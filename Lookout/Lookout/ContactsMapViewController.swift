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
            print(self.longitude)
            print(self.latitude)
        })
    }
    
    func sendLocation() {
        var data = [Constants.Location.latitude: self.latitude! as String]
        data[Constants.Location.longitude] = self.longitude! as String
        self.ref.child("location").childByAutoId().setValue(data)
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = self.locationManager.location?.coordinate ?? center
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.contactMap.setRegion(region, animated: false)
        
        locationManager.stopUpdatingLocation()
    }
}
