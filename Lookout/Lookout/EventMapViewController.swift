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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setChart(xdata, values: (event?.data)!)
        setAnnotation(latitudeDegree: (event?.latitude)!, longitudeDegree: (event?.longitude)!, timestamp: (event?.time)!)
    }
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let color = UIColor.blackColor()
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: nil)
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        lineChartDataSet.colors = [color]
        lineChartDataSet.drawCirclesEnabled = false
        
        eventChart.data = lineChartData
        eventChart.xAxis.labelPosition = .Bottom
        
        //remove xAxis line
        eventChart.xAxis.drawGridLinesEnabled = false
        eventChart.xAxis.drawAxisLineEnabled = false
        eventChart.xAxis.drawLabelsEnabled = false
        
        //remove description
        eventChart.descriptionText = ""
        eventChart.rightAxis.removeAllLimitLines()
        eventChart.rightAxis.drawZeroLineEnabled = false
        eventChart.rightAxis.drawTopYLabelEntryEnabled = false
        eventChart.rightAxis.drawAxisLineEnabled = false
        eventChart.rightAxis.drawGridLinesEnabled = false
        eventChart.rightAxis.drawLabelsEnabled = false
        eventChart.rightAxis.drawLimitLinesBehindDataEnabled = false
        
        eventChart.leftAxis.axisMaxValue = 8
        eventChart.leftAxis.axisMinValue = 0
        
        eventChart.legend.enabled = false
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
