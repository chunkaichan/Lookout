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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var connectGmail: UIButton!
    
    @IBOutlet weak var connectedStatus: UILabel!
    
    @IBAction func connectGmail(sender: AnyObject) {
        
        if (self.connectGmail.titleLabel?.text == " Connect ") {
            // Connect with Gmail
            self.navigationController?.pushViewController(createAuthController(), animated: true)
            print(self.navigationController?.navigationItem.rightBarButtonItem?.title)
            print("pushed")
        } else {
            // Disconnect
            GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName("Gmail API")
            self.connectGmail.setTitle(" Connect ", forState: .Normal)
            self.connectedStatus.text = "Not connected"
            print("Auth removed")
        }
        
        
    }
    
    
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "556205392726-s6pohtn44l7eqpgmf0qtjq8mp0crt1nd.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeGmailSend]
    
    private let service = GTLRGmailService()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Gmail API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        
        connectGmail.layer.cornerRadius = 5
        
        
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
//        dismissViewControllerAnimated(true, completion: nil)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
