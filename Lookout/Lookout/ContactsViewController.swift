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
        coreDataManager.clearCoreData()
    }
    
    override func viewWillAppear(animated: Bool) {
        contacts = [ContactForTable(name: "Kyle", phoneNumber: "0987654321", trackID: "GLDkDlzgYJSxc7MVIyNfnL5TdXc2")]
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
        performSegueWithIdentifier("SegueContactMap", sender: [])
    }
    
    // Mark: Prepare segue for adding contact
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueContactMap" {
            let destination: ContactsMapViewController = segue.destinationViewController as! ContactsMapViewController
            destination.trackID = self.trackID
            print(self.trackID)
        }
    }
    
    // Mark: CoreDataManager delegate
    func manager(manager: CoreDataManager, didFetchContactData: AnyObject) {
        print(didFetchContactData)
        guard let results = didFetchContactData as? [Contact] else { fatalError() }
        if (results.count > 0) {
            for result in results {
                contacts.append(ContactForTable(name: result.name!, phoneNumber: result.number!, trackID: result.trackID!))
            }
        }
        self.contactsTable.reloadData()
    }

}