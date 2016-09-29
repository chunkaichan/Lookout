//
//  SendAlertViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase

class SendAlertViewController: TabViewControllerTemplate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUUID()

    }
    
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    func checkUUID() {
        if (userDefault.objectForKey("UUID") == nil) {
            AppState.sharedInstance.userID = NSUUID.init().UUIDString
            print("Generate new UUID: \(AppState.sharedInstance.userID)")
            userDefault.setObject(AppState.sharedInstance.userID, forKey: "UUID")
            userDefault.synchronize()
        } else {
            AppState.sharedInstance.userID = userDefault.objectForKey("UUID") as? String
            print(AppState.sharedInstance.userID)
        }
        
        
    }
    
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
}
