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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bloodTextField: UITextField!
    @IBOutlet weak var trackID: UILabel!
    
    @IBOutlet weak var connectGmail: UIButton!
    @IBOutlet weak var connectedStatus: UILabel!
    
    @IBAction func connectGmail(sender: AnyObject) {
        if (self.connectGmail.titleLabel?.text == " Connect ") {
            // Connect with Gmail
            self.navigationController?.pushViewController(createAuthController(), animated: true)
        } else {
            // Disconnect
            GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName("Gmail API")
            self.connectGmail.setTitle(" Connect ", forState: .Normal)
            self.connectedStatus.text = " Not connected "
        }
        
    }
    
    @IBOutlet weak var closeButtonStyle: UIButton!
    @IBOutlet weak var editButtonStyle: UIButton!
    
    @IBAction func editButton(sender: AnyObject) {
        if (inEditMode) {
            // tap to cancel
            let alert = UIAlertController(
                title: nil,
                message: "Discard changes?",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in
                    self.didCancelEdit()
                    self.changeBarButtonImage(leftButtonLink: self.editLink, rightButtonLink: self.closeLink)
                }
            )
            let cancel = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Default,
                handler: nil
            )
            alert.addAction(cancel)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            // tap to edit
            userProfileBeforeEdit = Profile(name: nameTextField.text ?? "Empty" ,
                                  birth: birthTextField.text ?? "Empty" ,
                                  address: addressTextField.text ?? "Empty" ,
                                  phone: phoneTextField.text ?? "Empty" ,
                                  blood: bloodTextField.text ?? "Empty")
            didTapEdit()
            changeBarButtonImage(leftButtonLink: cancelLink, rightButtonLink: saveLink)
            inEditMode = true
        }
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        if (inEditMode) {
            // tap to save
            let alert = UIAlertController(
                title: nil,
                message: "Save changes?",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in
                    self.didSaveEdit()
                    self.changeBarButtonImage(leftButtonLink: self.editLink, rightButtonLink: self.closeLink)
                    self.sendProfileToDB()
                }
            )
            let cancel = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Default,
                handler: nil
            )
            alert.addAction(cancel)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
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
    let closeLink = "close"
    let editLink = "profile-edit"
    
    func changeBarButtonImage(leftButtonLink leftButtonLink: String, rightButtonLink: String) {
        editButtonStyle.setImage(UIImage(named: leftButtonLink), forState: .Normal)
        closeButtonStyle.setImage(UIImage(named: rightButtonLink), forState: .Normal)
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
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePhoto.contentMode = .ScaleAspectFill
            profilePhoto.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
            saveToStorage()
        }
    }
    
    func didTapEdit() {
        setTextFieldGray()
    }
    
    func didCancelEdit() {
        nameTextField.text = userProfileBeforeEdit?.name
        birthTextField.text = userProfileBeforeEdit?.birth
        addressTextField.text = userProfileBeforeEdit?.address
        phoneTextField.text = userProfileBeforeEdit?.phone
        bloodTextField.text = userProfileBeforeEdit?.blood
        setTextFieldTransparent()
        inEditMode = false
    }
    
    func didSaveEdit() {
        setTextFieldTransparent()
        inEditMode = false
    }
    
    func setTextFieldGray() {
        nameTextField.layer.backgroundColor = UIColor.grayColor().CGColor
        nameTextField.layer.cornerRadius = 5
        birthTextField.layer.backgroundColor = UIColor.grayColor().CGColor
        birthTextField.layer.cornerRadius = 5
        addressTextField.layer.backgroundColor = UIColor.grayColor().CGColor
        addressTextField.layer.cornerRadius = 5
        bloodTextField.layer.backgroundColor = UIColor.grayColor().CGColor
        bloodTextField.layer.cornerRadius = 5
        phoneTextField.layer.backgroundColor = UIColor.grayColor().CGColor
        phoneTextField.layer.cornerRadius = 5
        setTextFieldEditable(isEditable: true)
    }
    
    func setTextFieldTransparent() {
        nameTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        birthTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        addressTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        bloodTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        phoneTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        setTextFieldEditable(isEditable: false)
    }
    
    func setTextFieldEditable(isEditable isEditable: Bool) {
        nameTextField.userInteractionEnabled = isEditable
        birthTextField.userInteractionEnabled = isEditable
        addressTextField.userInteractionEnabled = isEditable
        phoneTextField.userInteractionEnabled = isEditable
        phoneTextField.userInteractionEnabled = isEditable
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
    
    // When the view loads, create necessary subviews
    // and initialize the Gmail API service
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldEditable(isEditable: false)
        trackID.text = AppState.sharedInstance.UUID
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
        
        
    }
    
    // When the view appears, ensure that the Gmail API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        // If user alreay connected
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            connectedStatus.text = "Connected!"
            connectGmail.setTitle(" Disconnect ", forState: .Normal)
        }
    }
    
    let databaseChildPath = "user_profiles/\(AppState.sharedInstance.UUID)"
    
    func sendProfileToDB() {
        var data = [Constants.Profile.name : nameTextField.text!]
        data[Constants.Profile.birth] = birthTextField.text!
        data[Constants.Profile.address] = addressTextField.text!
        data[Constants.Profile.blood] = bloodTextField.text!
        data[Constants.Profile.phone] = phoneTextField.text!
        self.ref.child(databaseChildPath).setValue(data)
        print("Profile sent to DB")
    }
    
    func queryProfileFromDB() {
        _refHandle = self.ref.child(databaseChildPath).observeEventType(.Value, withBlock: { (snapshot) -> Void in
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
        })
    }
    
    func saveToStorage() {
        // Points to the root reference
        let storageRef = FIRStorage.storage().referenceForURL("gs://lookout-ea551.appspot.com")
        
        // Points to "images"
        let imagesRef = storageRef.child("profilePhotos")
        
        // Points to "images/space.jpg"
        // Note that you can use variables to create child values
        let fileName = "\(AppState.sharedInstance.UUID)"
        let spaceRef = imagesRef.child(fileName)
        
        guard let imageData = UIImageJPEGRepresentation(profilePhoto.image!, 0.5) else { fatalError() }
        
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
        let storageRef = FIRStorage.storage().referenceForURL("gs://lookout-ea551.appspot.com")
        
        // Create a reference to the file you want to download
        let profileImageRef = storageRef.child("profilePhotos/\(AppState.sharedInstance.UUID)")
        profileImageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                if let data = data {
                    print("Load profile photo from storage")
                    self.profilePhoto.image = UIImage(data: data)
                    self.profilePhoto.contentMode = .ScaleAspectFill
                }
            }
        }
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
