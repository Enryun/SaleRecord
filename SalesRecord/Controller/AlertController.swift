//
//  AlertController.swift
//  SalesRecord
//
//  Created by James Thang on 6/17/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Purchases

class AlertController: UIViewController, SKPaymentTransactionObserver {
    
    
//    var interstitial: GADInterstitial!
    
    let planOneID = "com.jamesthang.SalesRecord.RemoteRecord"
    let planTwoID = "com.jamesthang.SalesRecord.RemoteYearly"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        interstitial = createAndLoadInterstitial()
        SKPaymentQueue.default().add(self)
        
        // Check subscription
        Purchases.shared.purchaserInfo { (info, error) in
            if info?.entitlements["pro_member"]?.isActive == true {
                UserDefaults.standard.set(true, forKey: self.planOneID)
            } else {
                UserDefaults.standard.set(false, forKey: self.planOneID)
            }
        }
        
    }
    

    func alertUnSuccess(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
     
    
    func roundOrNot(value: Double) -> String {
        if value == floor(value) {
            return Int(value).formattedWithSeparator
        } else {
            return value.formattedWithSeparator
        }
    }
    
    func getDate()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    
    func getTime()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    
//    func createAndLoadInterstitial() -> GADInterstitial {
//        let interstitial = GADInterstitial(adUnitID: Constant.interestialID)
//        interstitial.delegate = self
//        interstitial.load(GADRequest())
//        return interstitial
//    }
//
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//      interstitial = createAndLoadInterstitial()
//    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      bannerView.alpha = 0
      UIView.animate(withDuration: 1, animations: {
        bannerView.alpha = 1
      })
    }
    
    // In App Purchase
    
    func isPurchase(planID: String) -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: planID)
        if purchaseStatus {
            print("already purchased")
            return true
        } else {
            print("never purchased")
            return false
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                removeAds()
                alertUnSuccess(title: "Thank you", message: "Terminate and Log In again. Download 'Coffee Record' on AppStore for other devices")
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    alertUnSuccess(title: "Error Purchasing", message: "transaction failed due to error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                removeAds()
                alertUnSuccess(title: "Transaction restored", message: "Welcome back. Terminate and Open your App again.")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func buyPlanOne() {
        if SKPaymentQueue.canMakePayments() {
            // Can make payment
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = planOneID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("can't make payment")
        }
    }
    
    func buyPlanTwo() {
        if SKPaymentQueue.canMakePayments() {
            // Can make payment
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = planTwoID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("can't make payment")
        }
    }
    
    func restore() {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["pro_member"]?.isActive == true {
                self.removeAds()
                self.alertUnSuccess(title: "Transaction restored", message: "Welcome back. Terminate and Open your App again.")
            } else {
                UserDefaults.standard.set(false, forKey: self.planOneID)
                self.alertUnSuccess(title: "Not valid", message: "Make sure you are using the same AppleID")
            }
        }
    }
    
    func removeAds() {
        UserDefaults.standard.set(true, forKey: planOneID)
        self.view.layoutIfNeeded()
    }
    
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Double{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
}


