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
import LocalAuthentication

extension SignInViewController: AKFViewControllerDelegate{
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("didCompleteLoginWithAuthorizationCode")
    }
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        print("didCompleteLoginWithAccessToken")
        didLoginAccountkit = true
        
        self.activityIndicatorView.layer.hidden = false
        self.activityIndicatorView.startAnimating()
        
        accountKit.requestAccount {
            (account, error) in
            if let phoneNumber = account?.phoneNumber?.stringRepresentation() {
                if (phoneNumber != "") {
                    self.signUpAccount(email: "\(phoneNumber)@lookout.com", password: phoneNumber)
                    self.signInAccount(email: "\(phoneNumber)@lookout.com", password: phoneNumber)
                    self.defaults.setObject(phoneNumber, forKey: "userPhoneNumber")
                }
            }
            if let emailAddress = account?.emailAddress {
                let account = emailAddress
                let accountKey = emailAddress.componentsSeparatedByString("@")[0]
                self.signUpAccount(email: account, password: accountKey)
                self.signInAccount(email: account, password: accountKey)
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

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var accountKit: AKFAccountKit!
    let defaults = NSUserDefaults.standardUserDefaults()
    var didLoginAccountkit = false
    
    @IBOutlet weak var loginButtonStyle: UIButton!
    @IBOutlet weak var loginMailButtonStyle: UIButton!
    @IBOutlet weak var loginLabelStyle: UILabel!
    
    @IBAction func loginWithEmail(sender: UIButton) {
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "User registration" as NSObject,
            kFIRParameterItemID: "Email" as NSObject
            ])
        
        if let accountKitEmailLoginVC: AKFViewController = accountKit.viewControllerForEmailLoginWithEmail(nil, state: nil) as? AKFViewController {
            
            accountKitEmailLoginVC.enableSendToFacebook = true
            
            accountKitEmailLoginVC.delegate = self
            
            presentViewController(accountKitEmailLoginVC as! UIViewController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func loginWithPhone(sender: UIButton) {
        
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "User registration" as NSObject,
            kFIRParameterItemID: "PhoneNumber" as NSObject
            ])
        
        if let accountKitPhoneLoginVC: AKFViewController = accountKit.viewControllerForPhoneLoginWithPhoneNumber(nil, state: nil) as? AKFViewController {
            
            accountKitPhoneLoginVC.enableSendToFacebook = true
            
            accountKitPhoneLoginVC.delegate = self
            
            presentViewController(accountKitPhoneLoginVC as! UIViewController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        if didLoginAccountkit {
            loginButtonStyle.layer.hidden = true
            loginMailButtonStyle.layer.hidden = true
            loginLabelStyle.layer.hidden = true
            activityIndicatorView.layer.hidden = false
            activityIndicatorView.startAnimating()
        } else {
            loginButtonStyle.layer.hidden = false
            loginMailButtonStyle.layer.hidden = false
            loginLabelStyle.layer.hidden = false
            activityIndicatorView.layer.hidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if accountKit == nil {
            // may also specify AKFResponseTypeAccessToken
            self.accountKit = AKFAccountKit(responseType: AKFResponseType.AccessToken)
        }
        
        if let user = FIRAuth.auth()?.currentUser {
            loginButtonStyle.layer.hidden = true
            loginMailButtonStyle.layer.hidden = true
            loginLabelStyle.layer.hidden = true
            activityIndicatorView.layer.hidden = false
            activityIndicatorView.startAnimating()
            self.signedIn(user)
            AppState.sharedInstance.UUID = user.uid
            AppState.sharedInstance.email = user.email!
        }
        
        UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
        UIApplication.sharedApplication().keyWindow?.rootViewController = self
        loginButtonStyle.translatesAutoresizingMaskIntoConstraints = true
        
        
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
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        performSegueWithIdentifier(Constants.Segues.SignInToFp, sender: nil)
        didLoginAccountkit = false
    }
}
