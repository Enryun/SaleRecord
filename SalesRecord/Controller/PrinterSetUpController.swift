//
//  PrinterSetUpController.swift
//  SalesRecord
//
//  Created by James Thang on 6/22/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import Printer
import RealmSwift

class PrinterSetUpController: AlertController {

    let realm = try! Realm()

    @IBOutlet weak var viewPrint: UIView!
    var tcpSocket: MySocket?
    private var billSetting: Results<BillDataRealm>?

    @IBOutlet weak var companyNameTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var contactTF: UITextField!
    @IBOutlet weak var wifiPassTF: UITextField!
    @IBOutlet weak var cashBalance: UITextField!
    @IBOutlet weak var stepperValue: UIStepper!
    @IBOutlet weak var discountStepper: UIStepper!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billSetting = realm.objects(BillDataRealm.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let realmBill = billSetting?.last {
            companyNameTF.text = realmBill.restaurantName
            addressTF.text = realmBill.restaurantAddress
            contactTF.text = realmBill.restaurantContact
            wifiPassTF.text = realmBill.wifiPassword
            cashBalance.text = String(roundOrNot(value: realmBill.cashBalance))
            taxLabel.text = "\(roundOrNot(value: realmBill.taxFee*100))%"
            stepperValue.value = realmBill.taxFee*100
            discountLabel.text = "\(roundOrNot(value: realmBill.discountRate*100))%"
            discountStepper.value = realmBill.discountRate*100
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tcpSocket?.disConnect()
    }
    
    @IBAction func airPrinter(_ sender: UIButton) {
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        
        printerPicker.present(from: CGRect(x: 0, y: 0, width: 600, height: 500), in: viewPrint, animated: true) { (printerPicker, userDidSelect, error) in
            if userDidSelect {
                //Here get the selected UIPrinter
                if let defaultPrinter = printerPicker.selectedPrinter {
                    UserDefaults.standard.set(defaultPrinter.url, forKey: "printerUrl")
                }
            }
        }
    }
    
    
    
    @IBAction func fixedIPPrinter(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter Printer IP Address", message: "The Printer and this Device must connect to the Same Wifi. Read your Printer's Instruction on How to Set and Print out its IP Address.", preferredStyle: UIAlertController.Style.alert )
        
        let enter = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
                        
            if textField.text != "" {
                let port: UInt16 = 9100
        
                self.tcpSocket = MySocket(address: textField.text!, portConnect: port)
                
                var testTicket = Ticket(
                    .title("TEST SUCCESSFUL"),
                    .blank,
                    .plainText("COPY RIGHT JAMES THANG 2020"),
                    .plainText("Tiếng Việt"),
                    .blank,
                    .qr("https://www.jamesthang.com")
                )

                testTicket.feedLinesOnTail = 1
                
                self.tcpSocket?.printTicketVN(testTicket)
                self.tcpSocket?.cutPaper()
                
            } else {
                self.alertUnSuccess(title: "Cannot Connect to Printer", message: "Empty or Invalid IP Adress")
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Example: 192.168.1.233"
        }

        alert.addAction(enter)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)
    }
    
    
    @IBAction func discountSelect(_ sender: UIStepper) {
        discountLabel.text = "\(Int(sender.value))%"
    }
    
    @IBAction func taxSelect(_ sender: UIStepper) {
        taxLabel.text = "\(Int(sender.value))%"
    }
    
    
    @IBAction func confirmSelect(_ sender: UIButton) {
        
        if billSetting!.isEmpty {
            try! realm.write{
                let billSetting = BillDataRealm()
                billSetting.restaurantName = companyNameTF.text ?? ""
                billSetting.restaurantAddress = addressTF.text ?? ""
                billSetting.restaurantContact = contactTF.text ?? ""
                billSetting.wifiPassword = wifiPassTF.text ?? ""
                billSetting.taxFee = stepperValue.value/100
                billSetting.discountRate = discountStepper.value/100
                realm.add(billSetting)
            }
        } else {
           let currentBill = realm.objects(BillDataRealm.self).last
            try! realm.write{
                currentBill!.restaurantName = companyNameTF.text ?? ""
                currentBill!.restaurantAddress = addressTF.text ?? ""
                currentBill!.restaurantContact = contactTF.text ?? ""
                currentBill!.wifiPassword = wifiPassTF.text ?? ""
                currentBill!.taxFee = stepperValue.value/100
                currentBill!.discountRate = discountStepper.value/100
            }
        }
        
   
        if let cashBegin = Double(cashBalance.text!) {
            
            let currentBill = realm.objects(BillDataRealm.self).last
            try! realm.write{
                currentBill?.cashBalance = cashBegin
            }
        } else {
            alertUnSuccess(title: "Cash Balance must be a Number", message: "Enter a number")
        }
    }
}
