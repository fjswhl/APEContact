//
//  DetailViewController.swift
//  contacts
//
//  Created by lancy on 28/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ldapLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    @IBOutlet var gmailLabel: UILabel!
    @IBOutlet var birthDayLabel: UILabel!
    @IBOutlet var horoscopeLabel: UILabel!
    
    var contact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUserInterface()
    }
    
    private func setupUserInterface() {
        nameLabel.text = contact?.name
        ldapLabel.text = contact?.ldap
        emailLabel.text = contact?.email
        phoneLabel.text = contact?.phone
        departmentLabel.text = contact?.department
        gmailLabel.text = contact?.gmail
        birthDayLabel.text = contact?.birthDay
        horoscopeLabel.text = contact?.horoscope
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        func findString(str: String?, withRegex regex: String) -> String? {
            if str == nil {
                return nil
            }
            let regex = NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.allZeros, error: nil)
            if let first = regex.firstMatchInString(str!, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, (str! as NSString).length)) {
                return (str? as NSString?)?.substringWithRange(first.range)
            } else {
                return nil
            }
        }
        
        let findPhone = { (str: String?) -> String? in
            return findString(str, withRegex: "^1[3456789]\\d{9}$")
        }
        
        let findEmail = { (str: String?) -> String? in
            return findString(str, withRegex: "^([\\.a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\\.[a-zA-Z0-9_-]{2,3}){1,2})$")
        }
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let actionSheet = UIAlertController(title: cell?.textLabel?.text, message: cell?.detailTextLabel?.text, preferredStyle: .ActionSheet)
        
        let copyAction = UIAlertAction(title: "复制到剪贴板", style: .Default) { (action) -> Void in
            UIPasteboard.generalPasteboard().string = cell?.detailTextLabel?.text
        }
        actionSheet.addAction(copyAction)

        if let phone = findPhone(cell?.detailTextLabel?.text) {
            let phoneAction = UIAlertAction(title: "拨打 \(phone)", style: .Default, handler: { (action) -> Void in
                let url = NSURL(string: "telprompt://\(phone)")
                UIApplication.sharedApplication().openURL(url)
            })
            actionSheet.addAction(phoneAction)
        }
        
        if let email = findEmail(cell?.detailTextLabel?.text) {
            let emailAction = UIAlertAction(title: "写邮件 \(email)", style: .Default, handler: { (action) -> Void in
                let url = NSURL(string: "mailto:\(email)")
                UIApplication.sharedApplication().openURL(url)
            })
            actionSheet.addAction(emailAction)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, nil)
        
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
