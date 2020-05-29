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
    
    var menu: [MenuItem] = MenuData.coffeeMenu
    
    var tableDisplayData: [TableCellData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
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
    
    
    @IBAction func payPress(_ sender: UIButton) {
        print(tableDisplayData)
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
        return tableDisplayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableCellIdentifier, for: indexPath) as! CustomTableCell
        
        cell.drinkNameLabel.text = tableDisplayData[indexPath.row].drink
        cell.priceLabel.text = tableDisplayData[indexPath.row].price
        
        let quantity = tableDisplayData[indexPath.row].quantity
        let total = tableDisplayData[indexPath.row].total
        
        cell.quantityLabel.text = String(quantity)
        cell.totalLabel.text = String(total)
        
        return cell

    }
}

//MARK: - Content Cell Clicked

extension OrderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = TableCellData(drink: menu[indexPath.item].drinkName, price: menu[indexPath.item].price)

        tableDisplayData.append(selectedCell)
        
        tableView.reloadData()
    }

}
