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

class SendAlertViewController: TabViewControllerTemplate, CLLocationManagerDelegate, CoreDataManagerDelegate, CoreMotionManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = contactsCollectionView.dequeueReusableCellWithReuseIdentifier("contactsCollectionCell", forIndexPath: indexPath) as! contactsCollectionViewCell
        cell.contactsButton.tag = indexPath.row
        cell.contactsButton.addTarget(self,action: #selector(buttonTapAction),forControlEvents: .TouchUpInside)
        cell.contactsButton.setImage(UIImage(named:"add-contact-circle" ), forState: .Normal)
        cell.contactsButton.imageView?.contentMode = .ScaleAspectFill
        if (indexPath.row < contacts.count) {
            if let contactPhoto = contacts[indexPath.row].photo {
                cell.contactsButton.setImage(UIImage(data: contactPhoto), forState: .Normal)
                cell.contactsButton.layer.cornerRadius = cell.contactsButton.layer.frame.width/2
                cell.contactsButton.clipsToBounds = true
            }
        }
        return cell
    }
    
    func buttonTapAction(sender: UIButton) {
        if (sender.tag < contacts.count) {
            let contact = contacts[sender.tag]
            showActionSheet(name: contact.name,
                            phoneNumber: contact.phoneNumber,
                            trackID: contact.trackID,
                            photoData: contact.photo!,
                            tag: sender.tag)
        } else {
            performSegueWithIdentifier("pushToAddContact", sender: nil)
        }
        
    }
    
    
    
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
        contactsCollectionView.backgroundColor = UIColor.clearColor()
        
        coreDataManager.delegate = self
        coreDataManager.fetchCoreData()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func sendAllAlert(sender: UIButton) {
        if (contacts.count != 0) {
            
            for contact in contacts {
                
                _refHandle = self.ref.child("user_token/\(contact.trackID)").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                    if let contactsToken = snapshot.value as? [String:String] {
                        if let token = contactsToken["token"] {
                            let defaults = NSUserDefaults.standardUserDefaults()
                            if let phone = defaults.stringForKey("userPhoneNumber") {
                                self.pushNotificationToContact(token: token, message: "Sent from \(phone)")
                            }
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
                            let defaults = NSUserDefaults.standardUserDefaults()
                            if let phone = defaults.stringForKey("userPhoneNumber") {
                                self.pushNotificationToContact(token: token, message: "Sent from \(phone)")
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    func pushNotificationToContact(token token: String, message: String) {
                let body = [ "to" : token ,
                             "priority" : "high",
                             "notification" : [ "title": "Emegency Notification",
                                                "body" : message,
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
                        print("STATUS CODE: \(statusCode)")
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
        
        UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
        UIApplication.sharedApplication().keyWindow?.rootViewController = self
        
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
    
    func showActionSheet(name name: String, phoneNumber: String, trackID: String, photoData: NSData, tag: Int) {
        
        let alert = UIAlertController(title: "\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
        let alertViewWidth = alert.view.bounds.size.width
        let buttonRadius: CGFloat = 40
        let photoRadios: CGFloat = 100
        let space: CGFloat = (alertViewWidth - 10 - photoRadios - 3*buttonRadius)/5
        
        let contactPhoto = UIImageView(frame: CGRectMake(10, 10, photoRadios, photoRadios))
        contactPhoto.image = UIImage(data: photoData)
        contactPhoto.contentMode = .ScaleAspectFill
        contactPhoto.clipsToBounds = true
        contactPhoto.layer.cornerRadius = contactPhoto.layer.frame.width/2
        alert.view.addSubview(contactPhoto)
        
        let contactName = UILabel(frame: CGRectMake(10+photoRadios+space, 20, 200, 40))
        contactName.text = name
        contactName.font = contactName.font.fontWithSize(25)
        alert.view.addSubview(contactName)
        
        let callButton = UIButton(type: .Custom)
        callButton.frame = CGRectMake(10+photoRadios+space, 70, buttonRadius, buttonRadius)
        callButton.setTitle("", forState: .Normal)
        callButton.setImage(UIImage(named: "call-contact"), forState: .Normal)
        callButton.backgroundColor = UIColor.clearColor()
        callButton.addTarget(self, action: #selector(callContact), forControlEvents: .TouchUpInside)
        callButton.tag = tag
        alert.view.addSubview(callButton)
        
        let viewMapButton = UIButton(type: .Custom)
        viewMapButton.frame = CGRectMake(10+photoRadios+space*2+buttonRadius, 70, buttonRadius, buttonRadius)
        viewMapButton.setTitle("", forState: .Normal)
        viewMapButton.setImage(UIImage(named: "view-map"), forState: .Normal)
        viewMapButton.backgroundColor = UIColor.clearColor()
        viewMapButton.addTarget(self, action: #selector(viewContactMap), forControlEvents: .TouchUpInside)
        viewMapButton.tag = tag
        alert.view.addSubview(viewMapButton)
        
        let viewProfileButton = UIButton(type: .Custom)
        viewProfileButton.frame = CGRectMake(10+photoRadios+space*3+buttonRadius*2, 70, buttonRadius, buttonRadius)
        viewProfileButton.setTitle("", forState: .Normal)
        viewProfileButton.setImage(UIImage(named: "contact-profile"), forState: .Normal)
        viewProfileButton.backgroundColor = UIColor.clearColor()
        viewProfileButton.addTarget(self, action: #selector(viewContactProfile), forControlEvents: .TouchUpInside)
        viewProfileButton.tag = tag
        alert.view.addSubview(viewProfileButton)
        
        if (alert.actions.count == 0) {
            alert.addAction(UIAlertAction(title: "Delete contact", style: .Destructive, handler: { _ in
                
                self.deleteContact(senderTag: tag)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func callContact(sender: UIButton) {
        print(sender.tag)
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(contacts[sender.tag].phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func viewContactMap(sender: UIButton) {
        print(sender.tag)
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("viewContactMap", sender: sender)
    }
    
    func viewContactProfile(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("pushToAddContact", sender: sender)
    }
    
    func deleteContact(senderTag tag: Int) {
        
        let confirmDelete = UIAlertController(title: "Delete this contact?", message: nil, preferredStyle: .ActionSheet)
        confirmDelete.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { _ in
            self.contacts.removeAtIndex(tag)
            CoreDataManager.shared.clearCoreData()
            for contact in self.contacts {
                CoreDataManager.shared.saveCoreData(name: contact.name, number: contact.phoneNumber, email: contact.email, trackID: contact.trackID, photo: contact.photo!)
            }
            CoreDataManager.shared.fetchCoreData()
        }))
        
        confirmDelete.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(confirmDelete, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewContactMap" {
            let destination: ContactsMapViewController = segue.destinationViewController as! ContactsMapViewController
            destination.trackID = contacts[(sender?.tag)!].trackID
            destination.navigationItem.title = contacts[(sender?.tag)!].name
            destination.contactNumber = contacts[(sender?.tag)!].phoneNumber
            print("press segue to map")
        }
        if (segue.identifier == "pushToAddContact") {
            
            if let tag = sender?.tag {
                let destination: NewContactViewController = segue.destinationViewController as! NewContactViewController
                destination.contactIsExist = true
                destination.senderTag = tag
                print("press segue to profile")
            }
            
        }
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
        contacts = []
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
            contactsCollectionView.reloadData()
        }
    }
    
    deinit {
        if (contacts.count != 0) {
            for contact in contacts {
                ref.child("user_token/\(contact.trackID)").removeObserverWithHandle(_refHandle)
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