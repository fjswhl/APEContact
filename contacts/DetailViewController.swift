//
//  DetailViewController.swift
//  contacts
//
//  Created by lancy on 28/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
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
                let emailVC = MFMailComposeViewController()
                emailVC.setToRecipients([email])
                emailVC.mailComposeDelegate = self
                self.presentViewController(emailVC, animated: true, completion: nil)

            })
            actionSheet.addAction(emailAction)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, nil)
        
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "生成完整的联系方式分享出去", message: nil, preferredStyle: .ActionSheet)
        let content = "\(contact!.name!)\n手机: \(contact!.phone!)\n邮箱: \(contact!.email!)"
        let copyAction = UIAlertAction(title: "复制到剪贴板", style: .Default) { (action) -> Void in
            UIPasteboard.generalPasteboard().string = content
        }
        let emailAction = UIAlertAction(title: "通过邮件", style: .Default, handler: { (action) -> Void in
            let emailVC = MFMailComposeViewController()
            emailVC.setSubject("\(self.contact!.name!)的联系方式")
            emailVC.setMessageBody(content, isHTML: false)
            emailVC.mailComposeDelegate = self;
            self.presentViewController(emailVC, animated: true, completion: nil)
        })
        let smsAction = UIAlertAction(title: "通过信息", style: .Default, handler: { (action) -> Void in
            let msgVC = MFMessageComposeViewController()
            msgVC.body = content
            msgVC.messageComposeDelegate = self
            self.presentViewController(msgVC, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, nil)
        actionSheet.addAction(copyAction)
        actionSheet.addAction(emailAction)
        actionSheet.addAction(smsAction)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
