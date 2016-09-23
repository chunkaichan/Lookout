//
//  ContainerViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/22.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    @IBOutlet weak var scrollableSideMenu: UIScrollView!

    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = 200
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
        
        // Tab bar controller's child pages have a top-left button toggles the menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(toggleMenu), name: "toggleMenu", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(closeMenuViaNotification), name: "closeMenuViaNotification", object: nil)
    }
    
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(animated:Bool = true){
        scrollableSideMenu.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: animated)
    }
    
    func openMenu(){
        scrollableSideMenu.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // This wrapper function is necessary because
    // closeMenu params do not match up with Notification
    func closeMenuViaNotification(){
        closeMenu()
    }
    
    func toggleMenu(){
        openMenu()
    }
    
    
}
