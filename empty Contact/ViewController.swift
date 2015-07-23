//
//  ViewController.swift
//  empty Contact
//
//  Created by yiplee on 6/24/15.
//  Copyright © 2015 wingringring. All rights reserved.
//

import UIKit

import AddressBook

class ViewController: UIViewController {

  @IBOutlet weak var contactButton: UIButton!
  
  @IBOutlet weak var messageLabel: UILabel!
  
  var addressBook : ABAddressBookRef?
  var authorizationStatus : ABAuthorizationStatus = .NotDetermined
  
  // dealloc
  deinit {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.view.backgroundColor = UIColor.whiteColor()
  }
  
  override func didMoveToParentViewController(parent: UIViewController?) {
    self.refreshStatus()
  }
  
  private func refreshStatus() {
    
    authorizationStatus = ABAddressBookGetAuthorizationStatus()
    
    if (authorizationStatus == .Denied || authorizationStatus == .Restricted) {
      contactButton.enabled = false
      messageLabel.hidden = false
    } else if (authorizationStatus == .Authorized) {
      contactButton.enabled = true
      messageLabel.hidden = true
    } else if (authorizationStatus == .NotDetermined) {
      contactButton.enabled = false
      messageLabel.hidden = true
      
      var error : Unmanaged<CFError>?
      addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
      
      ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.refreshStatus()
        })
      })
    }
  }

  @IBAction func enter(sender: UIButton) {
    self.performSegueWithIdentifier("contacts", sender: sender)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

