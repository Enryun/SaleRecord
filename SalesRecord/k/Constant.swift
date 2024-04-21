//
//  Constant.swift
//  SalesRecord
//
//  Created by James Thang on 5/28/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation

struct Constant {
    
    // Custom Identifier
    static let collectionCellIdentifier = "itemCell"
    static let tableCellIdentifier = "tableCell"
    static let paymentCellIdentifier = "paymentCell"
    
    // Custom Cell File Name
    static let collectionNibName = "CollectionViewCell"
    static let tableNibName = "CustomTableCell"
    static let paymentNibName = "PaymentCell"
    
    // Segue Names
    static let logInSeuge = "success"
    static let toHistory = "toOverallView"
    static let toPayment = "toPayment"
    static let toHistoryDetail = "toHistoryDetail"
    static let toInventoryDetail = "toInventoryDetail"
    static let toDoubleCheck = "toDoubleCheck"
    static let toPayMonthly = "toAutoRenewDetail1"
    static let toPayYearly = "toAutoRenewDetail2"
    static let toPolicy = "policyCell"
    static let toWebTerm = "termOfUse"
    static let toWebPolicy = "policyWeb"
    
    // User Defaults
    static let defaultCurrency = "currency"
    static let defaultAdminPassword = "adminPassword"
    static let defaultInventory = "inventoryControl"
    
    // Advertisements
    static let bannerID = "ca-app-pub-9446229809644145/9735004157"
    static let interestialID = "ca-app-pub-9446229809644145/8018953028"
    
}
