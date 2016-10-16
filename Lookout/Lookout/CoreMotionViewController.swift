//
//  CoreMotionViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/1.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import CoreMotion
import Charts

class CoreMotionViewController: UIViewController {
    
    @IBAction func saveEventButton(sender: AnyObject) {
        let time = NSDate()
        shared.saveCoreData(time: time, data: yAxis, latitude: AppState.sharedInstance.userLatitude, longitude: AppState.sharedInstance.userLongitude, isAccident: nil)
    }
    
    @IBOutlet weak var xLineChartView: LineChartView!
    
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    let manager = CMMotionManager()
    
    var xAxis = [""]
    var yAxis = [0.0]
    
    var dataEntries: [ChartDataEntry] = []
    
    let shared = EventCoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        while (yAxis.count < 200) {
            xAxis.append("")
            yAxis.append(0)
        }
        getAccelerationMotion()
        
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
        
        xLineChartView.data = lineChartData
        xLineChartView.xAxis.labelPosition = .Bottom
        
        //remove xAxis line
        xLineChartView.xAxis.drawGridLinesEnabled = false
        xLineChartView.xAxis.drawAxisLineEnabled = false
        xLineChartView.xAxis.drawLabelsEnabled = false
        
        //remove description
        xLineChartView.descriptionText = ""
        xLineChartView.rightAxis.removeAllLimitLines()
        xLineChartView.rightAxis.drawZeroLineEnabled = false
        xLineChartView.rightAxis.drawTopYLabelEntryEnabled = false
        xLineChartView.rightAxis.drawAxisLineEnabled = false
        xLineChartView.rightAxis.drawGridLinesEnabled = false
        xLineChartView.rightAxis.drawLabelsEnabled = false
        xLineChartView.rightAxis.drawLimitLinesBehindDataEnabled = false
        
        xLineChartView.leftAxis.axisMaxValue = 8
        xLineChartView.leftAxis.axisMinValue = 0
        
        xLineChartView.legend.enabled = false
    }
    
    
    func getAccelerationMotion() {
        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.02
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
                    let overallAcceleration = sqrt(acceleration.x*acceleration.x + acceleration.y*acceleration.y + acceleration.z*acceleration.z)
                    self!.yAxis.removeAtIndex(0)
                    self!.yAxis.append(overallAcceleration)
                    self!.setChart(self!.xAxis, values: self!.yAxis)
                }
                
            }
        }
    }
    
}
