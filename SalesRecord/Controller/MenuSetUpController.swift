//
//  MenuSetUpController.swift
//  SalesRecord
//
//  Created by James Thang on 6/9/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import RealmSwift


class MenuSetUpController: AlertController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var takenImage: UIImageView!
    @IBOutlet weak var segmentLabel: UISegmentedControl!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkPriceLabel: UILabel!
    @IBOutlet weak var menuName: UITextField!
    @IBOutlet weak var currencyLabel: UITextField!
    
    let menuDefault = UserDefaults.standard
    var menuGrandList: Results<MenuDrinKRealm>?
    
    private var priceValue: Double?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyLabel.text = menuDefault.string(forKey: Constant.defaultCurrency)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuGrandList = realm.objects(MenuDrinKRealm.self)
    }
    

    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        menuName.text = self.menuDefault.string(forKey: "\(segmentLabel.selectedSegmentIndex)")
    }
    
    @IBAction func saveMenuName(_ sender: UIButton) {
        // Create the New Menu
        
        if menuName.text == "" {
            alertUnSuccess(title: "Enter your Menu Name: ", message: "Menu name cannot be Empty")
        } else {
            if self.menuDefault.bool(forKey: "\(segmentLabel.selectedSegmentIndex)") {
                self.menuDefault.removeObject(forKey: "\(segmentLabel.selectedSegmentIndex)")
            }
            
            self.menuDefault.set(menuName.text!, forKey: "\(segmentLabel.selectedSegmentIndex)")
        }
        
        if currencyLabel.text != "" {
            self.menuDefault.set(currencyLabel.text!, forKey: Constant.defaultCurrency)
        } else {
            alertUnSuccess(title: "Empty currency", message: "Please try again!")
        }

    }
    
    @IBAction func addIconSelect(_ sender: UIButton) {
        cameraShot()
//        alertWithTF()
    }
    
    @IBAction func saveItemSelect(_ sender: UIButton) {
        // Append new Drink and Write to Realm
        if drinkPriceLabel.text == "" || drinkNameLabel.text == "" || takenImage.image == UIImage(systemName: "folder.fill.badge.plus") {
            alertUnSuccess(title: "Invalid Number or Empty Drink Name or Image", message: "Try again with valid Data")
        } else {

            if let doublePrice = priceValue, let imageName = drinkNameLabel.text {
                try! realm.write {
                    let newDrink = MenuDrinKRealm()
                    newDrink.id = "\(UUID())"
                    newDrink.position = segmentLabel.selectedSegmentIndex
                    newDrink.name = imageName
                    newDrink.price = doublePrice
                    realm.add(newDrink)
                }
                saveImage(imageName: imageName + "james", image: takenImage.image!)
            }
        }
//
//        if interstitial.isReady && !self.isPurchase(planID: self.planOneID) {
//            interstitial.present(fromRootViewController: self)
//        }
        
        resetSample()
    }
    
    
    @IBAction func removeItemSelect(_ sender: UIButton) {
        deleteMenuItem()
    }
    
    
    @IBAction func promotion(_ sender: UIButton) {
        promotionItem()
    }
}



//MARK: - Camera

extension MenuSetUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            takenImage.image = image
        } else {
            alertUnSuccess(title: "Unsuccess taken Image", message: "Try again!")
        }
        

        self.dismiss(animated: true, completion: nil)
        
        alertWithTF()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cameraShot() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
    }
    
    func saveImage(imageName: String, image: UIImage) {

     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }

    }
}


//MARK: - Alert and Reset functions

extension MenuSetUpController {
    
    func alertWithTF() {
        
        let alert = UIAlertController(title: "Enter Item Name and Item Price", message: "Please input something", preferredStyle: UIAlertController.Style.alert )
        
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let textField2 = alert.textFields![1] as UITextField
            
            if textField.text != "" && textField2.text != "" {
                if let doublePrice = Double(textField2.text!) {
                    self.priceValue = doublePrice
                    self.drinkPriceLabel.text = doublePrice.formattedWithSeparator
                } else {
                    self.alertUnSuccess(title: "Invalid Price", message: "Please enter a Number!")
                    return
                }
                self.drinkNameLabel.text = textField.text!

            } else {
                self.alertUnSuccess(title: "Empty Name or Empty Price", message: "Please Enter Valid name or price!")
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Item Name: "
            textField.textColor = .red
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Price: "
            textField.textColor = .blue
        }
        alert.addAction(save)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
    
        self.present(alert, animated:true, completion: nil)
    }
    
    
    func resetSample() {
           drinkNameLabel.text = ""
           drinkPriceLabel.text = ""
           takenImage.image = UIImage(systemName: "folder.fill.badge.plus")
    }
}

//MARK: - Delete and Promotion

extension MenuSetUpController {
    func deleteMenuItem() {

        let alert = UIAlertController(title: "Enter Correct Item Name: ", message: "Has to match perfectly every letter", preferredStyle: UIAlertController.Style.alert )
        
        let enter = UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            if let deleteItem = self.menuGrandList?.filter("name == %@", textField.text!) {
                try! self.realm.write {
                    self.realm.delete(deleteItem)
                }
                
//                if self.interstitial.isReady && !self.isPurchase(planID: self.planOneID) {
//                    self.interstitial.present(fromRootViewController: self)
//                }
            } else {
                self.alertUnSuccess(title: "Item not found!", message: "Item Name has to match perfectly every letter!")
            }
            
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Item Name"
        }

        alert.addAction(enter)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)
    }
    
    func promotionItem() {
        let alert = UIAlertController(title: "Enter Correct Item Name and Discount %: ", message: "Item Name has to match perfectly every letter", preferredStyle: UIAlertController.Style.alert )
        
        let save = UIAlertAction(title: "Enable", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let textField2 = alert.textFields![1] as UITextField
            
            if textField.text != "" && textField2.text != "" {
                if let discountPercent = Double(textField2.text!) {
                    if discountPercent > 100 || discountPercent < 0 {
                        self.alertUnSuccess(title: "Discount % Invalid!", message: "Only between 0 and 100")
                        return
                    }
                    
                    if let promoItem = self.menuGrandList?.filter("name == %@", textField.text!) {
                        try! self.realm.write {
                            promoItem.first?.promoPercent = discountPercent
                        }
                    } else {
                        self.alertUnSuccess(title: "Item not found", message: "Please Enter exacly Item Name!")
                    }
                    
                } else {
                    self.alertUnSuccess(title: "Discount % is not a Number", message: "Please Enter valid number!")
                }
                
                
                
//                if self.interstitial.isReady && !self.isPurchase(planID: self.planOneID) {
//                    self.interstitial.present(fromRootViewController: self)
//                }
                
            } else {
                self.alertUnSuccess(title: "Empty Name or Empty Discount %", message: "Please Enter Valid name or price!")
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item Name: "
            textField.textColor = .red
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Discount(%): "
            textField.textColor = .blue
        }
        alert.addAction(save)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
}
