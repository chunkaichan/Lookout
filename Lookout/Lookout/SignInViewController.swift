//
//  SignInViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/27.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics

extension SignInViewController: AKFViewControllerDelegate{
 
    func viewController(viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("didCompleteLoginWithAuthorizationCode")
    }
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        print("didCompleteLoginWithAccessToken")
        accountKit.requestAccount {
            (account, error) in
            if let phoneNumber = account?.phoneNumber?.stringRepresentation() {
                self.signUpAccount(email: "\(phoneNumber)@lookout.com", password: phoneNumber)
                self.signInAccount(email: "\(phoneNumber)@lookout.com", password: phoneNumber)
                self.defaults.setObject(phoneNumber, forKey: "userPhoneNumber")
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

    var accountKit: AKFAccountKit!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func loginWithPhone(sender: UIButton) {
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "User registration" as NSObject,
            kFIRParameterItemID: "0" as NSObject
            ])
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
        }
        
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
            AppState.sharedInstance.UUID = user.uid
            AppState.sharedInstance.email = user.email!
        }
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
        
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        
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
