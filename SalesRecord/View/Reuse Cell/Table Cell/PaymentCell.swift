//
//  PaymentCell.swift
//  SalesRecord
//
//  Created by James Thang on 7/16/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var oldLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
