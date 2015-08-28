//
//  ABHelper.swift
//  contacts
//
//  Created by Lin on 15/8/28.
//  Copyright (c) 2015年 Fenbi Inc. All rights reserved.
//

import UIKit
import AddressBook

struct ABHelper {

    static let addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    static let cache = NSCache()
    static let CONTACTSCACHE_KEY = "CONTACTSCACHE_KEY"

    static func askForAddressBookAuthorizationWithCompletion(completion: (Bool) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, _) -> Void in
            completion(granted)
        })
    }

    static func openAppSettings() {
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    static func createGroup(groupName: String) -> ABRecordRef {

        let allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook).takeRetainedValue() as! [ABRecordRef]
        for group in allGroups {
            let curGroupName = ABRecordCopyValue(group, kABGroupNameProperty).takeRetainedValue() as! String
            if curGroupName == groupName {
                println("Group exists")
                return group
            }
        }

        let groupRecord: ABRecordRef = ABGroupCreate().takeRetainedValue()
        ABRecordSetValue(groupRecord, kABGroupNameProperty, groupName, nil)
        ABAddressBookAddRecord(addressBook, groupRecord, nil)
        saveAddressBookChanges()
        println("\(groupName) has been created")
        return groupRecord
    }

    static func saveAddressBookChanges() -> Bool {
        if ABAddressBookHasUnsavedChanges(addressBook) {
            let saveToAddressBook = ABAddressBookSave(addressBook, nil)
            if saveToAddressBook {
                println("Successfully saved changes")
            } else {
                println("Couldn't save changes")
            }
            return saveToAddressBook
        }

        println("No changes occurred")
        return true
    }

    // MARK: concret operation

    static func insertIntoAddressBook(contact: Contact, groupName: String? = nil) -> ABRecordRef {
        var contactRecord: ABRecordRef
        if let existedRecord: ABRecordRef = getContactRecord(contact) {
            contactRecord = existedRecord
        } else {
            contactRecord = ABPersonCreate().takeRetainedValue()
        }

        ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, contact.name!, nil)

        let phoneNumbers: ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(phoneNumbers, contact.phone!, kABPersonPhoneMainLabel, nil)
        ABRecordSetValue(contactRecord, kABPersonPhoneProperty, phoneNumbers, nil)

        let emails: ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(emails, contact.email!, kABWorkLabel, nil)
        if let gmail = contact.gmail {
            ABMultiValueAddValueAndLabel(emails, gmail, kABHomeLabel, nil)
        }
        ABRecordSetValue(contactRecord, kABPersonEmailProperty, emails, nil)

        if let depart = contact.department {
            ABRecordSetValue(contactRecord, kABPersonDepartmentProperty, depart, nil)
        }


        ABAddressBookAddRecord(addressBook, contactRecord, nil)
        saveAddressBookChanges()

        if let group = groupName {
            addToGroup(contactRecord, groupName: group)
        }
        return contactRecord
    }

    static func getContactRecord(contact: Contact) -> ABRecordRef? {
        var allContacts: [ABRecordRef]
        if let cachedContacts = cache.objectForKey(CONTACTSCACHE_KEY) as? [ABRecordRef] {
            allContacts = cachedContacts
        } else {
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [ABRecordRef]
        }

        var targetContact: ABRecordRef?
        for record in allContacts {
            let curContactMultiEmail: ABMultiValueRef = ABRecordCopyValue(record, kABPersonEmailProperty).takeRetainedValue()
            for var i = 0; i < ABMultiValueGetCount(curContactMultiEmail); i++ {
                let email = ABMultiValueCopyValueAtIndex(curContactMultiEmail, i).takeRetainedValue() as! String
                if email == contact.email! {
                    targetContact = record
                    break
                }
            }
        }
        return targetContact
    }

    static func addToGroup(record: ABRecordRef, groupName: String) -> Bool{
        let group: ABRecordRef = createGroup(groupName)


        if let groupMembersArray = ABGroupCopyArrayOfAllMembers(group) {
            let groupMembers = groupMembersArray.takeRetainedValue() as [ABRecordRef]
            for member in groupMembers {
                if member === record {
                    return true
                }
            }
        }


        let result = ABGroupAddMember(group, record, nil)
        saveAddressBookChanges()
        return result
    }
}











