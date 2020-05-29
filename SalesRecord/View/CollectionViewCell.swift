//
//  CollectionViewCell.swift
//  SalesRecord
//
//  Created by James Thang on 5/27/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var priceTag: UILabel!
    
    var drinkData = [String: Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
