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
    
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ContactTableViewXib", bundle: nil)
        contactsTable.registerNib(nib, forCellReuseIdentifier: "ContactTableViewCell")
        contactsTable.dataSource = self
        contactsTable.delegate = self
        
        coreDataManager.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        contacts = [ContactForTable(name: "Kyle", phoneNumber: "0987654321", trackID: "GLDkDlzgYJSxc7MVIyNfnL5TdXc2", email: "email@com.tw")]
        
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.trackID = contacts[indexPath.row].trackID
        self.name = contacts[indexPath.row].name
        performSegueWithIdentifier("SegueContactMap", sender: [])
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            contacts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            coreDataManager.clearCoreData()
            for contact in contacts {
                coreDataManager.saveCoreData(name: contact.name, number: contact.phoneNumber, email: contact.email, trackID: contact.trackID)
            }
            
        }
    }
    
    // Mark: Prepare segue for adding contact
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueContactMap" {
            let destination: ContactsMapViewController = segue.destinationViewController as! ContactsMapViewController
            destination.trackID = self.trackID
            destination.navigationItem.title = self.name
            print(self.trackID)
        }
    }
    
    // Mark: CoreDataManager delegate
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {
        print(didFetchContactData)
        guard let results = didFetchContactData as? [Contact] else { fatalError() }
        if (results.count > 0) {
            for result in results {
                contacts.append(ContactForTable(name: result.name!, phoneNumber: result.number!, trackID: result.trackID!, email: result.email!))
            }
        }
        self.contactsTable.reloadData()
    }

}