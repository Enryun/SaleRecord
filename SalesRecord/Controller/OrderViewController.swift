//
//  OrderViewController.swift
//  SalesRecord
//
//  Created by James Thang on 5/27/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class OrderViewController: AlertController {
    
    let realm = try! Realm()

    @IBOutlet weak var segmentLabel: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultTotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    var menuGrandList: Results<MenuDrinKRealm>?
    var menuList: Results<MenuDrinKRealm>?
        
    private var tableDisplay: [DrinkDisplay] = []
    private var inventoryTrackList: [InventoryTracking] = []
    private var currencyText: String = ""
    private var taxRate: Double?
    private var billSettingMother: Results<BillDataRealm>?
    private var taxValue: Double = 0
    private var discountValue: Double = 0
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        taxLabel.isHidden = true
        discountLabel.isHidden = true

        collectionView.delegate = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constant.collectionNibName, bundle: nil), forCellWithReuseIdentifier: Constant.collectionCellIdentifier)
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constant.tableNibName, bundle: nil), forCellReuseIdentifier: Constant.tableCellIdentifier)
        
        // Banner Ad
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
        loadMenu()

        for i in 0...9 {
            segmentLabel.setTitle(UserDefaults.standard.string(forKey: "\(i)"), forSegmentAt: i)
        }
        
        menuList = menuGrandList?.filter("position == 0").sorted(byKeyPath: "name", ascending: true)
        currencyText = UserDefaults.standard.string(forKey: Constant.defaultCurrency) ?? ""
        collectionView.reloadData()
    }
    
    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            menuList = menuGrandList?.filter("position == 0").sorted(byKeyPath: "name", ascending: true)
        case 1:
            menuList = menuGrandList?.filter("position == 1").sorted(byKeyPath: "name", ascending: true)
        case 2:
            menuList = menuGrandList?.filter("position == 2").sorted(byKeyPath: "name", ascending: true)
        case 3:
            menuList = menuGrandList?.filter("position == 3").sorted(byKeyPath: "name", ascending: true)
        case 4:
            menuList = menuGrandList?.filter("position == 4").sorted(byKeyPath: "name", ascending: true)
        case 5:
            menuList = menuGrandList?.filter("position == 5").sorted(byKeyPath: "name", ascending: true)
        case 6:
            menuList = menuGrandList?.filter("position == 6").sorted(byKeyPath: "name", ascending: true)
        case 7:
            menuList = menuGrandList?.filter("position == 7").sorted(byKeyPath: "name", ascending: true)
        case 8:
            menuList = menuGrandList?.filter("position == 8").sorted(byKeyPath: "name", ascending: true)
        case 9:
            menuList = menuGrandList?.filter("position == 9").sorted(byKeyPath: "name", ascending: true)
        default:
            print("default unexpected")
        }

        collectionView.reloadData()
    }

    
    @IBAction func trashSelect(_ sender: UIButton) {
        emptyTable()
    }
    
    
    @IBAction func payPress(_ sender: UIButton) {
        // Condition cannot Empty
        if !tableDisplay.isEmpty {
            performSegue(withIdentifier: Constant.toPayment, sender: self)
            emptyTable()
        }
    }
    
    
    @IBAction func toOverRallView(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.toHistory, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.toPayment {
            let paymentVC = segue.destination as! PaymentViewController
            
            paymentVC.subTotal = totalResult(array: tableDisplay)
            paymentVC.taxAmount = taxValue
            paymentVC.discount = discountValue
            paymentVC.passTotal = totalResult(array: tableDisplay) - discountValue + taxValue
            paymentVC.passTable = tableDisplay
            paymentVC.passInventoryList = inventoryTrackList
            paymentVC.currencyText = self.currencyText
            paymentVC.billSetting = self.billSettingMother
            paymentVC.menuGrandList = self.menuGrandList
        }
    }
}

//MARK: - Collection View

extension OrderViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuList?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.collectionCellIdentifier, for: indexPath) as! CollectionViewCell
        
        if let item = menuList?[indexPath.row] {
            cell.drinkName.text = item.name
            cell.image.image = loadImageFromDiskWith(fileName: item.name + "james")
        }
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
}


//MARK: - Table View Display

extension OrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
    
        let quantity = tableDisplay[indexPath.row].quantity
        let total = roundOrNot(value: tableDisplay[indexPath.row].total)

        cell.drinkNameLabel.text = tableDisplay[indexPath.row].drink
        cell.quantityLabel.text = "\(Int(quantity)) x"
        cell.totalLabel.text = "\(total)"
        
        return cell

    }
}

