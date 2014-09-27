//
//  BaseViewController.swift
//  contacts
//
//  Created by lancy on 27/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - User Info
    
    func isLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("isLogin")
    }
    
    func setLogin(toggle: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(toggle, forKey: "isLogin")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: - Private Alert Utils
    
    func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private var loadingAlert: UIAlertController?
    
    func showLoadingAlert() {
        if (loadingAlert == nil) {
            loadingAlert = UIAlertController(title: "Loading...", message: "", preferredStyle: .Alert)
            self.presentViewController(loadingAlert!, animated: false, completion: nil)
        }
    }
    
    func hideLoadingAlert() {
        if (loadingAlert != nil) {
            self.loadingAlert?.dismissViewControllerAnimated(true, completion: nil)
            self.loadingAlert = nil
        }
    }
}
