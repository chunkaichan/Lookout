//
//  Person.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/26.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation

class Person {
    
    var name: String
    var phoneNumber: String
    var trackID: String
    var email: String
    var photo: NSData?
    
    init(name: String, phoneNumber: String, trackID: String, email: String, photo: NSData) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.trackID = trackID
        self.email = email
        self.photo = photo
        
    }
    
}