//
//  DrinkDisplay.swift
//  SalesRecord
//
//  Created by James Thang on 6/3/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation
import RealmSwift

class DrinkDisplay: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var quantity: Double = 1
    @objc dynamic var drink: String = ""
    @objc dynamic var oldPrice: Double = 0
    @objc dynamic var price: Double = 0
    
    @objc dynamic var total: Double {
        get {
            return quantity*price
        }
    }
    
    let owner = LinkingObjects(fromType: HistoryDrinkRealm.self, property: "details")
}
