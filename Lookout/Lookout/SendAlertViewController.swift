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
        var gtlMessage = GTLRGmail_Message()
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
        
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        var todayString:String = dateFormatter.stringFromDate(NSDate())
        
        var rawMessage = "" +
            "Date: \(todayString)\r\n" +
            "From: kyle791121@gmail.com\r\n" +
            "To: username kyle791121@gmail.com\r\n" +
            "Subject: Test send email\r\n\r\n" +
        "Test body"
        
        print("message \(rawMessage)")
        return GTLREncodeWebSafeBase64(rawMessage.dataUsingEncoding(NSUTF8StringEncoding))!
    }
    
}
