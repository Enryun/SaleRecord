//
//  MenuData.swift
//  SalesRecord
//
//  Created by James Thang on 5/28/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation

struct MenuItem {
    let drinkName: String
    var price: String
}

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


struct MenuData {
    static let coffeeMenu: [MenuItem] = [
        MenuItem(drinkName: "ĐEN ĐÁ", price: "20k"),
        MenuItem(drinkName: "SỮA ĐÁ", price: "25k"),
        MenuItem(drinkName: "ĐEN NÓNG", price: "20k"),
        MenuItem(drinkName: "SỮA NÓNG", price: "25k"),
        MenuItem(drinkName: "Latte ĐÁ", price: "35k"),
        MenuItem(drinkName: "Latte NÓNG", price: "35k"),
        MenuItem(drinkName: "Capuchino ĐÁ", price: "35k"),
        MenuItem(drinkName: "Capuchino NÓNG", price: "35k"),
        MenuItem(drinkName: "Expresso", price: "15k")
    ]

    static let teaMenu: [MenuItem] = [
        MenuItem(drinkName: "ATISO ĐỎ", price: "27k"),
        MenuItem(drinkName: "ATISO ĐỎ(L)", price: "30k"),
        MenuItem(drinkName: "ĐẬU BIẾC", price: "27k"),
        MenuItem(drinkName: "ĐẬU BIẾC(L)", price: "30k"),
        MenuItem(drinkName: "TRÀ ĐÀO", price: "27k"),
        MenuItem(drinkName: "TRÀ ĐÀO(L)", price: "30k"),
        MenuItem(drinkName: "TRÀ SỮA", price: "27k"),
        MenuItem(drinkName: "TRÀ SỮA(L)", price: "30k"),
        MenuItem(drinkName: "ÉP THƠM", price: "27k"),
        MenuItem(drinkName: "ÉP THƠM(L)", price: "30k"),
        MenuItem(drinkName: "DƯA HẤU", price: "27k"),
        MenuItem(drinkName: "DƯA HẤU()L", price: "30k"),
        MenuItem(drinkName: "DỪA TƯƠI", price: "27k"),
        MenuItem(drinkName: "CAM TƯƠI", price: "30k"),
    ]

    static let softDrinkMenu: [MenuItem] = [
        MenuItem(drinkName: "COCA COLA", price: "20k"),
        MenuItem(drinkName: "PEPSI", price: "20k"),
        MenuItem(drinkName: "BÒ HÚC", price: "25k"),
        MenuItem(drinkName: "NƯỚC SUỐI", price: "15k"),
        MenuItem(drinkName: "STING", price: "20k"),
    ]

    static let bakeryMenu: [MenuItem] = [
        MenuItem(drinkName: "BÁNH BON", price: "25k"),
    ]
}
