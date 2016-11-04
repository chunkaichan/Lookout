//
//  NewContactViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/30.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase

class NewContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CoreDataManagerDelegate {

    @IBOutlet weak var addPhoto: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var saveNewContact: UIButton!
    
    var contactIsExist = false
    var senderTag = -1
    
    // Firebase
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 232/255, green: 193/255, blue: 35/255, alpha: 1)
        
        newNumber.keyboardType = .PhonePad
        saveNewContact.layer.cornerRadius = 8
        
        let tapToAdd = UITapGestureRecognizer(target: self, action: #selector(addNewPhoto))
        addPhoto.addGestureRecognizer(tapToAdd)
        addPhoto.userInteractionEnabled = true
        addPhoto.image = addPhoto.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addPhoto.tintColor = UIColor.grayColor()
        
        imagePicker.delegate = self
        
        ref = FIRDatabase.database().reference()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        if contactIsExist {
            CoreDataManager.shared.delegate = self
            CoreDataManager.shared.fetchCoreData()
        }
        
        
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            addPhoto.contentMode = .ScaleAspectFill
            addPhoto.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
            addPhoto.clipsToBounds = true
        }
        
    }
    
    func addNewPhoto() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveNewContact(sender: AnyObject) {

        guard let imageData = UIImageJPEGRepresentation(addPhoto.image!, 0.3) else { fatalError() }
        
        if ( newName.text == "" || newNumber.text == "" ||
            newEmail.text == "" || newTrackID.text == "" ) {
            
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
        else if ( contactIsExist ){
            
            contacts[senderTag].name = newName.text!
            contacts[senderTag].trackID = newTrackID.text!
            contacts[senderTag].email = newEmail.text!
            contacts[senderTag].phoneNumber = newNumber.text!
            contacts[senderTag].photo = imageData
            CoreDataManager.shared.clearCoreData()
            sendContactTrackIDToDB(trackID: newTrackID.text!)
            for contact in contacts {
                CoreDataManager.shared.saveCoreData(name: contact.name, number: contact.phoneNumber, email: contact.email, trackID: contact.trackID, photo: contact.photo!)
            }
            navigationController?.popToRootViewControllerAnimated(true)
        }
        
        else {
            CoreDataManager.shared.saveCoreData(
                name: newName.text!,
                number: newNumber.text!,
                email: newEmail.text!,
                trackID: newTrackID.text!,
                photo: imageData)
            sendContactTrackIDToDB(trackID: newTrackID.text!)
            navigationController?.popToRootViewControllerAnimated(true)
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
    
    var contacts: [Person] = []
    
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {
        contacts = []
        guard let results = didFetchContactData as? [Contact] else { fatalError() }
        if (results.count > 0) {
            for result in results {
                contacts.append(Person(
                    name: result.name!,
                    phoneNumber: result.number!,
                    trackID: result.trackID!,
                    email: result.email!,
                    photo: result.photo!))
            }
        }
        let contact = contacts[senderTag]
        newName.text = contact.name
        newTrackID.text = contact.trackID
        newEmail.text = contact.email
        newNumber.text = contact.phoneNumber
        addPhoto.image = UIImage(data: contact.photo!)
        addPhoto.contentMode = .ScaleAspectFill
        addPhoto.clipsToBounds = true
    }
    
    func sendContactTrackIDToDB(trackID trackID: String) {
        let databaseChildPath = "user_contacts/\(AppState.sharedInstance.UUID)"
        let data = [trackID : true]
        
        self.ref.child(databaseChildPath).updateChildValues(data)
        print("Profile sent to DB")
    }
}
