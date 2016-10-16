//
//  EventCoreDataManager.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/10/16.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation
import CoreData

protocol EventCoreDataManagerDelegate: class {
    func manager(manager: EventCoreDataManager, didSaveEventData: AnyObject)
    func manager(manager: EventCoreDataManager, getFetchEventError: ErrorType)
    func manager(manager: EventCoreDataManager, didFetchEventData: AnyObject)
}

extension EventCoreDataManager {
    func manager(manager: EventCoreDataManager, didSaveEventData: AnyObject) {}
    func manager(manager: EventCoreDataManager, getFetchEventError: ErrorType) {}
    func manager(manager: EventCoreDataManager, didFetchEventData: AnyObject) {}
}

class EventCoreDataManager {
    
    static let shared = EventCoreDataManager()
    
    private init() {
        
    }
    
    private let entityName = "Events"
    
    private var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    weak var delegate: EventCoreDataManager?
    
    func saveCoreData(time time: NSDate, data: [Double], latitude: Double, longitude: Double, isAccident: Bool?) {
        let event = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as! Events
        event.time = time
        event.data = data
        event.latitude = latitude
        event.longitude = longitude
        event.isAccident = isAccident
        do {
            try self.moc.save()
            print("Save new event to core data.")
        } catch {
            fatalError("Error occurs while saving an event.")
        }
    }
    
    func fetchCoreData() {
        let request = NSFetchRequest(entityName: entityName)
        do {
            guard let results = try moc.executeFetchRequest(request) as? [Events] else {fatalError()}
            delegate?.manager(self, didFetchEventData: results)
        } catch {
            delegate?.manager(self, getFetchEventError: error)
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
            print("Clear events core data")
        } catch let error as NSError {
            print(error)
        }
    }
}