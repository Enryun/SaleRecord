//
//  PopUpInventoryController.swift
//  SalesRecord
//
//  Created by James Thang on 7/10/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift

class PopUpInventoryController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var quantityTextDisplay: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var currentQuantityLabel: UILabel!
    @IBOutlet weak var itemName: UILabel!
    
    var quantity: String = ""
    var name: String = ""
    var item: MenuDrinKRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuantityLabel.text = quantity
        itemName.text = name
        warningLabel.isHidden = true
    }
    

    @IBAction func inputSelect(_ sender: UIButton) {
        
        if let intQuantity = Int(quantityTextDisplay.text!) {
            warningLabel.isHidden = true
            if let realmItem = item {
                if sender.currentTitle! == "Increase" {
                   try! realm.write {
                        realmItem.inventoryQuantity += intQuantity
                    }
                } else {
                   try! realm.write {
                        realmItem.inventoryQuantity -= intQuantity
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            warningLabel.isHidden = false
        }
    }
}
