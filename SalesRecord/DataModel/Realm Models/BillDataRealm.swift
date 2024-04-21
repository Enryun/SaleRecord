//
//  BillDataRealm.swift
//  SalesRecord
//
//  Created by James Thang on 7/13/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation
import RealmSwift

class BillDataRealm: Object {
    @objc dynamic var restaurantName: String = ""
    @objc dynamic var restaurantAddress: String = ""
    @objc dynamic var restaurantContact: String = ""
    @objc dynamic var wifiPassword: String = ""
    @objc dynamic var billId: Int = 1
    @objc dynamic var cashIn: Double = 0
    @objc dynamic var cashOut: Double = 0
    @objc dynamic var taxFee: Double = 0
    @objc dynamic var discountRate: Double = 0
    @objc dynamic var cashBalance: Double = 0
}
