//
//  CoreMotionManager.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/20.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation
import CoreMotion

protocol CoreMotionManagerDelegate: class {
    func manager(manager: CoreMotionManager, didGetMotion: Double)
//    func manager(manager: CoreMotionManager, didGetMotionForChart: Double)
}

extension CoreDataManagerDelegate {
    func manager(manager: CoreMotionManager, didGetMotion: Double) {}
//    func manager(manager: CoreMotionManager, didGetMotionForChart: Double) {}
}

class CoreMotionManager {
    
    static let shared = CoreMotionManager()
    
    let manager = CMMotionManager()
    
    weak var delegate: CoreMotionManagerDelegate?
    
    func startDetection() {
        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.04
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
                    let accX = acceleration.x
                    let accY = acceleration.y
                    let accZ = acceleration.z
                    let overallAcceleration = sqrt( accX*accX + accY*accY + accZ*accZ )
                    
                    self.delegate?.manager(self, didGetMotion: overallAcceleration)
                }
                
            }
        }
    }
    
    func stopDetection() {
        
        if manager.accelerometerAvailable {
            manager.stopAccelerometerUpdates()
        }
        
    }
    
}