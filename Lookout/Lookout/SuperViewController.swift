//
//  SuperViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/20.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Charts

class SuperViewController: UITabBarController, CoreMotionManagerDelegate {
    
    let sendAlertViewController = SendAlertViewController()
    let coreMotionViewController = CoreMotionViewController()
    
    var xAxis = [""]
    var yAxis = [1.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreMotionManager.shared.delegate = self
        if (AppState.sharedInstance.detectionEnabled) {
            CoreMotionManager.shared.startDetection()
        } else {
            CoreMotionManager.shared.stopDetection()
        }
        while (yAxis.count < 100) {
            xAxis.append("")
            yAxis.append(1.0)
        }
    }
    
    func manager(manager: CoreMotionManager, didGetMotion: Double) {
        
        yAxis.removeAtIndex(0)
        yAxis.append(didGetMotion)
        
        if (didGetMotion > 8.0) {
            sendAlertViewController.sendAlertWhenAccidentDeteced()
            let time = NSDate()
            let event = Event(time: time, data: yAxis, latitude: AppState.sharedInstance.userLatitude, longitude: AppState.sharedInstance.userLongitude, isAccident: nil)
            EventCoreDataManager.shared.saveCoreData(eventToSave: event)
        }
    }
    
    
}