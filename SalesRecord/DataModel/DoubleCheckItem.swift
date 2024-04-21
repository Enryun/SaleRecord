//
//  DoubleCheckItem.swift
//  SalesRecord
//
//  Created by James Thang on 7/14/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation

class DoubleCheckItem {
    
    var moneyTag: Int
    var count: Int = 0
    var result: Int {
        get {
            return moneyTag*count
        }
    }
    
    init(moneyInput: Int) {
        self.moneyTag = moneyInput
    }
    
   
}
