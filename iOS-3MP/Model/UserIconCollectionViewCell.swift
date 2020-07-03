//
//  UserIconCollectionViewCell.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 08/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class UserIconCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageVIew: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageVIew.round(corners: .allCorners, cornerRadius: Double(imageVIew.frame.height)/2)
    }

}
