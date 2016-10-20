//
//  SuperViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/20.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class SuperViewController: UITabBarController, CoreMotionManagerDelegate {
    
    let sendAlertViewController = SendAlertViewController()
    let coreMotionViewController = CoreMotionViewController()
    
    override func viewDidLoad() {
        
        CoreMotionManager.shared.delegate = self
        CoreMotionManager.shared.startDetection()
        
    }
    
    func manager(manager: CoreMotionManager, didGetMotion: Double) {
        print("Superview: \(didGetMotion)")
    }
    
}