//
//  AutoRenewViewController.swift
//  SalesRecord
//
//  Created by James Thang on 23/01/2021.
//  Copyright © 2021 James Thang. All rights reserved.
//

import UIKit

class AutoRenewViewController: AlertController {
    
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var plan: String = ""
    
    let policyContent = PolicyModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if plan == "month" {
            contentLabel.text = "Monthly Subscription: 4.49 $ / month"
        } else if plan == "year" {
            contentLabel.text = "Yearly Subscription: 38.99 $ / year"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.toPolicy)
    }
    

    @IBAction func buyClick(_ sender: UIButton) {
        if plan == "month" {
            buyPlanOne()
        } else if plan == "year" {
            buyPlanTwo()
        }
    }
}

extension AutoRenewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policyContent.AutoRenew.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.toPolicy, for: indexPath) as UITableViewCell?
        
        cell?.textLabel?.text = policyContent.AutoRenew[indexPath.row]
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell!
    }
    
    
}
