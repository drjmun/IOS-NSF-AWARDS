//
//  AwardsTableViewCell.swift
//  NSF Awards
//
//  Created by JLM on 3/10/17.
//  Copyright © 2017 JLM. All rights reserved.
//

import UIKit

class AwardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var awardsCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
