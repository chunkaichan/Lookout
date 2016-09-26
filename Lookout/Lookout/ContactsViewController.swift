//
//  ContactsViewController.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/23.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import UIKit

class ContactsViewController: TabViewControllerTemplate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contactsTable: UITableView!
    
    @IBAction func toggleSetting(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ContactTableViewXib", bundle: nil)
        contactsTable.registerNib(nib, forCellReuseIdentifier: "ContactTableViewCell")
        contactsTable.dataSource = self
        contactsTable.delegate = self
        
    }
    enum ContactRow: Int {
        case name, phoneNumber, address
    }
    
    var rows: [ContactRow] = [
        ContactRow.name,
        ContactRow.phoneNumber,
        ContactRow.address
    ]
    
    typealias Contact = Person
    
    // [Section]
    var contacts: [Contact] = [
        Contact(name: "Kyle", phoneNumber: "0987654321", address: "Taipei"),
        Contact(name: "Hi", phoneNumber: "1234567890", address: "Taipei"),
    ]
    
    
    
    
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

}