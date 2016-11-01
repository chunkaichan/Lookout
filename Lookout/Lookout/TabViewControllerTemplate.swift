//
//  TabViewControllerTemplate.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class TabViewControllerTemplate: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
    }
}