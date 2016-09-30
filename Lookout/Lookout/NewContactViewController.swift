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
        
        CoreDataManager.shared.saveCoreData(
            name: self.newName.text!,
            number: self.newNumber.text!,
            email: self.newEmail.text!,
            trackID: self.newTrackID.text!)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var newNumber: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var newTrackID: UITextField!
    
    
    
}
