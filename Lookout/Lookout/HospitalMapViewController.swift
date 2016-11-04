//
//  HospitalMapViewController.swift
//  
//
//  Created by Chunkai Chan on 2016/11/3.
//
//

import UIKit
import MapKit

class HospitalMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var hospitalMapView: MKMapView!
    
    @IBAction func setRegionCurrentLocation(sender: AnyObject) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        hospitalMapView.setRegion(region, animated: true)
    }
    override func viewDidLoad() {
        hospitalMapView.showsUserLocation = true
        hospitalMapView.delegate = self
        
        navigationController!.navigationBar.tintColor = UIColor(red: 232/255, green: 193/255, blue: 35/255, alpha: 1)
        
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        hospitalMapView.setRegion(region, animated: true)
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = "醫院"
        localSearchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(AppState.sharedInstance.userLatitude, AppState.sharedInstance.userLongitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (searchResponse, error) in
            
            if searchResponse == nil {
                let alert = UIAlertController(title: nil, message: "There's no hospital near you.", preferredStyle: .Alert)
                if (alert.actions.count == 0) {
                    let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(alertAction)
                }
                self.presentViewController(alert, animated: true, completion: nil)
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
                    
                    self.hospitalMapView.addAnnotation(hospitalAnnotation)
                }
            }
            
        }

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "hospitalPin")

        if annotation.coordinate.latitude != AppState.sharedInstance.userLatitude {
            pinAnnotationView.pinTintColor = UIColor.redColor()
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let callButton = UIButton(type: .Custom)
            callButton.frame.size.width = 20
            callButton.frame.size.height = 20
            callButton.backgroundColor = UIColor.clearColor()
            callButton.setImage(UIImage(named: "contact-call"), forState: .Normal)
            callButton.addTarget(self, action: #selector(callHospital), forControlEvents: .TouchUpInside)
            
            if let subtitle = annotation.subtitle {
                if let phoneWithPlusSign = subtitle {
                    let subtitleRemoveAddress = phoneWithPlusSign.componentsSeparatedByString("\n")[1]
                    let stringArray = subtitleRemoveAddress.componentsSeparatedByCharactersInSet(
                        NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                    let newString = stringArray.joinWithSeparator("")
                    if let pureNumber =  Int(newString) {
                        callButton.tag = pureNumber
                    } else { return nil }
                } else { return nil }
            } else { return nil }
            
            pinAnnotationView.rightCalloutAccessoryView = callButton
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func callHospital(sender: UIButton) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(sender.tag)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
}
