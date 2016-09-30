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
    
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
}
