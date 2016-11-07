//
//  DatabaseManager.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/11/7.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation
import Firebase

protocol DatabaseManagerDelegate: class {
    func didReadData(manager: DatabaseManager, didReadData: FIRDataSnapshot)
}

class DatabaseManager {
    
    var ref: FIRDatabaseReference!
    var _refHandle: FIRDatabaseHandle!
    
    weak var delegate: DatabaseManagerDelegate?
    
    enum ObserveType {
        case Events
        case Single
    }
    
    enum DataType {
        case Profile
        case Coordinate
    }

    func readDataFromDatabase(destinationPath destinationPath: String, observeType: ObserveType ) {
        ref = FIRDatabase.database().reference()
        
        switch observeType {
        case .Single:
            ref.child(destinationPath).observeSingleEventOfType(.Value, withBlock: { (snapShot) in
                self.delegate?.didReadData(self, didReadData: snapShot)
            })
        case .Events:
            print("events type observation")
        }
        
    }
    
    func sendDataToDatabase(destinationPath destinationPath: String, dataType: DataType, data: NSDictionary) {
        
        switch dataType {
        case .Profile:
            print(data)
        case .Coordinate:
            print("coordinate type")
        }
    }
    
}