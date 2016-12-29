//
//  MainCell.swift
//  Rabbit Food
//
//  Created by Chris on 7/6/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var food: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
