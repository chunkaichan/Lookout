//
//  ContactsViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ContactsViewController: TabViewControllerTemplate, UITableViewDataSource, UITableViewDelegate, CoreDataManagerDelegate {

    @IBOutlet weak var contactsTable: UITableView!
    
    let coreDataManager = CoreDataManager.shared
    
    // Firebase
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ContactTableViewXib", bundle: nil)
        contactsTable.registerNib(nib, forCellReuseIdentifier: "ContactTableViewCell")
        contactsTable.dataSource = self
        contactsTable.delegate = self
        
        
        ref = FIRDatabase.database().reference()
        queryContactsFromDB()
    }
    
    override func viewDidAppear(animated: Bool) {
        contacts = []
        
        coreDataManager.delegate = self
        coreDataManager.fetchCoreData()
    }
    
    enum ContactRow: Int {
        case name, phoneNumber, address
    }
    
    var rows: [ContactRow] = [
        ContactRow.name,
        ContactRow.phoneNumber,
        ContactRow.address
    ]
    
    typealias ContactForTable = Person
    
    
    var trackID: String = ""
    var name: String = ""
    var number: String = ""
    // [Section]
    var contacts: [ContactForTable] = []
    
    // Mark: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = contactsTable.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath:indexPath) as! ContactTableViewCell
        cell.contactName.text = contact.name
        cell.contactNumber.text = contact.phoneNumber
        cell.contactPhoto.image = UIImage(data: contact.photo!)
        cell.contactPhoto.contentMode = .ScaleAspectFill
        cell.contactPhoto.layer.cornerRadius = cell.contactPhoto.frame.size.width/2
        cell.contactPhoto.clipsToBounds = true
        cell.contactMail.text = contact.email
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.trackID = contacts[indexPath.row].trackID
        self.name = contacts[indexPath.row].name
        self.number = contacts[indexPath.row].phoneNumber
        performSegueWithIdentifier("SegueContactMap", sender: [])
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            contacts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            coreDataManager.clearCoreData()
            for contact in contacts {
                coreDataManager.saveCoreData(name: contact.name, number: contact.phoneNumber, email: contact.email, trackID: contact.trackID, photo: contact.photo!)
            }
            
        }
    }
    
    // Mark: Prepare segue for adding contact
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueContactMap" {
            let destination: ContactsMapViewController = segue.destinationViewController as! ContactsMapViewController
            destination.trackID = self.trackID
            destination.navigationItem.title = self.name
            destination.contactNumber = self.number
            print(number)
        }
    }
    
    // Mark: CoreDataManager delegate
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {
        guard let results = didFetchContactData as? [Contact] else { fatalError() }
        if (results.count > 0) {
            for result in results {
                if let temp = result.photo {
                        contacts.append(ContactForTable(name: result.name!, phoneNumber: result.number!, trackID: result.trackID!, email: result.email!, photo: temp))
                }

            }
        }
        self.contactsTable.reloadData()
    }
    
    
    // Mark: get contacts info from DB
    func queryContactsFromDB() {
        _refHandle = self.ref.child("user_contacts").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            if let contactsDictionary = snapshot.value as? [String: [String:Bool]] {
                
                let keyArray = Array(contactsDictionary.keys)
                let currentDeviceID = AppState.sharedInstance.UUID
                
                let currentDeviceContacts = contactsDictionary[currentDeviceID] ?? ["NO CONTACTS": true]
                
                var alreadyAddedAsContact = false
                
                for key in keyArray { // key == remote device ID
                    if (currentDeviceContacts[key] == true) { // check if current device has added remote device as a contact
                        alreadyAddedAsContact = true
                    }
                    
                    var remoteDeviceContacts = contactsDictionary[key]!
                    if (remoteDeviceContacts[AppState.sharedInstance.UUID] == true && !alreadyAddedAsContact) {
                        // if remote device add current device as contact, show alert
                        self.showAlert(remoteUID: key)
                    }
                    
                    
                }
                
            }
        })
    }
    
    func showAlert(remoteUID remoteUID: String) {
        let alert = UIAlertController(
            title: nil,
            message: "<\(remoteUID)> wants to set you as a contact",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "Confirm",
            style: UIAlertActionStyle.Default,
            handler: {(alert: UIAlertAction!) in
                self.confirmContactToDatabase(remoteUID: remoteUID)
            }
        )
        let cancel = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(cancel)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func confirmContactToDatabase(remoteUID remoteUID: String) {
        let databaseContactPath = "user_contacts/\(AppState.sharedInstance.UUID)/"
        print(AppState.sharedInstance.UUID)
        print(databaseContactPath)
        let data = [remoteUID : true]
        self.ref.child(databaseContactPath).updateChildValues(data)
        print("Contact \(remoteUID) is set to be true.")
    }

}