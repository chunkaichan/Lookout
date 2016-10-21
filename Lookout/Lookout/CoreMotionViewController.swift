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

class CoreMotionViewController: UIViewController, EventCoreDataManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventsUITableView: UITableView!
    
    @IBAction func saveEventButton(sender: AnyObject) {
        let time = NSDate()
        let event = Event(time: time, data: yAxis, latitude: AppState.sharedInstance.userLatitude, longitude: AppState.sharedInstance.userLongitude, isAccident: nil)
        eventCoreDataManager.saveCoreData(eventToSave: event)
        eventCoreDataManager.fetchCoreData()
    }
    
    @IBOutlet weak var xLineChartView: LineChartView!
    
    let manager = CMMotionManager()
    
    var xAxis = [""]
    var yAxis = [1.0]
    
    var dataEntries: [ChartDataEntry] = []
    
    let eventCoreDataManager = EventCoreDataManager.shared
    
    var event: Event?
    var events:[Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        while (yAxis.count < 100) {
            xAxis.append("")
            yAxis.append(1.0)
        }
        
        eventCoreDataManager.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Start updating chart.")
        getAccelerationMotion()
        eventCoreDataManager.fetchCoreData()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        if manager.accelerometerAvailable {
            manager.stopAccelerometerUpdates()
            print("Stop updating chart.")
        }
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
            manager.accelerometerUpdateInterval = 0.04
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
                    let overallAcceleration = sqrt(acceleration.x*acceleration.x + acceleration.y*acceleration.y + acceleration.z*acceleration.z)
                    self!.yAxis.removeAtIndex(0)
                    self!.yAxis.append(overallAcceleration)
                    
                    if (UIApplication.sharedApplication().applicationState == .Active) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self!.setChart(self!.xAxis, values: self!.yAxis)
                        })
                    }
                }
                
            }
        }
    }
    
    func manager(manager: EventCoreDataManager, didSaveEventData: AnyObject) {
        print("Save an event to core data")
    }
    func manager(manager: EventCoreDataManager, didFetchEventData: AnyObject) {
        events = []
        print("Fetch events from core data.")
        guard let results = didFetchEventData as? [Events] else {fatalError()}
        if (results.count>0) {
            for result in results {
                events.append(Event(time: result.time!, data: result.data! as! [Double], latitude: result.latitude! as Double, longitude: result.longitude! as Double, isAccident: result.isAccident as? Bool))
                
            }
            dispatch_async(dispatch_get_main_queue(), {
                UIView.transitionWithView(self.eventsUITableView, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    () -> Void in
                    self.eventsUITableView.reloadData()
                    }, completion: nil)
            })
        }
    }
    
    func manager(manager: EventCoreDataManager, getFetchEventError: ErrorType) {
        print("Error when fetch events from core data.")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = (events.count - 1) - indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("EventsTableCell", forIndexPath: indexPath) as! EventsTableViewCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
        let convertedDate = dateFormatter.stringFromDate(events[index].time)
        cell.eventTime.text = "\(convertedDate)"
        return cell
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let index = (events.count - 1) - indexPath.row
            events.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            eventCoreDataManager.clearCoreData()
            for event in events {
                eventCoreDataManager.saveCoreData(eventToSave: event)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = (events.count - 1) - indexPath.row
        event = events[index]
        self.performSegueWithIdentifier("SegueEventDetail", sender: [])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueEventDetail" {
            let destination: EventMapViewController = segue.destinationViewController as! EventMapViewController
            destination.xdata = xAxis
            destination.event = event
        }
    }
}
