//
//  OveralViewController.swift
//  SalesRecord
//
//  Created by James Thang on 6/5/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaAsyncSocket
import GoogleMobileAds


class OveralViewController: AlertController {

    let realm = try! Realm()

    private var total: Double = 0
    private var tcpSocket: MySocket?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var historyItem: Results<HistoryDrinkRealm>?
    private var billSetting: Results<BillDataRealm>?
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billSetting = realm.objects(BillDataRealm.self)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.tableNibName, bundle: nil), forCellReuseIdentifier: Constant.tableCellIdentifier)
        tableView.rowHeight = 50
        
        // Google Ad
//        if isPurchase(planID: planOneID) {
//            bannerView.isHidden = true
//        } else {
//            bannerView.delegate = self
//            bannerView.adUnitID = Constant.bannerID
//            bannerView.rootViewController = self
//            bannerView.load(GADRequest())
//            adViewDidReceiveAd(bannerView)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dateConvert(date: datePicker.date)
        if let ipAddress = UserDefaults.standard.string(forKey: "tcpPrinterIP") {
            let port: UInt16 = 9100
            
            self.tcpSocket = MySocket(address: ipAddress, portConnect: port)
        }
    }
    
 
    @IBAction func dateSelect(_ sender: UIDatePicker) {
        total = 0
        totalLabel.text = ""
        dateConvert(date: sender.date)
    }
    
    
    @IBAction func cashInOutSelect(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter Admin Password", message: "Unlock admin authority", preferredStyle: UIAlertController.Style.alert )
        
        let inflow = UIAlertAction(title: "InFlow (+)", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let isDouble = Double(textField.text!) {
                try! self.realm.write {
                    self.billSetting?.first?.cashIn += isDouble
                }
//                self.tcpSocket?.openDrawer()
            } else {
                self.alertUnSuccess(title: "Not a Number", message: "Only accept number.")
            }
        }
        
        let outflow = UIAlertAction(title: "OutFlow (-)", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let isDouble = Double(textField.text!) {
                try! self.realm.write{
                    self.billSetting?.first?.cashOut += isDouble
                }
//                self.tcpSocket?.openDrawer()
            } else {
                self.alertUnSuccess(title: "Not a Number", message: "Only accept number.")
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Enter the Amount"

        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }

        alert.addAction(inflow)
        alert.addAction(outflow)
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)
    }
    
    @IBAction func doubleCheckSelect(_ sender: UIButton) {
//        self.tcpSocket?.openDrawer()
        performSegue(withIdentifier: Constant.toDoubleCheck, sender: self)
    }
    
    func dateConvert(date: Date) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = timeFormatter.string(from: date)
        loadDataRealm(date: stringDate)
        tableView.reloadData()
    }
    
    func loadDataRealm(date: String) {
        historyItem = realm.objects(HistoryDrinkRealm.self)
            .filter("date == %@", date)
            .sorted(byKeyPath: "time", ascending: false)
        
        if historyItem!.count > 0 {
            totalCalulate()
        }
    }
    
    func totalCalulate() {
        historyItem?.forEach({ (item) in
            total = total + item.revenue
        })
        
        totalLabel.text = "Total: \(roundOrNot(value: total)) \(historyItem?[0].currency ?? "")"
    }
    
    override func roundOrNot(value: Double) -> String {
        if value == floor(value) {
            return Int(value).formattedWithSeparator
        } else {
            return value.formattedWithSeparator
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constant.toHistoryDetail {
            let detailVC = segue.destination as! PopUpHistoryController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.selectItem = historyItem?[indexPath.row]
            }
            
            detailVC.tcpSocket = self.tcpSocket
            detailVC.billSetting = self.billSetting
            detailVC.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            detailVC.popoverPresentationController?.sourceView = view
            detailVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        } else if segue.identifier == Constant.toDoubleCheck {
            let doubleVC = segue.destination as! DoubleCheckController
            
            doubleVC.expectedResult = self.total
            doubleVC.tcpDoubleCSocket = self.tcpSocket
            
            if historyItem!.count > 0 {
                doubleVC.currency = historyItem?[0].currency
            }
        }
    }

}


extension OveralViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItem?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
        
        let totalBill = historyItem?.count ?? 0
        
        if let item = historyItem?[indexPath.row] {
            cell.quantityLabel.text = "#\(totalBill - indexPath.row)"
            cell.totalLabel.text = "\(roundOrNot(value: item.revenue)) \(item.currency)"
            cell.drinkNameLabel.text = item.time
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.toHistoryDetail, sender: self)
    }
}
