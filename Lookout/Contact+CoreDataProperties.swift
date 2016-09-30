//
//  Contact+CoreDataProperties.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/30.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var name: String?
    @NSManaged var number: String?
    @NSManaged var email: String?
    @NSManaged var trackID: String?

}
