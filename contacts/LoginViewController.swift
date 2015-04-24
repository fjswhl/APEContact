//
//  LoginViewController.swift
//  contacts
//
//  Created by lancy on 27/9/14.
//  Copyright (c) 2014 Fenbi Inc. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: BaseViewController {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func didTapLoginButton(sender: UIButton) {
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        self.requestLoginWithUserName(usernameTextField.text, password: passwordTextField.text)
    }
    
    private func requestLoginWithUserName(username: String, password: String) {
        self.showLoadingAlert()
        Alamofire.request(.POST, "https://wiki.zhenguanyu.com/FrontPage?action=login", parameters: ["name": username, "password": password, "login": "Login"])
            .response { (request, response, data, error) in
                self.hideLoadingAlert()
                if (200 <= response?.statusCode && response?.statusCode <= 299) {
                    self.setLogin(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.setLogin(false)
                    if (response?.statusCode == 403) {
                        self.showAlertWithTitle("Error", message: "Invalid username or password.")
                    } else {
                        self.showAlertWithTitle("Error", message: "Network Error.")
                    }
                }

        }
    }
}
