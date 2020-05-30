//
//  TableDisplay.swift
//  SalesRecord
//
//  Created by James Thang on 5/29/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation

struct TableCellData: Hashable {
    
    var quantity = 1
    let drink: String
    let price: String
    
    var total: Int {
        get {
            let priceInt = Int(price.dropLast())
            return quantity*priceInt!
        }
    }
}

struct TableDisplay {
    
    var TableArray: [TableCellData]
    
    var totalResult: Int {
        get {
            let total = self.TableArray.reduce(0) { (result: Int, cell: TableCellData) -> Int in
                result + cell.total
            }
            
            return total
        }
    }

}
