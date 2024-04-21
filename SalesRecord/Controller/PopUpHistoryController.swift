//
//  PopUpHistoryController.swift
//  SalesRecord
//
//  Created by James Thang on 6/20/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift
import Printer

class PopUpHistoryController: AlertController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet var printingView: UIView!
    
    var tcpSocket: MySocket?
    var billSetting: Results<BillDataRealm>?
    
    var selectItem: HistoryDrinkRealm? {
        didSet {
            itemList = selectItem?.details.sorted(byKeyPath: "drink", ascending: true)
        }
    }
    
    var itemList: Results<DrinkDisplay>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constant.tableNibName, bundle: nil), forCellReuseIdentifier: Constant.tableCellIdentifier)
        
        totalLabel.text = "\(selectItem?.revenue.formattedWithSeparator ?? "0") \(selectItem?.currency ?? "")"
        receiveLabel.text = "\(selectItem?.receive.formattedWithSeparator ?? "0") \(selectItem?.currency ?? "")"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
        
        if let item = itemList?[indexPath.row] {
            cell.quantityLabel.text = "\(Int(item.quantity))x"
            cell.drinkNameLabel.text = item.drink
            cell.totalLabel.text = "\(roundOrNot(value: item.total)) \(selectItem?.currency ?? "")"
        }
            
        return cell
    }

    
    @IBAction func printSelect(_ sender: UIButton) {
//        if let printerUrl = UserDefaults.standard.url(forKey: "printerUrl") {
//            let printer = UIPrinter.init(url: printerUrl)
//            printer.contactPrinter({ (available) in
//                if available {
//                    let printInfo: UIPrintInfo = UIPrintInfo.printInfo()
//                    printInfo.outputType = .general
//                    printInfo.jobName = "James Thang"
//
//                    let printController = UIPrintInteractionController.shared
//                    printController.printInfo = printInfo
//
//                    printController.printingItem = self.printingView.asImage()
//
//                    printController.print(to: printer) { (printInteractionController, completed, error) in
//                        if ((completed && error != nil))
//                        {
//                            print("Print Error: {error.Code}:{error.Description}");
//                            self.alertUnSuccess(title: "Error Printing", message: "")
//                        }
//                    }
//                }
//            })
//        }
        
        var ticket2 = Ticket(
            .title("BILL-\(self.billSetting?.first?.billId ?? 0)"),
            .blank,
            .plainText(billSetting?.first?.restaurantName ?? ""),
            .plainText(billSetting?.first?.restaurantAddress ?? ""),
            .plainText(billSetting?.first?.restaurantContact ?? ""),
            .blank,
            .text(.init(content: String("Time: " + self.getTime()) + "   " + String(self.getDate()), predefined: .alignment(.right))),
            .blank,
            .plainText("PURCHASE"),
            .blank
        )
        
        for item in self.itemList! {
            ticket2.add(
                block: Block(Text(content: "\(item.drink)" + " \(Int(item.quantity)) x \(self.roundOrNot(value:item.price)) = \(self.roundOrNot(value: item.total))", predefined: .alignment(.right), .bold)))
        }
        
        
        
        ticket2.add(block: Block(Text(content: "-----------------------------", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "Total: \(self.totalLabel.text!)", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "Receive: \(receiveLabel.text!)", predefined: .alignment(.center)), feedPoints: 1))
        ticket2.add(block: Block(Text(content: "--------", predefined: .alignment(.center)), feedPoints: 1))
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

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
