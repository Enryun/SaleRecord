//
//  OrderViewController.swift
//  SalesRecord
//
//  Created by James Thang on 5/27/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    
    @IBOutlet weak var segmentLabel: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultTotalLabel: UILabel!
    
    var menu: [MenuItem] = MenuData.coffeeMenu
    private var tableDisplay = TableDisplay(TableArray: [])
    
    // Sharing this Data to the Second Tab
    var salesConfirm = ConfirmSales(Sales: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constant.collectionNibName, bundle: nil), forCellWithReuseIdentifier: Constant.collectionCellIdentifier)
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constant.tableNibName, bundle: nil), forCellReuseIdentifier: Constant.tableCellIdentifier)
    }
    
    
    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            menu = MenuData.coffeeMenu
        case 1:
            menu = MenuData.teaMenu
        case 2:
            menu = MenuData.softDrinkMenu
        case 3:
            menu = MenuData.bakeryMenu
        default:
            print("default unexpected")
        }
        
        collectionView.reloadData()
    }
    
    
    @IBAction func trashSelect(_ sender: UIButton) {
        emptyTable()
    }
    
    
    @IBAction func payPress(_ sender: UIButton) {
        // Saving this Bill to Core Data
        
        // Condition can not Empty
        if !tableDisplay.TableArray.isEmpty {
            salesConfirm.Sales.append(tableDisplay)
            emptyTable()
        }
       
        print(salesConfirm.Sales)
        print(salesConfirm.Sales.count)
        
        // Create Alert Box or New navigation
        
        // Connect and Order Printer
    }
}

//MARK: - Collection View

extension OrderViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.collectionCellIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.drinkName.text = menu[indexPath.row].drinkName
        cell.priceTag.text = menu[indexPath.row].price
        
        return cell
    }
}


//MARK: - Table View Display

extension OrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDisplay.TableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
        
        cell.drinkNameLabel.text = tableDisplay.TableArray[indexPath.row].drink
        cell.priceLabel.text = tableDisplay.TableArray[indexPath.row].price

        let quantity = tableDisplay.TableArray[indexPath.row].quantity
        let total = tableDisplay.TableArray[indexPath.row].total

        cell.quantityLabel.text = "\(quantity) x"
        cell.totalLabel.text = "\(total),000 Đ "
        
        return cell

    }
}

//MARK: - Content Cell Clicked

extension OrderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = TableCellData(drink: menu[indexPath.item].drinkName, price: menu[indexPath.item].price)
        
        if tableDisplay.TableArray.count == 0 {
            tableDisplay.TableArray.append(selectedCell)
        } else {
            for i in 0...tableDisplay.TableArray.count - 1 {
                if selectedCell.drink == tableDisplay.TableArray[i].drink {
                    tableDisplay.TableArray[i].quantity += 1
                    
                    updateTableCell()
                    return
                }
            }
            tableDisplay.TableArray.append(selectedCell)
        }
        
        // Update Result label
        updateTableCell()
    }

}


//MARK: - Remove Table Cell when Touch

extension OrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Huỷ món này? ", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Có", style: .destructive, handler: { action in
            self.tableDisplay.TableArray.remove(at: indexPath.row)
            self.updateTableCell()
        }))
        
        alert.addAction(UIAlertAction(title: "Không", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}


//MARK: - additional Functions

extension OrderViewController {
    
    func updateTableCell() {
        let total = tableDisplay.totalResult
        resultTotalLabel.text = "\(total),000 Đ "
        tableView.reloadData()
    }
    
    func emptyTable() {
        tableDisplay.TableArray = []
        updateTableCell()
    }
}
