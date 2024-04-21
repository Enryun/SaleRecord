//
//  BarUpController.swift
//  SalesRecord
//
//  Created by James Thang on 6/6/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import Firebase

class BarUpController: UITabBarController {

    @IBOutlet weak var tabBarDeSelect: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarDeSelect.isHidden = true
    }

    @IBAction func adminConfirm(_ sender: UIBarButtonItem) {
        let adminPass = UserDefaults.standard.string(forKey: Constant.defaultAdminPassword) ?? ""
        adminPassCheck(password: adminPass)
    }
    
    @IBAction func logOutPress(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            print("log out")
            self.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func adminPassCheck(password: String) {
        let alert = UIAlertController(title: "Enter Admin Password", message: "Unlock admin authority", preferredStyle: UIAlertController.Style.alert )
        
        let enter = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            if textField.text == password {
                self.tabBarDeSelect.isHidden = false
            } else {
                self.alertUnSuccess(title: "Empty or Wrong Password", message: "Try again!")
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Admin Password"
            textField.textContentType = .password
            textField.isSecureTextEntry = true
        }

        alert.addAction(enter)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)
    }

    func alertUnSuccess(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
}
