//
//  InventoryController.swift
//  SalesRecord
//
//  Created by James Thang on 7/7/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift


class InventoryController: AlertController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var confirmBtnLabel: UIButton!
    
    private var menuGrandList: Results<MenuDrinKRealm>?

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionLabel.text = "Enable then Click to the Cell for inputting the quantity of each item. After that, select Confirm. Note: Inventory cannot goes below 0. When the remain number hit 0, you cannot sell that item anymore."
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constant.collectionNibName, bundle: nil), forCellWithReuseIdentifier: Constant.collectionCellIdentifier)
        
        loadMenu()
        collectionIsEnable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    

    @IBAction func enableInventoryControl(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: Constant.defaultInventory)
        collectionIsEnable()

    }
    
    @IBAction func disableInventoryControl(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: Constant.defaultInventory)
        collectionIsEnable()

    }
    
    @IBAction func confirmSelect(_ sender: UIButton) {

        // Send data to Firebase
      
//        if interstitial.isReady && !isPurchase(planID: planOneID) {
//            interstitial.present(fromRootViewController: self)
//        }
                
    }
    
    
    func collectionIsEnable() {
        if !UserDefaults.standard.bool(forKey: Constant.defaultInventory) {
            collectionView.isHidden = true
            confirmBtnLabel.isHidden = true
        } else {
            collectionView.isHidden = false
            confirmBtnLabel.isHidden = false
        }
        collectionView.reloadData()
    }
    
    
}

//MARK: - Colletion Method

extension InventoryController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuGrandList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.collectionCellIdentifier, for: indexPath) as! CollectionViewCell
        
        if let item = menuGrandList?[indexPath.row] {
            cell.drinkName.text = item.name
            cell.image.image = loadImageFromDiskWith(fileName: item.name + "james")
        }
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.toInventoryDetail, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! PopUpInventoryController
            
        if let indexPath = collectionView.indexPathsForSelectedItems {
            if let selectItem = menuGrandList?[indexPath[0].row] {
                detailVC.quantity = selectItem.inventoryQuantity.formattedWithSeparator
                detailVC.name = selectItem.name
                detailVC.item = selectItem
            }
        }
            
        detailVC.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
        detailVC.popoverPresentationController?.sourceView = view
        detailVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
    
    
}

//MARK: - Load Data Realm

extension InventoryController {
    func loadMenu() {
        menuGrandList = realm.objects(MenuDrinKRealm.self)
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

