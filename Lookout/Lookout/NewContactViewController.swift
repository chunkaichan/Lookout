//
//  NewContactViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/30.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class NewContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addPhoto: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var saveNewContact: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 65/255, green: 188/255, blue: 165/255, alpha: 1)
        
        
        saveNewContact.layer.cornerRadius = 8
        
        let tapToAdd = UITapGestureRecognizer(target: self, action: #selector(addNewPhoto))
        addPhoto.addGestureRecognizer(tapToAdd)
        addPhoto.userInteractionEnabled = true
        addPhoto.image = addPhoto.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addPhoto.tintColor = UIColor.whiteColor()
        
        imagePicker.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 40)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += (keyboardSize.height - 40)
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addPhoto.contentMode = .ScaleToFill
            addPhoto.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func addNewPhoto() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveNewContact(sender: AnyObject) {

        guard let imageData = UIImageJPEGRepresentation(addPhoto.image!, 1) else { fatalError() }
        
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
                trackID: self.newTrackID.text!,
                photo: imageData)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var newNumber: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var newTrackID: UITextField!
    
    let alert = UIAlertController(title: nil, message: "Please fill in all fields.", preferredStyle: .Alert)
    
    override func viewDidAppear(animated: Bool) {
        
        if (alert.actions.count == 0) {
            let alertAction = UIAlertAction(title: "Close", style: .Default, handler: nil)
            alert.addAction(alertAction)
        }
    }
}
