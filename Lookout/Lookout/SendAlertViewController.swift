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
    
    
    @IBAction func tapSendEmail(sender: AnyObject) {
        let gtlMessage = GTLRGmail_Message()
        gtlMessage.raw = self.generateRawString()
        
        let appd = UIApplication.sharedApplication().delegate as! AppDelegate
        let query = GTLRGmailQuery_UsersMessagesSend.queryWithObject(gtlMessage, userId: "me", uploadParameters: nil)
        
        appd.service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
            print("ticket \(ticket)")
            print("response \(response)")
            print("error \(error)")
            
        })
        
    }
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    
    func generateRawString() -> String {
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        let todayString:String = dateFormatter.stringFromDate(NSDate())
        let fromLocationURL = "http://maps.google.com/maps?q=loc:36.26577,-92.54324"
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "Emergency contact", mailbox: "kyle791121@gmail.com")]
        builder.header.from = MCOAddress(displayName: "From Lookout: Emergency Notification", mailbox: "kyle791121@gmail.com")
        builder.header.subject = "Subject"
        builder.htmlBody = "This is a test msg" + "\r\n" +
                           "From location:http://maps.google.com/maps?q=loc:36.26577,-92.54324"
        builder.header.date = NSDate()
        
        //
        let rfc822Data = builder.data()
        
        
        
        return GTLREncodeWebSafeBase64(rfc822Data)!
    }
    
}
