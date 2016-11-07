//
//  EventMapViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/17.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import MapKit
import Charts

class EventMapViewController: UIViewController {

    @IBOutlet weak var eventMap: MKMapView!
    @IBOutlet weak var eventChart: LineChartView!
    
    var event: Event?
    var xdata = [""]
    
    let chartView = ChartViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.setChartFormat(lineChartView: eventChart)
        chartView.setChartData(lineChartView: eventChart, dataPoints: xdata, values: (event?.data)!)

        setAnnotation(latitudeDegree: (event?.latitude)!, longitudeDegree: (event?.longitude)!, timestamp: (event?.time)!)
    }
    
    var myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    func setAnnotation(latitudeDegree latitudeDegree: Double, longitudeDegree: Double, timestamp: NSDate) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm:ss"
        let convertedDate = dateFormatter.stringFromDate(timestamp)
        
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeDegree, longitudeDegree)
        myAnnotation.title = "\(convertedDate)"
        if (eventMap.annotations.isEmpty) {
            // remote location is available and annotation has not been set yet
            eventMap.addAnnotation(myAnnotation)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitudeDegree, longitudeDegree), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.eventMap.setRegion(region, animated: false)
        }
        
    }

    
}
