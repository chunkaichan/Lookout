//
//  SignInViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/27.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase

extension SignInViewController: AKFViewControllerDelegate{
 
    func viewController(viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("didCompleteLoginWithAuthorizationCode")
        accountKit.requestAccount {
            (account, error) in
            if let phoneNumber = account?.phoneNumber?.stringRepresentation() {
                print(phoneNumber)
                
            }
        }
    }
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        print("didCompleteLoginWithAccessToken")
        accountKit.requestAccount {
            (account, error) in
            if let phoneNumber = account?.phoneNumber?.stringRepresentation() {
                print(phoneNumber)
            }
        }
    }
    
    func viewController(viewController: UIViewController!, didFailWithError error: NSError!) {
        print("didFailWithError")
    }
    
    func viewControllerDidCancel(viewController: UIViewController!) {
        print("viewControllerDidCancel")
    }
    
}

class SignInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var accountKit: AKFAccountKit!
    
    @IBAction func loginWithPhone(sender: UIButton) {
        
        if let accountKitPhoneLoginVC: AKFViewController = accountKit.viewControllerForPhoneLoginWithPhoneNumber(nil, state: nil) as? AKFViewController {
            
            accountKitPhoneLoginVC.enableSendToFacebook = true
            
            accountKitPhoneLoginVC.delegate = self
            
            presentViewController(accountKitPhoneLoginVC as! UIViewController, animated: true, completion: nil)
            
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        
        if accountKit == nil {
            // may also specify AKFResponseTypeAccessToken
            self.accountKit = AKFAccountKit(responseType: AKFResponseType.AccessToken)
            print("nilrrrr")
        }
        
//        if let user = FIRAuth.auth()?.currentUser {
//            self.signedIn(user)
//            AppState.sharedInstance.UUID = user.uid
//            AppState.sharedInstance.email = user.email!
//        }
    }
    
    func signInAccount(email email: String, password: String) {
        // Sign In with credentials.
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.signedIn(user!)
            AppState.sharedInstance.UUID = user!.uid
        }
    }
    
    func signUpAccount(email email: String, password: String) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.setDisplayName(user!)
            AppState.sharedInstance.UUID = user!.uid
        }
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        // Sign In with credentials.
        let email = emailField.text
        let password = passwordField.text
        signInAccount(email: email!, password: password!)
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        signUpAccount(email: email!, password: password!)
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
