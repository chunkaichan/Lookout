//
//  SendAlertViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import Firebase
import GoogleAPIClientForREST
import GTMOAuth2

class SendAlertViewController: TabViewControllerTemplate {
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoncallButton: UIButton!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "556205392726-s6pohtn44l7eqpgmf0qtjq8mp0crt1nd.apps.googleusercontent.com"
    private let service = GTLRGmailService()
    
    override func viewDidLoad() {
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
            print(123)
        }
        
        messageButton.layer.cornerRadius = messageButton.layer.frame.width/2
        messageButton.layer.borderWidth = 2
        messageButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func tapSendEmail(sender: AnyObject) {
        let gtlMessage = GTLRGmail_Message()
        gtlMessage.raw = self.generateRawString()
        
        let query = GTLRGmailQuery_UsersMessagesSend.queryWithObject(gtlMessage, userId: "me", uploadParameters: nil)
        
        service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
            print("ticket \(ticket)")
            print("response \(response)")
            print("error \(error)")
            
        })
        
    }
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    
    func generateRawString() -> String {
//    func generateRawString(toMailName toMailName: String, toMailAddress: String, mailSubject: String, fromLocation: String) -> String {
        
//        let dateFormatter:NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
//        let todayString:String = dateFormatter.stringFromDate(NSDate())
        let fromLocationURL = "http://maps.google.com/maps?q=loc:36.26577,-92.54324"
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "Emergency contact", mailbox: "kyle791121@gmail.com")]
        builder.header.from = MCOAddress(displayName: "From Lookout: Emergency Notification", mailbox: "kyle791121@gmail.com")
        builder.header.subject = "Subject"
        builder.htmlBody = "This is a test msg" + "<br><br>" +
                           "\(fromLocationURL)"
        
        builder.header.date = NSDate()
        
        //
        let rfc822Data = builder.data()
        
        
        
        return GTLREncodeWebSafeBase64(rfc822Data)!
    }
    
}
