//
//  ProfileViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/3.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import Firebase
import Crashlytics
import MessageUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var loadDataIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bloodTextField: UITextField!
    @IBOutlet weak var trackID: UILabel!
    
    @IBOutlet weak var connectGmail: UIButton!
    @IBOutlet weak var connectedStatus: UILabel!
    
    @IBOutlet weak var closeButtonStyle: UIButton!
    @IBOutlet weak var editButtonStyle: UIButton!
    
    @IBAction func connectGmail(sender: AnyObject) {
        
        if (connectGmail.titleLabel?.text == " Connect ") {
            // Connect with Gmail
            self.navigationController?.pushViewController(createAuthController(), animated: true)
        } else {
            // Disconnect
            GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName("Gmail API")
            self.connectGmail.setTitle(" Connect ", forState: .Normal)
            self.connectedStatus.text = "Not connected"
        }
    }
    
    @IBAction func editButton(sender: AnyObject) {
        
        dismissKeyboard()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        if (inEditMode) {
            didCancelEdit()
            changeBarButtonImage(leftButtonLink: editLink, rightButtonLink: logOutLink)
        } else {
            // tap to edit
            userProfileBeforeEdit = Profile(name: nameTextField.text ?? "Empty" ,
                                            birth: birthTextField.text ?? "Empty" ,
                                            address: addressTextField.text ?? "Empty" ,
                                            phone: phoneTextField.text ?? "Empty" ,
                                            blood: bloodTextField.text ?? "Empty")
            didTapEdit()
            changeBarButtonImage(leftButtonLink: cancelLink, rightButtonLink: saveLink)
            
            // Test Crashlytics
            //            Crashlytics.sharedInstance().crash()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func sendTrackIDWithSMS(sender: UIButton) {
        
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "This is my tracking number:\n\(AppState.sharedInstance.UUID)"
            messageVC.messageComposeDelegate = self
            self.presentViewController(messageVC, animated: false, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        dismissKeyboard()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        if inEditMode {
            
            let alert = UIAlertController(
                title: nil,
                message: "Save changes?",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in
                    self.didSaveEdit()
                    self.changeBarButtonImage(leftButtonLink: self.editLink, rightButtonLink: self.logOutLink)
                    self.sendProfileToDB()})
            
            let cancel = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                dismissViewControllerAnimated(true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError)")
            }
        }
        
    }
    
    struct Profile {
        var name: String
        var birth: String
        var address: String
        var phone: String
        var blood: String
    }
    
    var userProfileBeforeEdit: Profile?
    
    var inEditMode = false
    let saveLink = "profile-save-edit"
    let cancelLink = "profile-cancel-edit"
    let logOutLink = "signout"
    let editLink = "profile-edit"
    
    func changeBarButtonImage(leftButtonLink leftButtonLink: String, rightButtonLink: String) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.transitionWithView(self.editButtonStyle, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                () -> Void in
                self.editButtonStyle.setImage(UIImage(named: leftButtonLink), forState: .Normal)
                }, completion: nil)
            UIView.transitionWithView(self.closeButtonStyle, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                () -> Void in
                self.closeButtonStyle.setImage(UIImage(named: rightButtonLink), forState: .Normal)
                }, completion: nil)
        })
    }
    
    func setPhotoPicker() {
        let tapToAdd = UITapGestureRecognizer(target: self, action: #selector(addNewPhoto))
        profilePhoto.addGestureRecognizer(tapToAdd)
        profilePhoto.userInteractionEnabled = true
        profilePhoto.image = profilePhoto.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        profilePhoto.tintColor = UIColor.whiteColor()
        
        imagePicker.delegate = self
    }
    
    func addNewPhoto() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePhoto.contentMode = .ScaleAspectFill
            profilePhoto.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
            saveToStorage()
        }
    }
    
    func didTapEdit() {
        setTextField(isEditable: true)
        inEditMode = true
    }
    
    func didCancelEdit() {
        nameTextField.text = userProfileBeforeEdit?.name
        birthTextField.text = userProfileBeforeEdit?.birth
        addressTextField.text = userProfileBeforeEdit?.address
        phoneTextField.text = userProfileBeforeEdit?.phone
        bloodTextField.text = userProfileBeforeEdit?.blood
        setTextField(isEditable: false)
        inEditMode = false
    }
    
    func didSaveEdit() {
        defaults.setObject(phoneTextField.text, forKey: "userPhoneNumber")
        setTextField(isEditable: false)
        inEditMode = false
    }
    
    var textFieldBackgroundColor = UIColor.clearColor().CGColor
    var textFieldColor = UIColor.clearColor()
    
    // TODO: combine the functions below as
    // setTextFieldStatus(backgroundColor backgroundColor: CGColor,
    // isEditable: Bool)
    func setTextField(isEditable isEditable: Bool) {
        
        nameTextField.userInteractionEnabled = isEditable
        birthTextField.userInteractionEnabled = isEditable
        addressTextField.userInteractionEnabled = isEditable
        bloodTextField.userInteractionEnabled = isEditable
        phoneTextField.userInteractionEnabled = isEditable
        
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.4, delay: 0, options: .TransitionCrossDissolve, animations: {() -> Void in
                
                if isEditable {
                    self.textFieldBackgroundColor = UIColor.grayColor().CGColor
                    self.textFieldColor = UIColor.whiteColor()
                } else {
                    self.textFieldBackgroundColor = UIColor.clearColor().CGColor
                    self.textFieldColor = UIColor(red: 112/255, green: 110/255, blue: 95/255, alpha: 1.0)
                }
                self.nameTextField.layer.cornerRadius = 5
                self.birthTextField.layer.cornerRadius = 5
                self.addressTextField.layer.cornerRadius = 5
                self.bloodTextField.layer.cornerRadius = 5
                self.phoneTextField.layer.cornerRadius = 5
                self.nameTextField.layer.backgroundColor = self.textFieldBackgroundColor
                self.birthTextField.layer.backgroundColor = self.textFieldBackgroundColor
                self.addressTextField.layer.backgroundColor = self.textFieldBackgroundColor
                self.bloodTextField.layer.backgroundColor = self.textFieldBackgroundColor
                self.phoneTextField.layer.backgroundColor = self.textFieldBackgroundColor
                self.nameTextField.textColor = self.textFieldColor
                self.birthTextField.textColor = self.textFieldColor
                self.addressTextField.textColor = self.textFieldColor
                self.bloodTextField.textColor = self.textFieldColor
                self.phoneTextField.textColor = self.textFieldColor
                
                
                }, completion: nil)
            
        })
        
    }
    
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "556205392726-s6pohtn44l7eqpgmf0qtjq8mp0crt1nd.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeGmailSend]
    
    private let service = GTLRGmailService()
    
    // Firebase
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    // When the view loads, create necessary subviews
    // and initialize the Gmail API service
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.keyboardType = .PhonePad
        if let phone = defaults.stringForKey("userPhoneNumber") {
            phoneTextField.text = phone
        }
        setTextField(isEditable: false)
        trackID.text = AppState.sharedInstance.UUID
        trackID.userInteractionEnabled = true
        profilePhoto.layer.cornerRadius = profilePhoto.layer.frame.width/2
        profilePhoto.clipsToBounds = true
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        connectGmail.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ref = FIRDatabase.database().reference()
        
        setPhotoPicker()
        
        queryProfileFromDB()
        
        downloadFromStorage()
        
        loadDataIndicator.layer.hidden = false
        loadDataIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // When the view appears, ensure that the Gmail API service is authorized
    // and perform API calls
    override func viewWillAppear(animated: Bool) {
        // If user alreay connected
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            connectedStatus.text = "Connected!"
            connectGmail.setTitle(" Disconnect ", forState: .Normal)
            
            if let mail = authorizer.userEmail {
                connectedStatus.text = mail.componentsSeparatedByString("@")[0]
            }
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0 && view.frame.height <= 568 {
                
                var originY: CGFloat = 0.0
                if (phoneTextField.isFirstResponder() ||
                    addressTextField.isFirstResponder()) {
                    originY = (phoneTextField.superview?.superview?.frame.origin.y)!
                    view.frame.origin.y -= (view.frame.height - keyboardSize.height - originY - 70)
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        //        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sendProfileToDB() {
        let databaseChildPath = "user_profiles/\(AppState.sharedInstance.UUID)"
        var data = [Constants.Profile.name : nameTextField.text!]
        data[Constants.Profile.birth] = birthTextField.text!
        data[Constants.Profile.address] = addressTextField.text!
        data[Constants.Profile.blood] = bloodTextField.text!
        data[Constants.Profile.phone] = phoneTextField.text!
        self.ref.child(databaseChildPath).setValue(data)
        print("Profile sent to DB")
    }
    
    var loadIsDone = false
    
    func queryProfileFromDB() {
        let databaseChildPath = "user_profiles/\(AppState.sharedInstance.UUID)"
        
        ref.child(databaseChildPath).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            
            if (snapshot.childrenCount != 0) {
                print("Load profile from DB")
                if let profile = snapshot.value as? [String:String] {
                    self.nameTextField.text = profile[Constants.Profile.name]
                    self.birthTextField.text = profile[Constants.Profile.birth]
                    self.addressTextField.text = profile[Constants.Profile.address]
                    self.bloodTextField.text = profile[Constants.Profile.blood]
                    self.phoneTextField.text = profile[Constants.Profile.phone]
                }
            }
            
            if self.loadIsDone {
                self.loadDataIndicator.layer.hidden = true
                self.loadDataIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            } else {
                self.loadIsDone = true
            }
        })
    }
    
    func saveToStorage() {
        // Points to the root reference
        let storageRef = FIRStorage.storage().referenceForURL("gs://asic-lookout-84de7.appspot.com")
        
        // Points to "images"
        let imagesRef = storageRef.child("profilePhotos")
        
        // Points to "images/space.jpg"
        // Note that you can use variables to create child values
        let fileName = "\(AppState.sharedInstance.UUID)"
        let spaceRef = imagesRef.child(fileName)
        
        guard let imageData = UIImageJPEGRepresentation(profilePhoto.image!, 0.3) else { fatalError() }
        
        let _ = spaceRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                print("Uh-oh, an error occurred!")
            } else {
                print("Image upload to storage")
                let _ = metadata!.downloadURL
            }
        }
    }
    
    func downloadFromStorage() {
        let storageRef = FIRStorage.storage().referenceForURL(AppState.sharedInstance.storage)
        
        storageRef.child("profilePhotos/\(AppState.sharedInstance.UUID)").downloadURLWithCompletion({
            (URL,error) in
            if (error == nil) {
                // SDWebImage
                self.profilePhoto.sd_setImageWithURL(URL)
                self.profilePhoto.contentMode = .ScaleAspectFill
            }
            
            if self.loadIsDone {
                self.loadDataIndicator.layer.hidden = true
                self.loadDataIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            } else {
                self.loadIsDone = true
            }
        })
        
    }
    
    // Creates the auth controller for authorizing access to Gmail API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(ProfileViewController.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Gmail API
    // with the new credentials.
    func viewController(vc : UIViewController, finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        service.authorizer = authResult
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
