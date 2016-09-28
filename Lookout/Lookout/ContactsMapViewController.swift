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

    @IBAction func didTapSendLocation(sender: AnyObject) {
        print("Send location:\(self.longitude), \(self.latitude)")
        sendLocation()
    }
    
    var ref: FIRDatabaseReference!
    var location: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    var locationManager: CLLocationManager!
    var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationManager()
        configureDatabase()
    }
    
    deinit {
        self.ref.child("location").removeObserverWithHandle(_refHandle)
    }

    var longitude: String?
    var latitude: String?
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("location").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            self.location.append(snapshot)
            let locationSnapshot: FIRDataSnapshot! = self.location[0]

            let remoteLocation = locationSnapshot.value as! [String: String]
            self.longitude = remoteLocation[Constants.Location.longitude] as String!
            self.latitude = remoteLocation[Constants.Location.latitude] as String!
            self.setAnnotation(latitudeDegree: (self.latitude! as NSString).doubleValue, longitudeDegree: (self.longitude! as NSString).doubleValue )
        })
        
        _refHandle = self.ref.child("location").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            self.location.append(snapshot)
            let locationSnapshot: FIRDataSnapshot! = self.location.last
            
            let remoteLocation = locationSnapshot.value as! [String: String]
            self.longitude = remoteLocation[Constants.Location.longitude] as String!
            self.latitude = remoteLocation[Constants.Location.latitude] as String!
            print("Location changed!")
            print(self.longitude)
            print(self.latitude)
            self.setAnnotation(latitudeDegree: (self.latitude! as NSString).doubleValue, longitudeDegree: (self.longitude! as NSString).doubleValue )
        })
    }
    
    func sendLocation() {
        var data = [Constants.Location.latitude: String(self.userLatitude)]
        data[Constants.Location.longitude] = String(self.userLongitude)
        self.ref.child("location/-K2ib4H77rj0LYewF7dP").setValue(data)
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
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.contactMap.setRegion(region, animated: false)
        
        locationManager.stopUpdatingLocation()
    }
    
    func setAnnotation(latitudeDegree latitudeDegree: Double, longitudeDegree: Double) {
        
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeDegree, longitudeDegree);
        let allAnnotations = self.contactMap.annotations
        contactMap.removeAnnotations(allAnnotations)
        contactMap.addAnnotation(myAnnotation)
        
    }

}
