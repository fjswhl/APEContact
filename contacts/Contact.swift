//
//  Contact.swift
//  contacts
//
//  Created by lancy on 27/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var name: String?
    var ldap: String?
    var email: String?
    var phone: String?
    var department: String?
    var gmail: String?
    var birthDay: String?
    var horoscope: String?
    
    class func contactsFromHTMLString(html: String) -> [Contact] {
        func getATagContentFromString(string: String) -> String? {
            var str: NSString?
            let scanner = NSScanner(string: string)
            let closeCharset = NSCharacterSet(charactersInString: ">")
            scanner.scanUpToString("<a", intoString: nil)
            scanner.scanUpToCharactersFromSet(closeCharset, intoString: nil);
            scanner.scanCharactersFromSet(closeCharset, intoString: nil)
            scanner.scanUpToString("</a>", intoString: &str)
            return str
        }
        
        func getPTagContentFromString(string: String) -> String? {
            var str: NSString?
            let scanner = NSScanner(string: string)
            let closeCharset = NSCharacterSet(charactersInString: ">")
            scanner.scanUpToString("<p", intoString: nil)
            scanner.scanUpToCharactersFromSet(closeCharset, intoString: nil);
            scanner.scanCharactersFromSet(closeCharset, intoString: nil)
            scanner.scanUpToString("</td>", intoString: &str)
            return str
        }
        
        func getContentFromString(td: String) -> String? {
            if let result = getATagContentFromString(td) {
                return result
            } else if let result = getPTagContentFromString(td) {
                return result
            } else {
                return nil
            }
        }
        
        let tableTagOpenRange = html.rangeOfString("<tbody>")
        let tableTagCloseRagne = html.rangeOfString("</tbody>")
        let scanner = NSScanner(string: html)
        let tableStartIndex = distance(html.startIndex, tableTagOpenRange!.endIndex)
        let tableEndIndex = distance(html.startIndex, tableTagCloseRagne!.endIndex)
        
        scanner.scanLocation = tableStartIndex
        
        var contacts: [Contact] = []
        
        let openCharset = NSCharacterSet(charactersInString: "<")
        // skip table header
        scanner.scanUpToString("</tr>", intoString: nil)

        while scanner.scanLocation < tableEndIndex {
            var tr: NSString?
            scanner.scanUpToString("<tr>", intoString: nil)
            scanner.scanUpToString("</tr>", intoString: &tr)
            
            if tr == nil {
                break
            }
            
            let tds = tr?.componentsSeparatedByString("<td>")
            
            var name: String? = getContentFromString(tds![1] as String)
            var ldap: String? = getContentFromString(tds![2] as String)
            var email: String? = getContentFromString(tds![3] as String)
            var phone: String? = getContentFromString(tds![4] as String)
            var department: String? = getContentFromString(tds![5] as String)
            var gmail: String? = getContentFromString(tds![6] as String)
            var birthDay: String? = getContentFromString(tds![7] as String)
            var horoscope: String? = getContentFromString(tds![8] as String)
            
            func trim(str: String?) -> String? {
                return str?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            
            let contact = Contact()
            contact.name = trim(name)
            contact.ldap = trim(ldap)
            contact.email = trim(email)
            contact.phone = trim(phone)
            contact.department = trim(department)
            contact.gmail = trim(gmail)
            contact.birthDay = trim(birthDay)
            contact.horoscope = trim(horoscope)
            
            if contact.name != nil {
                contacts.append(contact)
            }
        }
        
        return contacts
    }
}
