//
//  ChatMessageCell.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 28/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    

    
    static let grayColor = UIColor( red: CGFloat(240/255.0), green: CGFloat(240/255.0), blue: CGFloat(240/255.0), alpha: CGFloat(1.0))
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var timestamp : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.font = label.font.withSize(8)
        return label
    }()
    
    var seenStatus : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.font = label.font.withSize(13)
        return label
    }()
    
    var statusBulb : UIView = {
        let bulb = UIView()
        bulb.layer.cornerRadius = 4
        bulb.translatesAutoresizingMaskIntoConstraints = false
        bulb.layer.masksToBounds = true
        bulb.backgroundColor = .gray
        return bulb
    }()
    
    var textViewRightAnchor : NSLayoutConstraint?
    var textViewWidthAncor : NSLayoutConstraint?
    var textViewHeightAnchor : NSLayoutConstraint?
    var textViewLeftAnchor: NSLayoutConstraint?
    
    var id : String?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)
        addSubview(profileImageView)
        self.isUserInteractionEnabled = true
        let imageHolder = UIView()
        addSubview(imageHolder)
        imageHolder.translatesAutoresizingMaskIntoConstraints = false
        imageHolder.backgroundColor = .clear
        imageHolder.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        imageHolder.bottomAnchor.constraint(equalTo: textView.bottomAnchor,constant: -15).isActive = true
        imageHolder.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageHolder.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageHolder.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: imageHolder.leftAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: imageHolder.bottomAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        imageHolder.addSubview(statusBulb)
        statusBulb.centerXAnchor.constraint(equalTo: imageHolder.centerXAnchor, constant: 14).isActive = true
        statusBulb.centerYAnchor.constraint(equalTo: imageHolder.centerYAnchor, constant: -14).isActive = true
        statusBulb.widthAnchor.constraint(equalToConstant: 8).isActive = true
        statusBulb.heightAnchor.constraint(equalToConstant: 8).isActive = true
        //
        textViewRightAnchor = textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12)
        textViewRightAnchor?.isActive = true
        textViewLeftAnchor = textView.leftAnchor.constraint(equalTo: self.profileImageView.rightAnchor, constant: 8)
        textView.isSelectable = false
        if #available(iOS 13.0, *) {
            textView.backgroundColor = .systemGray2
        } else {
            // Fallback on earlier versions
        }
        textView.textContainerInset = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textViewWidthAncor = textView.widthAnchor.constraint(equalToConstant: 230)
        textViewWidthAncor?.isActive = true
        textViewHeightAnchor = textView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0)
        textViewHeightAnchor?.isActive = true
        
        addSubview(timestamp)
        timestamp.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        timestamp.leftAnchor.constraint(equalTo: self.textView.leftAnchor, constant: 10).isActive = true
        timestamp.rightAnchor.constraint(equalTo: self.textView.rightAnchor, constant: -10).isActive = true
        timestamp.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
