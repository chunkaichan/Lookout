//
//  NewContactViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/30.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class NewContactViewController: UIViewController {

    @IBAction func saveNewContact(sender: AnyObject) {

        if ( self.newName.text == "" ||
             self.newNumber.text == "" ||
             self.newEmail.text == "" ||
            self.newTrackID.text == "" ) {
            self.presentViewController(self.alert, animated: true, completion: nil)
        } else {
            CoreDataManager.shared.saveCoreData(
                name: self.newName.text!,
                number: self.newNumber.text!,
                email: self.newEmail.text!,
                trackID: self.newTrackID.text!)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var newNumber: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var newTrackID: UITextField!
    
    let alert = UIAlertController(title: nil, message: "Please fill in all fields.", preferredStyle: .Alert)
    
    override func viewDidAppear(animated: Bool) {
        
        let alertAction = UIAlertAction(title: "Close", style: .Default, handler: nil)
        alert.addAction(alertAction)
    }
}
