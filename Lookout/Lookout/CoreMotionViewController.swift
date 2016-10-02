//
//  CoreMotionViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/1.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import CoreMotion
import CoreGraphics
import QuartzCore
import PNChartSwift


@objc class CoreMotionViewController: UIViewController {

    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    let manager = CMMotionManager()
    
    var temp: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
                    self!.temp = acceleration.x
                    print(self!.temp)
                }
            }
        }
        
        lineChart()
        
        

    }
    
    var ChartLabel:UILabel = UILabel(frame: CGRectMake(0, 90, 320.0, 30))
    
    func lineChart() {
        // Add LineChart
        ChartLabel.text = "Line Chart"
        
        let lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clearColor()
        lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
        lineChart.showCoordinateAxis = true
        lineChart.delegate = self
        
        // Line Chart Nr.1
        var data01Array: [CGFloat] = [60.1, 160.1, 126.4, 262.2, 186.2, 127.2, 176.2]
        let data01:PNLineChartData = PNLineChartData()
        data01.color = PNGreenColor
        data01.itemCount = data01Array.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = data01Array[index]
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        
        self.view.addSubview(lineChart)
        self.view.addSubview(ChartLabel)
        self.title = "Line Chart"
        dispatch_async(dispatch_get_main_queue()){
            if (self.title == "Line Chart") {
                print(123)
                data01Array = [ CGFloat(arc4random() % 300), CGFloat(arc4random() % 300), CGFloat(arc4random() % 300), CGFloat(arc4random() % 300), CGFloat(arc4random() % 300), CGFloat(arc4random() % 300), CGFloat(self.temp) ]
                let data01:PNLineChartData = PNLineChartData()
                data01.color = PNGreenColor
                data01.itemCount = data01Array.count
                data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone
                data01.getData = ({(index: Int) -> PNLineChartDataItem in
                    let yValue:CGFloat = data01Array[index]
                    let item = PNLineChartDataItem(y: yValue)
                    return item
                })
                
                
                lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
            }
        }
        
    }
    
    func getAccelerationMotion() {
//        if manager.accelerometerAvailable {
//            manager.accelerometerUpdateInterval = 0.01
//            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
//                [weak self] (data: CMAccelerometerData?, error: NSError?) in
//                if let acceleration = data?.acceleration {
//                    print(acceleration.x)
//                    
//                }
//            }
//        }
    }
    
}

extension CoreMotionViewController : PNChartDelegate {
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
    
    func userClickedOnBarChartIndex(barIndex: Int)
    {
        print("Click  on bar \(barIndex)")
    }
    
}
