//
//  ContactsViewController.swift
//  contacts
//
//  Created by lancy on 27/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUserInterface()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup Methods
    
    private func setupUserInterface() {
        
    }
    
    // MARK: - TableView DataSource and Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kCellIdentifier = "ContactCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Lancy"
        cell.detailTextLabel?.text = "18500519154"
        return cell;
    }
    
    // MARK: - Target Action Methods
    
    @IBAction func didTapRefreshButton(sender: UIBarButtonItem) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
