//
//  SendAlertViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase
import GoogleAPIClientForREST
import GTMOAuth2
import CoreLocation
import AudioToolbox

class SendAlertViewController: TabViewControllerTemplate, CLLocationManagerDelegate, CoreDataManagerDelegate, CoreMotionManagerDelegate {
    
    // Google Auth
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "556205392726-s6pohtn44l7eqpgmf0qtjq8mp0crt1nd.apps.googleusercontent.com"
    private let service = GTLRGmailService()
    
    // Firebase
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    
    let coreDataManager = CoreDataManager.shared
    let coreMotionManager = CoreMotionManager.shared
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        setLocationManager()
    }
    
    @IBAction func sendAllAlert(sender: UIButton) {
        if (contacts.count != 0) {
            
            for contact in contacts {
                print(contact.trackID)
                
                _refHandle = self.ref.child("user_token/\(contact.trackID)").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                    if let contactsToken = snapshot.value as? [String:String] {
                        if let token = contactsToken["token"] {
                            self.pushNotificationToContact(token: token, message: "msg body")
                        }
                    }
                })
                
                let gtlMessage = GTLRGmail_Message()
                for contact in contacts {
                    gtlMessage.raw = self.generateRawString(toMail: contact.email, body: "This is a emergency notification from Lookout.")
                    
                    let query = GTLRGmailQuery_UsersMessagesSend.queryWithObject(gtlMessage, userId: "me", uploadParameters: nil)
                    
                    service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                        print("ticket \(ticket)")
                        print("response \(response)")
                        print("error \(error)")
                        
                        if error != nil {
                            self.showAlert(message: "Failed to send email.", actionTitle: "Close")
                        } else {
                            self.showAlertAfterSending()
                        }
                    })
                }
            }
            
            
        } else {
            showAlert(message: "Please add a contact", actionTitle: "OK")
        }
    }
    
    @IBAction func clickSendMessage(sender: UIButton) {
        if (contacts.count != 0) {
            
            for contact in contacts {
                print(contact.trackID)
                
                _refHandle = self.ref.child("user_token/\(contact.trackID)").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                    if let contactsToken = snapshot.value as? [String:String] {
                        if let token = contactsToken["token"] {
                            self.pushNotificationToContact(token: token, message: "msg body")
                        }
                    }
                })
            }
        }
        
    }
    
    func pushNotificationToContact(token token: String, message: String) {
                let body = [ "to" : token ,
                             "priority" : "high",
                             "notification" : [ "title": "this is title",
                                                "body" : message,
                                                "alert" :"this is alert",
                                                "sound": "default"
                                              ]
                           ]
        
                let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")
                let mutableURLRequest = NSMutableURLRequest(URL: url!)
                let session = NSURLSession.sharedSession()
                do {
                    let jsonBody = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
                    mutableURLRequest.HTTPMethod = "POST"
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.setValue("key=\(AppState.sharedInstance.APIKey)", forHTTPHeaderField: "Authorization")
                    mutableURLRequest.HTTPBody = jsonBody
                    let task = session.dataTaskWithRequest(mutableURLRequest) {
                        ( data , response, error ) in
                        let httpResponse = response as! NSHTTPURLResponse
                        let statusCode = httpResponse.statusCode
                        print(statusCode)
                    }
                    task.resume()
                } catch {
                    print(error)
                }
    }
    
    @IBAction func detectionEnabledButton(sender: UIButton) {
        let originalImage = UIImage(named: "fall-detection")
        let tintImage = originalImage?.imageWithRenderingMode(.AlwaysTemplate)
        if (AppState.sharedInstance.detectionEnabled == true) {
            AppState.sharedInstance.detectionEnabled = false
            sender.setImage(tintImage, forState: .Normal)
            sender.tintColor = UIColor.grayColor()
            CoreMotionManager.shared.stopDetection()
        } else {
            AppState.sharedInstance.detectionEnabled = true
            sender.setImage(originalImage, forState: .Normal)
            CoreMotionManager.shared.startDetection()
        }
    }

    var locationManager: CLLocationManager!
    
    func setLocationManager() {
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
        print(locationManager.location?.coordinate)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        if let userLatitude = locationManager.location?.coordinate.latitude, userLongitude = locationManager.location?.coordinate.longitude {
            AppState.sharedInstance.userLatitude = userLatitude
            AppState.sharedInstance.userLongitude = userLongitude
        }
        
        sendLocationToDB()
        
        if UIApplication.sharedApplication().applicationState == .Background {
            NSLog("background time: %f", UIApplication.sharedApplication().backgroundTimeRemaining)
        }
        
    }
    
    func sendLocationToDB() {
        
        var data = [Constants.Location.latitude: AppState.sharedInstance.userLatitude]
        data[Constants.Location.longitude] = AppState.sharedInstance.userLongitude
        data[Constants.Location.timestamp] = NSDate().timeIntervalSince1970
        self.ref.child("user_locations/\(AppState.sharedInstance.UUID)").setValue(data)
        
        print("Send current location to database.")
    }
    
    override func viewDidAppear(animated: Bool) {
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        contacts = []
        
        coreDataManager.delegate = self
        coreDataManager.fetchCoreData()
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            tokenUploadToDatabase(token: refreshedToken)
        }
        
    }
    
    func tokenUploadToDatabase(token token: String) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let data = ["token": token ]
        print("user_token/\(AppState.sharedInstance.UUID)")
        ref.child("user_token/\(AppState.sharedInstance.UUID)").setValue(data)
        print("send token to db")
    }
    
    func sendAlertWhenAccidentDeteced() {
        print("Send alert automatically when accident is detected.")
    }
    
    @IBAction func tapSendEmail(sender: AnyObject) {
        if (contacts.count != 0) {
            let gtlMessage = GTLRGmail_Message()
            for contact in contacts {
                gtlMessage.raw = self.generateRawString(toMail: contact.email, body: "This is a emergency notification from Lookout.")
                
                let query = GTLRGmailQuery_UsersMessagesSend.queryWithObject(gtlMessage, userId: "me", uploadParameters: nil)
                
                service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                    print("ticket \(ticket)")
                    print("response \(response)")
                    print("error \(error)")
                    
                    if error != nil {
                        self.showAlert(message: "Failed to send your message", actionTitle: "Close")
                    } else {
                        self.showAlertAfterSending()
                    }
                })
            }
        } else {
            showAlert(message: "Please add a contact", actionTitle: "OK")
        }
        
    }
    
    @IBAction func tapPhoneCall(sender: AnyObject) {
        if contacts.count==0 {
            showAlert(message: "Please add a contact", actionTitle: "OK")
        } else {
            let randomNumber = Int(arc4random_uniform(UInt32(contacts.count)))
            callNumber(contacts[randomNumber].phoneNumber)
        }
    }
    
    var fromLocationURL = "- User location unavailable -"
    
    func generateRawString(toMail toMail: String, body: String) -> String {
        
        if (AppState.sharedInstance.userLatitude != 0.0) {
            fromLocationURL = "http://maps.google.com/maps?q=loc:\(AppState.sharedInstance.userLatitude),\(AppState.sharedInstance.userLongitude)"
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "Emergency contact", mailbox: toMail)]
//        builder.header.from = MCOAddress(displayName: "From Lookout: Emergency Notification", mailbox: "kyle791121@hotmail.com")
        builder.header.subject = "From Lookout"
        builder.htmlBody = "\(body)" +
                           "<br><br>" +
                           "Sent from location:" +
                           "<br>" +
                           "\(fromLocationURL)"
        
        builder.header.date = NSDate()
        
        //
        let rfc822Data = builder.data()
        
        return GTLREncodeWebSafeBase64(rfc822Data)!
    }
    
    func showAlert(message message: String, actionTitle: String) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        if (alert.actions.count == 0) {
            let alertAction = UIAlertAction(title: actionTitle, style: .Default, handler: nil)
            alert.addAction(alertAction)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlertAfterSending() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let time = NSDate()
        let alert = UIAlertController(
            title: nil,
            message: "\(time)\nYou just sent a notification to your contacts.\nDo you want to send a safety message?",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "YES",
            style: UIAlertActionStyle.Default,
            handler: {(alert: UIAlertAction!) in
                let gtlMessage = GTLRGmail_Message()
                for contact in self.contacts {
                    print(contact.email)
                    gtlMessage.raw = self.generateRawString(toMail: contact.email, body: "I am safe right now!")
                    
                    let query = GTLRGmailQuery_UsersMessagesSend.queryWithObject(gtlMessage, userId: "me", uploadParameters: nil)
                    
                    self.service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                        print("ticket \(ticket)")
                        print("response \(response)")
                        print("error \(error)")
                        
                        if error != nil {
                            self.showAlert(message: "Failed to send your message.", actionTitle: "Close")
                        } else {
                            self.showAlert(message: "Safety message is successfully sent!", actionTitle: "Close")
                        }
                    })
                }
            }
        )
        let cancel = UIAlertAction(
            title: "NO",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(cancel)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    var contacts: [Person] = []
    
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {
        guard let results = didFetchContactData as? [Contact] else { fatalError() }
        if (results.count > 0) {
            for result in results {
                contacts.append(Person(
                    name: result.name!,
                    phoneNumber: result.number!,
                    trackID: result.trackID!,
                    email: result.email!,
                    photo: result.photo!))
            }
        }
    }
}

protocol SendAlertViewControllerDelegate: class {
    func manager(manager manager: SendAlertViewController, didGetCoreMotion: AnyObject)
    func manager(manager manager: SendAlertViewController, didReachThreshold: AnyObject)
}

extension SendAlertViewController {
    func manager(manager manager: SendAlertViewController, didGetCoreMotion: AnyObject) {}
    func manager(manager manager: SendAlertViewController, didReachThreshold: AnyObject) {}
}