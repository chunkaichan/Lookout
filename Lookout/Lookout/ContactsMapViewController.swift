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

class ContactsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var contactMap: MKMapView!

    
    @IBAction func tapNavigation(sender: AnyObject) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.userLatitude, self.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.contactMap.setRegion(region, animated: true)
    }

    let alert = UIAlertController(title: nil, message: "Ineffective track ID", preferredStyle: .Alert)
    
    @IBAction func tapRefresh(sender: AnyObject) {
        if (self.latitude != 0.0) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.contactMap.setRegion(region, animated: true)
        } else {
            if (alert.actions.count == 0) {
                let alertAction = UIAlertAction(title: "Close", style: .Default, handler: nil)
                alert.addAction(alertAction)
            }
            self.presentViewController(self.alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func didTapSendLocation(sender: AnyObject) {
        sendLocation()
    }
    
    var trackID: String = ""
    var ref: FIRDatabaseReference!
    var location: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    var locationManager: CLLocationManager!
    var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        if let user = FIRAuth.auth()?.currentUser {
            AppState.sharedInstance.UUID = user.uid
        }
        setLocationManager()
        configureDatabase()
        
//        var _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setLocationManager), userInfo: nil, repeats: true)
//        var _ = NSTimer.scheduledTimerWithTimeInterval(1.001, target: self, selector: #selector(stopUpdate), userInfo: nil, repeats: true)
    }
    
    func stopUpdate() {
        self.locationManager.delegate = nil
    }
    
    deinit {
        self.ref.child("user_locations").removeObserverWithHandle(_refHandle)
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
        // Listen for new messages in the Firebase database
//        _refHandle = self.ref.child("user_locations").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
//            self.location.append(snapshot)
//            let locationSnapshot: FIRDataSnapshot! = self.location[0]
//
//            let remoteLocation = locationSnapshot.value as! [String: String]
//            self.longitude = remoteLocation[Constants.Location.longitude] as String!
//            self.latitude = remoteLocation[Constants.Location.latitude] as String!
//            self.setAnnotation(latitudeDegree: (self.latitude! as NSString).doubleValue, longitudeDegree: (self.longitude! as NSString).doubleValue )
//        })
//        
//        _refHandle = self.ref.child("user_locations/\(trackID)").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
//            
//            self.location.append(snapshot)
//            let locationSnapshot: FIRDataSnapshot! = self.location.last
//            self.remoteLocation[locationSnapshot.key] = locationSnapshot.value as? Double
//            self.longitude = self.remoteLocation[Constants.Location.longitude]!
//            self.latitude = self.remoteLocation[Constants.Location.latitude]!
////            print("Location changed!")
////            print(self.longitude)
////            print(self.latitude)
//            self.setAnnotation(latitudeDegree: self.latitude, longitudeDegree: self.longitude)
//        })

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


    }
    
    func sendLocation() {
        
        var data = [Constants.Location.latitude: self.userLatitude]
        data[Constants.Location.longitude] = self.userLongitude
        data[Constants.Location.timestamp] = NSDate().timeIntervalSince1970
        self.ref.child("user_locations/\(AppState.sharedInstance.UUID)").setValue(data)
    }
    
    func setLocationManager() {
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
        contactMap.showsUserLocation = true
        contactMap.delegate = self
        
    }
    
    var userLongitude: Double = 0.0
    var userLatitude: Double = 0.0
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = self.locationManager.location?.coordinate ?? center
        
        self.userLongitude = userLocation.longitude
        self.userLatitude = userLocation.latitude
        
        
        if (self.latitude == 0.0) {
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.contactMap.setRegion(region, animated: false)
        }
        
        locationManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()
        sendLocation()
    
    }
    
    var myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    func setAnnotation(latitudeDegree latitudeDegree: Double, longitudeDegree: Double) {
        
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeDegree, longitudeDegree)
        myAnnotation.title = "\(NSDate(timeIntervalSince1970: self.timestamp))"
        if (contactMap.annotations.isEmpty) {
            contactMap.addAnnotation(myAnnotation)
        }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.contactMap.setRegion(region, animated: false)
        
    }

}
