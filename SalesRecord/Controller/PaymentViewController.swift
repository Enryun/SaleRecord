//
//  PaymentViewController.swift
//  SalesRecord
//
//  Created by James Thang on 5/30/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import Printer
import CocoaAsyncSocket

class PaymentViewController: AlertController {
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var repayLabel: UILabel!
    @IBOutlet weak var tableNumberTF: UITextField!
    
    var passTotal: Double = 0
    var passTable: [DrinkDisplay] = []
    var passInventoryList: [InventoryTracking] = []
    var input: String = ""
    var currencyText: String = ""
    
    var tcpSocket: MySocket?
    
    var menuGrandList: Results<MenuDrinKRealm>?
    var billSetting: Results<BillDataRealm>?
    
    var taxAmount: Double = 0
    var discount: Double = 0
    var subTotal: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalLabel.text = "\(roundOrNot(value: passTotal)) \(currencyText)"
        
        tableView.register(UINib(nibName: Constant.paymentNibName, bundle: nil), forCellReuseIdentifier: Constant.paymentCellIdentifier)
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let ipAddress = UserDefaults.standard.string(forKey: "tcpPrinterIP") {
            let port: UInt16 = 9100
            
            self.tcpSocket = MySocket(address: ipAddress, portConnect: port)
        }
    }
    
    @IBAction func escapeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payPress(_ sender: UIButton) {
        
        if !input.isEmpty && Double(input)! >= passTotal {
            let alert = UIAlertController(title: "Confirm Payment? ", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                
                if self.isPurchase(planID: self.planOneID) {
                    // FireBase Write
                    if Auth.auth().currentUser != nil {
                        var detail = ""
                        var quantity = ""
                        self.passTable.forEach { (item) in
                            print(item)
                            let content = "\(item.drink)&&&\(Int(item.quantity))&&&\(item.quantity*item.price)"
                            quantity += content
                            quantity += "###"
                            
                            
                            let detailContent = "\(item.drink)  :  \(Int(item.quantity))  X  \(self.roundOrNot(value: item.price))  =  \(self.roundOrNot(value: item.quantity*item.price)) \(self.currencyText) "
                            detail += detailContent
                            detail += "###"
                        }
                        
                        let userEmail = Auth.auth().currentUser!.email!
                    
                        self.db.collection("Bills_Data").addDocument(data: [
                            "time": String(self.getTime()),
                            "date": String(self.getDate()),
                            "revenue": self.passTotal,
                            "receive" : Double(self.input)!,
                            "currency": self.currencyText,
                            "details" : detail,
                            "quantity": quantity,
                            "tax" : self.taxAmount,
                            "discount" : self.discount,
                            "sort" : Date().timeIntervalSince1970,
                            "userName" : userEmail
                            
                        ]) { (error) in
                            if let e = error {
                                print("There is a problem with Firebase \(e)")
                            } else {
                                print("Success")
                            }
                        }
                    } else {
                        print("No User Sign In")
                    }
                } else {
                    print("not purchase")
                }
               
                
                
                // Realm write
                try! self.realm.write {
                    let newHistory = HistoryDrinkRealm()
                    newHistory.date = self.getDate()
                    newHistory.time = self.getTime()
                    newHistory.revenue = self.passTotal
                    newHistory.receive = Double(self.input)!
                    newHistory.currency = self.currencyText
                    self.passTable.forEach { (item) in
                        newHistory.details.append(item)
                    }
                    
                    self.realm.add(newHistory)
                }
                
                // Inventory Control if Activate
                if UserDefaults.standard.bool(forKey: Constant.defaultInventory) {
                    self.passInventoryList.map { item in
                        let menuItem = self.menuGrandList?.filter("id == '\(item.id)'")
                        try! self.realm.write{
                            menuItem?.first?.inventoryQuantity -= item.quantity
                        }
                    }
                }
                
                
                // Check Printer Ready
                var ticket1 = Ticket(
                    .title("BILL-\(self.billSetting?.first?.billId ?? 0)"),
                    .blank,
                    .text(.init(content: String(self.getTime()) + "   " + String(self.getDate()), predefined: .alignment(.center))),
                    .text(.init(content: "Table: \(self.tableNumberTF.text ?? "")", predefined: .alignment(.left), .bold)),
                    .blank
                )
                
                for item in self.passTable {
                    ticket1.add(block: Block(Text(content: "\(Int(item.quantity)) \(item.drink)", predefined: .alignment(.center), .scale(.l1))))
                }
                
                self.tcpSocket?.printTicketVN(ticket1)
                self.tcpSocket?.cutPaper()
                //                    let image = UIImage(named: "eCoffeeLogo")
                self.ticket2()
                
                try! self.realm.write{
                    self.billSetting?.first?.billId += 1
                }
                
                self.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            repayLabel.text = "Enter Amount!"
        }
    }
    
    @IBAction func numberPress(_ sender: UIButton) {
        if let numberString = sender.currentTitle {
            input = input + numberString
            inputLabel.text = Double(input)!.formattedWithSeparator + " \(currencyText)"
            
            if Double(input)! >= passTotal {
                let exchange = Double(input)! - passTotal
                repayLabel.text = "-\(roundOrNot(value: exchange)) \(currencyText)"
            }
        }
    }
    
    @IBAction func quickNumber(_ sender: UIButton) {
        if let numberString = sender.currentTitle {
            input = input + numberString
            inputLabel.text = Double(input)!.formattedWithSeparator + " \(currencyText)"
            
            if Double(input)! > passTotal {
                let exchange = Double(input)! - passTotal
                repayLabel.text = "-\(roundOrNot(value: exchange)) \(currencyText)"
            }
        }
    }
    
    @IBAction func resetPress(_ sender: UIButton) {
        inputLabel.text = "0 \(currencyText)"
        repayLabel.text = "0"
        input = ""
    }
    
}

