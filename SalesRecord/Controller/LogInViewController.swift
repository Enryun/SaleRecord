//
//  LogInViewController.swift
//  SalesRecord
//
//  Created by James Thang on 6/5/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class LogInViewController: AlertController {
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var adminPassword: UITextField!
    @IBOutlet weak var segmentLabel: UISegmentedControl!
    @IBOutlet weak var adminPassView: UIView!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adminPassView.isHidden = true
        adminLabel.isHidden = true
        
        rememberSwitch.isOn = KeychainWrapper.standard.bool(forKey: "remember") ?? false
        
        if rememberSwitch.isOn {
            userName.text = KeychainWrapper.standard.string(forKey: "userName")
            passWord.text = KeychainWrapper.standard.string(forKey: "passWord")
        }
    }

    
    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            adminPassView.isHidden = true
            adminLabel.isHidden = true
        } else {
            adminPassView.isHidden = false
            adminLabel.isHidden = false
        }
    }
    
    @IBAction func rememberPress(_ sender: UISwitch) {
        KeychainWrapper.standard.set(self.rememberSwitch.isOn, forKey: "remember")
    }
    
    @IBAction func confirmPress(_ sender: UIButton) {
        
        if userName.text!.isEmpty || passWord.text!.isEmpty {
            return
        }
        
        KeychainWrapper.standard.set(userName.text!, forKey: "userName")
        KeychainWrapper.standard.set(passWord.text!, forKey: "passWord")
        
        if segmentLabel.selectedSegmentIndex == 0 {
            logIn(email: userName.text!, password: passWord.text!)
        } else {
            if adminPassword.text! != "" {
                signUp(email: userName.text!, password: passWord.text!, adminPass: adminPassword.text!)
            } else {
                return
            }
        }
    }
    
    func logIn(email: String, password: String) {
         Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
               
                self.alertUnSuccess(title: "Error", message: e.localizedDescription)
            } else {
                self.performSegue(withIdentifier: Constant.logInSeuge, sender: self)
            }
        }
    }
    
    func signUp(email: String, password: String, adminPass: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          if let e = error {
            self.alertUnSuccess(title: "Error", message: e.localizedDescription)
            
          } else {
              // To the Chat Screen
            self.performSegue(withIdentifier: Constant.logInSeuge, sender: self)
          }
        }
        
        UserDefaults.standard.set(adminPass, forKey: Constant.defaultAdminPassword)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC = segue.destination         // Display Full Sceneeee
        secondVC.modalPresentationStyle = .fullScreen
    }
}
