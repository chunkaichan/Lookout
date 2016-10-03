//
//  ContainerViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/22.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var scrollableSideMenu: UIScrollView!
    
    @IBOutlet weak var transparentView: UIView!
    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = 100
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        transparentView.userInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tap.delegate = self
        transparentView.addGestureRecognizer(tap)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
        
        // Tab bar controller's child pages have a top-left button toggles the menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(toggleMenu), name: "toggleMenu", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(closeMenuViaNotification), name: "closeMenuViaNotification", object: nil)
        
        // Close the menu when the device rotates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(animated:Bool = true) {
        scrollableSideMenu.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: animated)
        transparentView.userInteractionEnabled = false
    }
    
    func openMenu() {
        scrollableSideMenu.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        transparentView.userInteractionEnabled = true
    }
    
    // This wrapper function is necessary because
    // closeMenu params do not match up with Notification
    func closeMenuViaNotification() {
        closeMenu()
    }
    
    func toggleMenu() {
        openMenu()
    }
    
    func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            dispatch_async(dispatch_get_main_queue()) {
                print("closing menu on rotate")
                self.closeMenu()
            }
        }
    }
    
    func tapView() {
        closeMenuViaNotification()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension ContainerViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x == 0) {
            transparentView.userInteractionEnabled = true
        } else {
            transparentView.userInteractionEnabled = false
        }
    }
    
    // http://www.4byte.cn/question/49110/uiscrollview-change-contentoffset-when-change-frame.html
    // When paging is enabled on a Scroll View,
    // a private method _adjustContentOffsetIfNecessary gets called,
    // presumably when present whatever controller is called.
    // The idea is to disable paging.
    // But we rely on paging to snap the slideout menu in place
    // (if you're relying on the built-in pan gesture).
    // So the approach is to keep paging disabled.
    // But enable it at the last minute during scrollViewWillBeginDragging.
    // And then turn it off once the scroll view stops moving.
    //
    // Approaches that don't work:
    // 1. automaticallyAdjustsScrollViewInsets -- don't bother
    // 2. overriding _adjustContentOffsetIfNecessary -- messing with private methods is a bad idea
    // 3. disable paging altogether.  works, but at the loss of a feature
    // 4. nest the scrollview inside UIView, so UIKit doesn't mess with it.  may have worked before,
    //    but not anymore.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollableSideMenu.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollableSideMenu.pagingEnabled = false
    }
}