//MARK: - Collection Cell Click

extension OrderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectMenuItem = menuList![indexPath.item]
        let discountPrice = (100 - selectMenuItem.promoPercent)/100
        
        let selectedCell = DrinkDisplay()
        selectedCell.id = selectMenuItem.id
        selectedCell.drink = selectMenuItem.name
        selectedCell.oldPrice = selectMenuItem.price
        selectedCell.price = selectMenuItem.price*discountPrice
        
        if UserDefaults.standard.bool(forKey: Constant.defaultInventory) {
            
            let currentQuantity = selectMenuItem.inventoryQuantity
            print(currentQuantity)

            if selectMenuItem.inventoryQuantity <= 0 {
                alertUnSuccess(title: "This item sold out!", message: "Require debit in Inventory Control to continue selling.")
                return
            }

            let inventoryTracking = InventoryTracking(id: selectMenuItem.id, quantity: 1)
            if inventoryTrackList.count == 0 {
                inventoryTrackList.append(inventoryTracking)
            } else {
                for i in 0...inventoryTrackList.count - 1 {
                    
                    if inventoryTracking.id == inventoryTrackList[i].id {
                        if inventoryTrackList[i].quantity >= currentQuantity {
                            alertUnSuccess(title: "This item sold out!", message: "Require debit in Inventory Control to continue selling.")
                            return
                        } else {
                            inventoryTrackList[i].quantity += 1
                        }
                    }
                }
                
                let isExist = inventoryTrackList.contains { (item) -> Bool in
                    if item.id == inventoryTracking.id {
                        return true
                    } else {
                        return false
                    }
                }
                
                if !isExist {
                    inventoryTrackList.append(inventoryTracking)
                }
            }
        }
        
        
        if tableDisplay.count == 0 {
            tableDisplay.append(selectedCell)
        } else {
            for i in 0...tableDisplay.count - 1 {
                if selectedCell.id == tableDisplay[i].id {
                    tableDisplay[i].quantity += 1
                    
                    updateTableCell()
                    return
                }
            }
            tableDisplay.append(selectedCell)
        }
        
        // Update Result label
        updateTableCell()
    }

}


//MARK: - Remove Table Cell when Touch

extension OrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Cancel this Item? ", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.tableDisplay.remove(at: indexPath.row)
            self.updateTableCell()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}


//MARK: - additional Functions

extension OrderViewController {
    
    func updateTableCell() {
        let total = roundOrNot(value: totalResult(array: tableDisplay))
        resultTotalLabel.text = "\(total) \(currencyText)"
        if let realmBill = billSettingMother?.last {
            
            if realmBill.taxFee == 0 {
                taxLabel.isHidden = true
                if realmBill.discountRate != 0 {
                    discountLabel.isHidden = false
                    discountValue = totalResult(array: tableDisplay)*realmBill.discountRate
                    discountLabel.text = "discount: -\(roundOrNot(value: discountValue))"
                }
            } else if realmBill.discountRate == 0 {
                discountLabel.isHidden = true
                if realmBill.taxFee != 0 {
                    taxLabel.isHidden = false
                    taxValue = totalResult(array: tableDisplay)*realmBill.taxFee
                    taxLabel.text = "tax: +\(roundOrNot(value: taxValue))"
                }
                
            } else if realmBill.taxFee != 0 && realmBill.discountRate != 0 {
                discountLabel.isHidden = false
                discountValue = totalResult(array: tableDisplay)*realmBill.discountRate
                discountLabel.text = "discount: -\(roundOrNot(value: discountValue))"
                taxLabel.isHidden = false
                taxValue = (totalResult(array: tableDisplay) - discountValue)*realmBill.taxFee
                taxLabel.text = "tax: +\(roundOrNot(value: taxValue))"
            }
        }
        tableView.reloadData()
    }
    
    func emptyTable() {
        tableDisplay = []
        inventoryTrackList = []
        updateTableCell()
    }
    
    func totalResult(array: [DrinkDisplay]) -> Double {
        let total = array.reduce(0) { (result: Double, cell: DrinkDisplay) -> Double in
            result + cell.total
        }
        
        return total
    }
    
}

//MARK: - Loading Menu Data from Realm

extension OrderViewController {
    func loadMenu() {
        menuGrandList = realm.objects(MenuDrinKRealm.self)
        billSettingMother = realm.objects(BillDataRealm.self)
        collectionView.reloadData()
    }

    func loadImageFromDiskWith(fileName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }
}
