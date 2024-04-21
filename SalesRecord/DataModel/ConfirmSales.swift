//
//  ConfirmSales.swift
//  SalesRecord
//
//  Created by James Thang on 6/2/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation
import RealmSwift

class ConfirmSales: Object {
    @objc dynamic var time: String = ""
    @objc dynamic var date: String = ""
    
    @objc dynamic var revenue: Double = 0
    @objc dynamic var receive: Double = 0
    @objc dynamic var payBack: Double {
        get {
            return self.receive - self.revenue
        }
    }
    
    var details = [DrinkDisplay]()
}
