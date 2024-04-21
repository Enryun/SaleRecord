//
//  HistoryDrinkRealm.swift
//  SalesRecord
//
//  Created by James Thang on 6/17/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryDrinkRealm: Object {
    @objc dynamic var date: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var currency: String = ""
    @objc dynamic var revenue: Double = 0
    @objc dynamic var receive: Double = 0
    
    var details = List<DrinkDisplay>()
}

