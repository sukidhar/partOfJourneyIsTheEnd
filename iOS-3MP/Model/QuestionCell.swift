//
//  QuestionCell.swift
//  iOS-3MP
//
//  Created by Mac on 28/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
