//
//  ContactsViewController.swift
//  contacts
//
//  Created by lancy on 27/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit
import Alamofire

class ContactsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate {
    @IBOutlet var tableView: UITableView!
    
    var contacts: [Contact] = []
    var searchResults: [Contact] = []
    
    // MARK: - Life Cycle Methods
    
    override func viewDidAppear(animated: Bool) {
        if self.contacts.count == 0 {
            if let cachedResponseString = self.getResponseStringFromFile() {
                self.showContactsFromResponseString(cachedResponseString)
            } else if !self.isLogin() {
                self.showLoginViewController()
            } else {
                self.requestContacts()
            }
        }
    }
        
    // MARK: - Setup Methods
    
    private func requestContacts() {
        self.showLoadingAlert()
        Alamofire.request(.GET, "http://wiki.zhenguanyu.com/TeamMembers")
        .responseString { (request, response, responseString, error) -> Void in
            self.hideLoadingAlert()
            if (200 <= response?.statusCode && response?.statusCode <= 299) {
                self.showContactsFromResponseString(responseString!)
                self.saveResponseStringToFile(responseString!)
            } else {
                self.setLogin(false)
                if (response?.statusCode == 403) {
                    self.showNeedLoginAlert()
                } else {
                    self.showAlertWithTitle("Error", message: "Network Error.")
                }
            }
        }
    }
    
    private func showContactsFromResponseString(responseString: String) {
        self.contacts = Contact.contactsFromHTMLString(responseString)
        self.tableView.reloadData()
    }
    
    // MARK: - Response Store
    
    private func responseStringSavePath() -> String {
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first as! String
        return dir.stringByAppendingPathComponent("response.string")
    }
    
    private func saveResponseStringToFile(responseString: String) {
        let path = self.responseStringSavePath()
        responseString.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    private func getResponseStringFromFile() -> String? {
        let path = self.responseStringSavePath()
        return String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    // MARK: - Show Login ViewController
    
    private func showNeedLoginAlert() {
        let alert = UIAlertController(title: "Error", message: "Need Login", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Login Now", style: .Default) { (action) -> Void in
            self.showLoginViewController()
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showLoginViewController() {
        self.performSegueWithIdentifier("showLogin", sender: self);
    }
    
    // MARK: - TableView DataSource and Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.searchResults.count
        } else {
            return self.contacts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kCellIdentifier = "ContactCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as? UITableViewCell
        let contact = tableView == self.searchDisplayController?.searchResultsTableView ? self.searchResults[indexPath.row] : self.contacts[indexPath.row]
        cell!.textLabel?.text = contact.name
        cell!.detailTextLabel?.text = contact.phone
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let contact = tableView == self.searchDisplayController?.searchResultsTableView ? self.searchResults[indexPath.row] : self.contacts[indexPath.row]
        if let url = NSURL(string: "telprompt://\(contact.phone!)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let contact = tableView == self.searchDisplayController?.searchResultsTableView ? self.searchResults[indexPath.row] : self.contacts[indexPath.row]
        self.performSegueWithIdentifier("showDetail", sender: contact)
    }
    
    // MARK: - Search Display View Controller Delegate Methods
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.searchResults = self.contacts.filter({ (contact: Contact) -> Bool in
            if contact.name?.rangeOfString(searchString) != nil
            || contact.phone?.rangeOfString(searchString) != nil
                || contact.email?.rangeOfString(searchString) != nil {
                    return true
            } else {
                return false
            }
        })
        return true
    }
    
    // MARK: - Target Action Methods
    
    @IBAction func didTapRefreshButton(sender: UIBarButtonItem) {
        self.requestContacts()
    }

    @IBAction func didTapAddToAddressBookButton(sender: AnyObject) {
        let importQueue = dispatch_queue_create("importAB", nil)
        let group = dispatch_group_create()

        let alert = UIAlertController(title: nil, message: "请填写分组名，空则不创建新组", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.text = "猿题库"
            textField.placeholder = "组名(可选)"
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (_) -> Void in

        }
        let confirmAction = UIAlertAction(title: "确定", style: .Default) { (_) -> Void in
            let textField = alert.textFields![0] as! UITextField
            let importingAlertVC = UIAlertController(title: "正在导入...", message: nil, preferredStyle: .Alert)
            self.presentViewController(importingAlertVC, animated: true, completion: nil)

            dispatch_group_async(group, importQueue, { () -> Void in
                self.addAllContactsToAddressBook(textField.text)
            })

            dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                importingAlertVC.dismissViewControllerAnimated(true, completion: nil)
                let successAlert = UIAlertController(title: "通讯录已更新", message: nil, preferredStyle: .Alert)
                self.presentViewController(successAlert, animated: true, completion: nil)

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    successAlert.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            alert.dismissViewControllerAnimated(false, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: false, completion: nil)
    }

    func addAllContactsToAddressBook(groupName: String?) {
        for contact in self.contacts {
            ABHelper.insertIntoAddressBook(contact, groupName: groupName ?? "猿题库")
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showDetail" {
            let contact = sender as! Contact
            let des = segue.destinationViewController as! DetailViewController
            des.contact = contact
        }
    }

}
