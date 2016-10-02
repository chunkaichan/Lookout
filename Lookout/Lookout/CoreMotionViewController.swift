//
//  CoreMotionViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/1.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import CoreMotion


class CoreMotionViewController: UIViewController {

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
