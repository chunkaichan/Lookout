//
//  CoreDataManager.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/30.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagerDelegate: class {
    func manager(manager: CoreDataManager, didSaveContactData: AnyObject)
    func manager(manager: CoreDataManager, getFetchContactError: ErrorType)
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject)
}

extension CoreDataManagerDelegate {
    func manager(manager: CoreDataManager, didSaveContactData: AnyObject) {}
    func manager(manager: CoreDataManager, getFetchContactError: ErrorType) {}
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {}
}

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {
        
    }
    
    private let entityName = "Contacts"
    
    private var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    weak var delegate: CoreDataManagerDelegate?
    
    func saveCoreData(name name: String, number: String, email: String, trackID: String, photo: NSData) {
        let contact = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as! Contact
        contact.name = name
        contact.number = number
        contact.email = email
        contact.trackID = trackID
        contact.photo = photo
        do {
            try self.moc.save()
            print("Save new contact info to core data")
        } catch {
            fatalError("Error occurs while saving core data")
        }
    }
    
    func fetchCoreData() {
        let request = NSFetchRequest(entityName: entityName)
        do {
            guard let results = try moc.executeFetchRequest(request) as? [Contact] else {fatalError()}
            delegate?.manager(self, didFetchContactData: results)
        } catch {
            delegate?.manager(self, getFetchContactError: error)
        }
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
            print("Clear core data")
        } catch let error as NSError {
            print(error)
        }
    }
}