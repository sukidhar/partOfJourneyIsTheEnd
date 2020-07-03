//
//  HeaderCollectionView.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 21/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
class HeaderCollectionView: UICollectionReusableView {
    
    var user : UserModel?{
        didSet{
            profileImageView.sd_setImage(with: URL(string: user?.imageUrl ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
            nameLabel.text = user?.name
            status()
        }
    }
    private func status(){
        if let id = user?.id{
        Database.database().reference().child("USER").child(id).observe(.value) { (snap) in
                if let data = snap.value as? [String : Any]{
                    if data["status"] as? String ?? "offline" == "online"{
                        self.statusBulb.backgroundColor = .green
                    }
                    else{
                        self.statusBulb.backgroundColor = .gray
                    }
                }
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(statusBulb)
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        statusBulb.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 30).isActive = true
//        statusBulb.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -30).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true

    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.image = UIImage(named: "default")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont(name:"HelveticaNeue-Bold", size: 22.0)
        name.layer.masksToBounds = true
        name.numberOfLines = 0
        return name
    }()

    let statusBulb : UIView = {
        let bulb = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2 + 20,y : 15, width: 10, height: 10))
        bulb.layer.cornerRadius = 5
        bulb.translatesAutoresizingMaskIntoConstraints = false
        bulb.layer.masksToBounds = true
        bulb.backgroundColor = .gray
        return bulb
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
