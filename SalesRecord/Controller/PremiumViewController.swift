//
//  PremiumViewController.swift
//  SalesRecord
//
//  Created by James Thang on 15/01/2021.
//  Copyright © 2021 James Thang. All rights reserved.
//

import UIKit
import GoogleMobileAds


class PremiumViewController: AlertController {

    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var planOneBtn: UIButton!
    @IBOutlet weak var planOneLabel: UILabel!
    @IBOutlet weak var planTwoBtn: UIButton!
    @IBOutlet weak var panTwoLabel: UILabel!
    @IBOutlet weak var benefitLabel: UILabel!
    @IBOutlet weak var restoreBtn: UIButton!
    
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageOne.layer.borderColor = UIColor.black.cgColor
        imageOne.layer.borderWidth = 1
        imageTwo.layer.borderColor = UIColor.black.cgColor
        imageTwo.layer.borderWidth = 1
        
//        if isPurchase(planID: planOneID) {
//            bannerView.isHidden = true
//            planOneBtn.isHidden = true
//            planOneLabel.text = "Thank you for your Support"
//            planOneLabel.textColor = .orange
//            panTwoLabel.text = "Download 'Coffee Record' from AppStore using the same Email and Password to Log In"
//            planTwoBtn.isHidden = true
//            restoreBtn.isHidden = true
//        } else {
//            bannerView.delegate = self
//            bannerView.adUnitID = Constant.bannerID
//            bannerView.rootViewController = self
//            bannerView.load(GADRequest())
//            adViewDidReceiveAd(bannerView)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == Constant.toPayMonthly {
            let secondVC = segue.destination as! AutoRenewViewController
            secondVC.plan = "month"
        } else if segue.identifier == Constant.toPayYearly {
            let secondVC = segue.destination as! AutoRenewViewController
            secondVC.plan = "year"
        } else if segue.identifier == Constant.toWebPolicy {
            let secondVC = segue.destination as! WebViewController
            secondVC.url = "https://www.jamesthang.com/policy/ucoffee"
        } else if segue.identifier == Constant.toWebTerm {
            let secondVC = segue.destination as! WebViewController
            secondVC.url = "https://www.jamesthang.com/policy/ucoffee-eula"
        }
    }
    
    

    @IBAction func planOnePurchased(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.toPayMonthly, sender: self)
    }
    
    
    @IBAction func planTwoPurchased(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.toPayYearly, sender: self)
    }
    
    @IBAction func restoreBtn(_ sender: UIButton) {
        restore()
    }
    
    
    @IBAction func termOfUse(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.toWebTerm, sender: self)
    }
    
    
    @IBAction func privacyPolicy(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.toWebPolicy, sender: self)
    }
}