//MARK: - Table View

extension PaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.paymentCellIdentifier, for: indexPath) as! PaymentCell
        
        let quantity = passTable[indexPath.row].quantity
        let total = roundOrNot(value: passTable[indexPath.row].total)
        
        cell.nameLabel.text = passTable[indexPath.row].drink
        cell.quantityLabel.text = "\(Int(quantity)) x"
        if passTable[indexPath.row].price == passTable[indexPath.row].oldPrice {
            cell.newLabel.text = "\(total) \(currencyText)"
            cell.oldLabel.text = ""
        } else {
            let crossTotal = passTable[indexPath.row].oldPrice * passTable[indexPath.row].quantity
            let crossString = roundOrNot(value: crossTotal)
            cell.oldLabel.attributedText = crossString.strikeThrough()
            cell.newLabel.text = "  \(total) \(currencyText)"
        }
        
        return cell
    }
}


//MARK: - Tickets

extension PaymentViewController {
    
    func ticket2() {
        var ticket2 = Ticket(
            .text(.init(content: String(billSetting?.first?.restaurantName ?? ""), predefined: .alignment(.center))),
            .text(.init(content: String(billSetting?.first?.restaurantAddress ?? ""), predefined: .alignment(.center))),
            .text(.init(content: String(billSetting?.first?.restaurantContact ?? ""), predefined: .alignment(.center))),
            .blank,
            .title("BILL-\(self.billSetting?.first?.billId ?? 0)"),
            .blank,
            .text(.init(content: "Table: \(self.tableNumberTF.text ?? "")", predefined: .alignment(.right), .bold)),
            .blank,
            .text(.init(content: String("Time: " + self.getTime()) + "   " + String(self.getDate()), predefined: .alignment(.right))),
            .blank,
            .plainText("PURCHASE"),
            .blank
        )
        
        
        
        for item in self.passTable {
            if item.oldPrice == item.price {
//                ticket2.add(
//                    block: Block(Text(
//                        content: "\(item.drink) \(Int(item.quantity))  x  \(self.roundOrNot(value:item.price)) = \(self.roundOrNot(value: item.total)) ",
//                        predefined: .alignment(.left), .scale(.l1), .small
//                        )
//                    )
//                )
                ticket2.add(
                    block: Block(Text(content: "\(item.drink)" + " \(Int(item.quantity)) x \(self.roundOrNot(value:item.price)) = \(self.roundOrNot(value: item.total))", predefined: .alignment(.right), .bold)))
            } else {
                let discount = (item.price - item.oldPrice)/item.oldPrice
                ticket2.add(
                    block: Block(Text(
                        content: "\(Int(item.quantity)) \(item.drink)  x \(self.roundOrNot(value:discount)) \(self.roundOrNot(value:item.price)) = \(self.roundOrNot(value: item.total)) ",
                        predefined: .alignment(.left), .scale(.l1), .small
                        )
                    )
                )
            }
        }
        
        ticket2.add(block: Block(Text(content: "-----------------------------", predefined: .alignment(.center)), feedPoints: 1))
        if self.discount > 0 && self.taxAmount > 0 {
            ticket2.add(block: Block(Text(content: roundOrNot(value: self.subTotal!), predefined: .alignment(.right)), feedPoints: 1))
        }
       
        if self.discount > 0 {
            ticket2.add(block: Block(Text(content: "Discount: -\(roundOrNot(value: self.discount))", predefined: .alignment(.right)), feedPoints: 1))
        }
        if self.taxAmount > 0 {
            ticket2.add(block: Block(Text(content: "Tax: +\(roundOrNot(value: self.taxAmount))", predefined: .alignment(.right)), feedPoints: 1))
        }
      
        ticket2.add(block: Block(Text(content: "        ", predefined: .alignment(.center)), feedPoints: 3))
        ticket2.add(block: Block(Text(content: "Total: \(self.totalLabel.text!)", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "Receive: \(Double(input)!.formattedWithSeparator) \(currencyText)", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "--------", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "Repay: \(self.repayLabel.text!)", predefined: .alignment(.center), .bold), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "        ", predefined: .alignment(.center)), feedPoints: 3))
        ticket2.add(block: Block(Text(content: "-----------------------------", predefined: .alignment(.center)), feedPoints: 3))
        ticket2.add(block: Block(Text(content: "        ", predefined: .alignment(.center)), feedPoints: 3))
        ticket2.add(block: Block(Text(content: "Wifi password: \(billSetting?.first?.wifiPassword ?? "")", predefined: .alignment(.center))))
        ticket2.add(block: Block(Text(content: "        ", predefined: .alignment(.center)), feedPoints: 3))
        ticket2.add(block: Block(Text(content: "Thanks for supporting", predefined: .alignment(.center))))
        
        self.tcpSocket?.printTicketVN(ticket2)
        self.tcpSocket?.cutPaper()
        self.tcpSocket?.openDrawer()
    }
}



