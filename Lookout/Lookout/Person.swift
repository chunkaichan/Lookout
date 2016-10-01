//
//  Person.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/26.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation

class Person {
    
    let name: String
    let phoneNumber: String
    let trackID: String
    let email: String
//    let photo: NSdata
    
    init(name: String, phoneNumber: String, trackID: String, email: String) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.trackID = trackID
        self.email = email
        
    }
    
}