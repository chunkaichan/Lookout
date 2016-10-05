//
//  SignInViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/27.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
            AppState.sharedInstance.UUID = user.uid
            AppState.sharedInstance.email = user.email!
        }
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        // Sign In with credentials.
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.signedIn(user!)
            AppState.sharedInstance.UUID = user!.uid
        }
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.setDisplayName(user!)
            AppState.sharedInstance.UUID = user!.uid
        }
    }
    
    func setDisplayName(user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func signedIn(user: FIRUser?) {
//        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        performSegueWithIdentifier(Constants.Segues.SignInToFp, sender: nil)
    }
}
