//
//  ContactsMapViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/26.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

class ContactsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var contactMap: MKMapView!

    var contactNumber = ""
    
    @IBAction func tapCallButton(sender: AnyObject) {
        if (contactNumber == "") {
            let alert = UIAlertController(title: nil, message: "Contact number unavailable.", preferredStyle: .Alert)
            if (alert.actions.count == 0) {
                let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(alertAction)
            }
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            if let phoneCallURL:NSURL = NSURL(string: "tel://\(contactNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }
        }

    }
    
    @IBAction func tapNavigation(sender: AnyObject) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.contactMap.setRegion(region, animated: true)
    }

    let alert = UIAlertController(title: nil, message: "Ineffective track ID", preferredStyle: .Alert)
    
    @IBAction func tapRefresh(sender: AnyObject) {
        if (self.latitude != 0.0) {
            // Set region to current location if remote location unavailable
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.contactMap.setRegion(region, animated: true)
        } else {
            // Set region to remote location if remote location available
            if (alert.actions.count == 0) {
                let alertAction = UIAlertAction(title: "Close", style: .Default, handler: nil)
                alert.addAction(alertAction)
            }
            self.presentViewController(self.alert, animated: true, completion: nil)
        }
    }
    
    
    var trackID: String = ""
    var ref: FIRDatabaseReference!
    var location: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        contactMap.showsUserLocation = true
        contactMap.delegate = self

        configureDatabase()
        navigationController!.navigationBar.tintColor = UIColor(red: 232/255, green: 193/255, blue: 35/255, alpha: 1)
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = "醫院"
        localSearchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (searchResponse, error) in
            
            if searchResponse == nil {
                print(error)
                print("No result!!!!")
                return
            }
            
            if let hospitals = searchResponse?.mapItems {
                for hospital in hospitals {
                    let hospitalAnnotation = MKPointAnnotation()
                    hospitalAnnotation.title = hospital.placemark.name
                    if let hospitalNumber = hospital.phoneNumber,
                    hospitalAddress = hospital.placemark.title {
                        hospitalAnnotation.subtitle = hospitalAddress+"\n"+hospitalNumber
                    }
                    print(hospital.placemark.name)
                    print(hospital.phoneNumber)
                    
                    hospitalAnnotation.coordinate = hospital.placemark.coordinate
                    
                    self.contactMap.addAnnotation(hospitalAnnotation)
                }
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "hospitalPin")
        
        if annotation.coordinate.latitude != AppState.sharedInstance.userLatitude {
            pinAnnotationView.pinTintColor = UIColor.greenColor()
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let callButton = UIButton(type: .Custom)
            callButton.frame.size.width = 20
            callButton.frame.size.height = 20
            callButton.backgroundColor = UIColor.clearColor()
            callButton.setImage(UIImage(named: "contact-call"), forState: .Normal)
            callButton.addTarget(self, action: #selector(callHospital), forControlEvents: .TouchUpInside)
            
            if let subtitle = annotation.subtitle {
                if let phoneWithPlus = subtitle {
                    let subtitleRemoveAddress = phoneWithPlus.componentsSeparatedByString("\n")[1]
                    let stringArray = subtitleRemoveAddress.componentsSeparatedByCharactersInSet(
                        NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                    let newString = stringArray.joinWithSeparator("")
                    if let pureNumber =  Int(newString) {
                        callButton.tag = pureNumber
                    }
                }
            }
            
            pinAnnotationView.rightCalloutAccessoryView = callButton
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func callHospital(sender: UIButton) {
        print(sender.tag)
    }
    
    override func viewDidDisappear(animated: Bool) {
        latitude = 0.0
        longitude = 0.0
        ref.child("user_locations").removeObserverWithHandle(_refHandle)
        let allAnnotations = contactMap.annotations
        contactMap.removeAnnotations(allAnnotations)
    }

    var longitude = 0.0
    var latitude = 0.0
    var timestamp = 0.0
    var remoteLocation: [String:Double] = [
        Constants.Location.longitude : 0.0,
        Constants.Location.latitude : 0.0,
        Constants.Location.timestamp : 0.0
        ]
    
    func configureDatabase() {
        _refHandle = self.ref.child("user_locations/\(trackID)").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            if (snapshot.childrenCount != 0) {
                self.location.append(snapshot)
                let locationSnapshot: FIRDataSnapshot! = self.location.last
                self.remoteLocation = locationSnapshot.value as! [String:Double]
                
                self.longitude = self.remoteLocation[Constants.Location.longitude]!
                self.latitude = self.remoteLocation[Constants.Location.latitude]!
                self.timestamp = self.remoteLocation[Constants.Location.timestamp]!// as NSTimeInterval
                self.setAnnotation(latitudeDegree: self.latitude, longitudeDegree: self.longitude)
            }
        })
        
        // set region to current location if remote location unavailable
        if (latitude == 0.0) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            contactMap.setRegion(region, animated: false)
        }


    }
    
    var myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    func setAnnotation(latitudeDegree latitudeDegree: Double, longitudeDegree: Double) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm:ss"
        let convertedDate = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self.timestamp))
        
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeDegree, longitudeDegree)
        myAnnotation.title = "\(convertedDate)"
        
        if (contactMap.annotations.isEmpty && self.latitude != 0.0) {
            // remote location is available and annotation has not been set yet
            contactMap.addAnnotation(myAnnotation)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.contactMap.setRegion(region, animated: false)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        let allAnnotations = self.contactMap.annotations
        self.contactMap.removeAnnotations(allAnnotations)
    }

}
