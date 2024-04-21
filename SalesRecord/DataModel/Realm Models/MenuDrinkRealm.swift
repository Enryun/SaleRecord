//
//  DrinkRealm.swift
//  SalesRecord
//
//  Created by James Thang on 6/10/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift

class MenuDrinKRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var position: Int = 0
    @objc dynamic var price: Double = 0
    @objc dynamic var promoPercent: Double = 0
    @objc dynamic var inventoryQuantity: Int = 0
}
