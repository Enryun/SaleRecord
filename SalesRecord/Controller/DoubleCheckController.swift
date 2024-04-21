//
//  DoubleCheckController.swift
//  SalesRecord
//
//  Created by James Thang on 7/13/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaAsyncSocket
import Printer

class DoubleCheckController: AlertController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var countTotalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var useless: UIButton!
    
    private var tableData: [DoubleCheckItem] = []
    private var paperAmount: String = ""
    private var total: Int = 0
    private var billSetting: Results<BillDataRealm>?
    
    var currency: String?
    var expectedResult: Double?
    var tcpDoubleCSocket: MySocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billSetting = realm.objects(BillDataRealm.self)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.tableNibName, bundle: nil), forCellReuseIdentifier: Constant.tableCellIdentifier)
        useless.isEnabled = false
    }
    
    @IBAction func priceTagSelect(_ sender: UIButton) {
        var priceTag = sender.currentTitle!
        paperAmount = ""
        if priceTag.contains(",") {
            priceTag = sender.currentTitle!.replacingOccurrences(of: ",", with: "")
        }
        
        let newTableCell = DoubleCheckItem(moneyInput: Int(priceTag)!)
        if tableData.isEmpty {
            tableData.append(newTableCell)
        } else {
            let repeatMoney = tableData.contains { (item) -> Bool in
                item.moneyTag == newTableCell.moneyTag
            }
            
            if !repeatMoney {
                tableData.append(newTableCell)
            }
        }
        
        totalCalulate()
        tableView.reloadData()
    }
    
    @IBAction func countSelect(_ sender: UIButton) {
        if sender.currentTitle == "AC" {
            tableData = []
            total = 0
            countTotalLabel.text = ""
        } else if sender.currentTitle == "=" {
            totalCalulate()
        } else {
            paperAmount.append(sender.currentTitle!)
            if let targetCell = tableData.last {
                targetCell.count = Int(paperAmount)!
            }
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func confirmSelect(_ sender: UIButton) {
        totalCalulate()
        let beginBalance = billSetting?.first?.cashBalance ?? 0
        let cashIn = billSetting?.first?.cashIn ?? 0
        let cashOut = billSetting?.first?.cashOut ?? 0
        let expect = beginBalance + (expectedResult ?? 0) + cashIn - cashOut
        let different = Double(total) - expect
        let takenOut = Double(total) - beginBalance
        
        var ticket3 = Ticket(
            .plainText(billSetting?.first?.restaurantName ?? ""),
            .plainText(billSetting?.first?.restaurantAddress ?? ""),
            .plainText(billSetting?.first?.restaurantContact ?? ""),
            .title("Double Check"),
            .text(.init(content: String("Time: " + self.getTime()) + "   " + String(self.getDate()), predefined: .alignment(.right))),
            .blank,
            .text(.init(content: "Revenue: \(roundOrNot(value: expectedResult ?? 0)) \(currency ?? "")", predefined: .alignment(.left))),
            .text(.init(content: "Balance: + \(roundOrNot(value: beginBalance)) \(currency ?? "")", predefined: .alignment(.left))),
            .text(.init(content: "Cash In: + \(roundOrNot(value: billSetting?.first?.cashIn ?? 0)) \(currency ?? "")", predefined: .alignment(.left))),
            .text(.init(content: "Cash Out: - \(roundOrNot(value: billSetting?.first?.cashOut ?? 0)) \(currency ?? "")", predefined: .alignment(.left))),
            .text(.init(content: "----------------" , predefined: .alignment(.left))),
            .text(.init(content: "Expected: = \(roundOrNot(value: expect)) \(currency ?? "")", predefined: .alignment(.left), .bold)),
            .text(.init(content: "Real Number: \(roundOrNot(value: Double(total))) \(currency ?? "")", predefined: .alignment(.left), .bold)),
            .text(.init(content: "Different: \(roundOrNot(value: different)) \(currency ?? "")", predefined: .alignment(.left), .bold)),
            .text(.init(content: "Taken out: \(roundOrNot(value: takenOut)) \(currency ?? "")", predefined: .alignment(.left), .bold)),
            .blank,
            .plainText("DETAIL: ")
        )
        
        for item in self.tableData {
            ticket3.add(
                block: Block(Text(
                    content: "\(item.moneyTag.formattedWithSeparator) x \(item.count)  =  \(item.result.formattedWithSeparator) ",
                    predefined: .alignment(.right)
                    )
                )
            )
        }
        
        self.tcpDoubleCSocket?.printTicketVN(ticket3)
        self.tcpDoubleCSocket?.cutPaper()
        
        try! realm.write{
            billSetting?.first?.billId = 1
            billSetting?.first?.cashIn = 0
            billSetting?.first?.cashOut = 0
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func totalCalulate() {
        total = 0
        tableData.forEach({ (item) in
            total = total + item.result
        })
        
        countTotalLabel.text = "Total: \(total.formattedWithSeparator) \(currency ?? "")"
    }
}

extension DoubleCheckController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
        
        cell.quantityLabel.text = "\(tableData[indexPath.row].moneyTag.formattedWithSeparator)"
        cell.drinkNameLabel.text = " x \(tableData[indexPath.row].count.formattedWithSeparator)"
        cell.totalLabel.text = "=  \(tableData[indexPath.row].result.formattedWithSeparator)"
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Cancel this Item? ", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.tableData.remove(at: indexPath.row)
            self.totalCalulate()
            tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}

extension Ticket: ESCPOSCommandsCreator { }
