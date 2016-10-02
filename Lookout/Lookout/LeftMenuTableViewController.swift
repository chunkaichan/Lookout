//
//  LeftMenuTableViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase

class LeftMenuTableViewController: UITableViewController {
    
    @IBOutlet var leftMenu: UITableView!
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuIcon.count
    }
    
    let menuIcon = ["menu-profile", "menu-settings","menu-signout"]
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = leftMenu.dequeueReusableCellWithIdentifier("LeftMenuCell", forIndexPath:  indexPath) as! LeftMenuTableViewCell
        cell.leftMenuIcon.image = UIImage(named: "\(menuIcon[indexPath.row])")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch menuIcon[indexPath.row] {
        case Constants.LeftMenuKeys.logOut.rawValue:
            signOut()
        case Constants.LeftMenuKeys.profile.rawValue:
            print("Go to profile page")
        case Constants.LeftMenuKeys.settings.rawValue:
            print("Go to setting page")
        default: print("wtf")
        }
        
    }
    
    func signOut() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }
}