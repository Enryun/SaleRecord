//
//  CustomTableCell.swift
//  SalesRecord
//
//  Created by James Thang on 5/28/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit

class CustomTableCell: UITableViewCell {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
