//
//  UniversityCollectionViewCell.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 24/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class UniversityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var enclosingView: UIView!
    @IBOutlet weak var containerVIew: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerOfImageVIew: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featherImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       containerOfImageVIew.applyShadowWithCornerRadius(color: .darkGray, opacity: 0.4, radius: 1.5, edge: .Bottom, shadowSpace: 2)
        imageView.layer.cornerRadius = imageView.frame.height/2
        enclosingView.clipsToBounds = true
        enclosingView.layer.masksToBounds = true
    }
    

}
