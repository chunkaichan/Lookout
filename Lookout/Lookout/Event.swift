//
//  Event.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/16.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation

class Event {
    
    let time: NSDate
    let data: [Double]
    let latitude: Double
    let longitude: Double
    let isAccident: Bool?
    //    let photo: NSdata
    
    init(time: NSDate, data: [Double], latitude: Double, longitude: Double, isAccident: Bool?) {
        
        self.time = time
        self.data = data
        self.latitude = latitude
        self.longitude = longitude
        self.isAccident = isAccident
        
    }
    
}