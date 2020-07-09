//
//  DepartmentCollectionViewCell.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 06/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class DepartmentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var crestImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.borderWidth = 1.0
        mainView.layer.borderColor = UIColor.clear.cgColor
    }

}
