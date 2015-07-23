//
//  TableViewController.swift
//  empty Contact
//
//  Created by yiplee on 6/24/15.
//  Copyright © 2015 wingringring. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class TableViewController: UITableViewController {
  
  let cellIdentifier : String = "contact"
  
  @IBAction func clear(sender: UIBarButtonItem) {
    var count = 0
    
    for person in contacts! {
      let phones : ABMultiValueRef? = ABRecordCopyValue(person,kABPersonPhoneProperty)?.takeUnretainedValue()
      let phonesCount = ABMultiValueGetCount(phones) as Int
      if phonesCount == 0 {
        count += 1
      }
    }
    
    let message = (count == 0) ? "所有联系人都有电话" : "有\(count)个联系人没有电话"
    let style   = (count == 0) ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet
    let alert   = UIAlertController(title: nil, message: message, preferredStyle: style)
    
    if (style == .ActionSheet) {
      let removeAction = UIAlertAction(title: "移除", style: .Destructive, handler: { (action) -> Void in
        self.clearAction()
      })
      alert.addAction(removeAction)
      
      let ppc = alert.popoverPresentationController
      ppc?.sourceView = self.view
      ppc?.barButtonItem = self.navigationItem.rightBarButtonItem
    }
    
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
    alert.addAction(cancelAction)
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  private func clearAction() {
    
    let indexSet = NSMutableIndexSet()
    var indexPaths : [NSIndexPath] = []
    
    var index = 0
    for person in contacts! {
      let phones : ABMultiValueRef? = ABRecordCopyValue(person,kABPersonPhoneProperty)?.takeUnretainedValue()
      let phonesCount = ABMultiValueGetCount(phones) as Int
      if phonesCount == 0 {
        indexSet.addIndex(index)
        indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
        
        let person = contacts?.objectAtIndex(index)
        ABAddressBookRemoveRecord(addressBook, person, nil)
      }
      
      index++
    }
    
    contacts?.removeObjectsAtIndexes(indexSet)
    
    self.tableView.beginUpdates()
    self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    self.tableView.endUpdates()
    
    ABAddressBookSave(addressBook, nil)
    
    let alert = UIAlertController(title: nil, message: "共移除\(indexSet.count)个联系人", preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(cancelAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  lazy var addressBook : ABAddressBookRef? = {
    var error : Unmanaged<CFError>?
    return ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
  }()
  
  lazy var contacts : NSMutableArray? = {
    let array : NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
    return array.mutableCopy() as? NSMutableArray
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
//    self.clearsSelectionOnViewWillAppear = false
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (contacts?.count)!
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
    
    let row = indexPath.row
    
    let person = contacts?.objectAtIndex(row)
    
    let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeUnretainedValue() as? NSString ?? ""
    let lastName  = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeUnretainedValue()  as? NSString ?? ""
    let seperate = lastName.length > 0 ? " " : ""
    cell.textLabel?.text = "\(lastName)\(seperate)\(firstName)"
    
    // phone
    let phones : ABMultiValueRef? = ABRecordCopyValue(person,kABPersonPhoneProperty)?.takeUnretainedValue()
    
    if let count : Int = ABMultiValueGetCount(phones) where count == 0 {
      cell.detailTextLabel?.text = "没有电话"
      cell.detailTextLabel?.textColor = UIColor.redColor()
    } else {
      let phone  = ABMultiValueCopyValueAtIndex(phones,0).takeUnretainedValue()
      cell.detailTextLabel?.text = "\(phone)"
      cell.detailTextLabel?.textColor = UIColor.orangeColor()
    }
    
    return cell
  }

  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
    return true
  }

  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if editingStyle == .Delete {
      let person = contacts?.objectAtIndex(indexPath.row)
      contacts?.removeObjectAtIndex(indexPath.row)
      ABAddressBookRemoveRecord(addressBook, person, nil)
      ABAddressBookSave(addressBook, nil)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let person = contacts?.objectAtIndex(indexPath.row)
    
    let detail = ABPersonViewController()
    detail.addressBook = addressBook
    detail.displayedPerson = person!
    detail.allowsEditing = true
    
    self.showViewController(detail, sender: self)
  }
}
