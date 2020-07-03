//
//  UserCell.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import KeychainSwift

class UserCell: UITableViewCell{
    
    let keychain = DataService().keyChain
    let db = Firestore.firestore()
    
    var partner : Partner?{
        didSet{
            setupNameAndProfileImage()
            status()
            self.textLabel?.text = partner?.name
            if let partner = partner{
                let date = Date(timeIntervalSince1970: partner.lastActive/1000)
                timeLabel.text = relativePast(for: date)
            }
            setDetailedText()
        }
    }
    
    private func setDetailedText(){
        if let partner = partner {
            Database.database().reference().child("chats").child(partner.chatID).queryLimited(toLast: 1).observe(.childAdded) { (snap) in
                if let data = snap.value as? [String:Any]{
                    let string = data["sender"] as! String
                    if string == self.keychain.get("uid"){
                        self.detailTextLabel?.text = "Me : \(data["content"] as! String)"
                    }else{
                        self.detailTextLabel?.text = "\(data["content"] as! String)"
                    }
                }
            }
        }
    }
    
    private func setupNameAndProfileImage(){
        
        if let realPartner = partner{
            db.collection("USER").document(realPartner.id).getDocument { (snap, error) in
                if let doc = snap?.data(){
                    self.profileImageView.sd_setImage(with: URL(string: doc["imageUrl"] as? String ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
                }
            }
        }
    }
    
    private func status(){
        if let realPartner = partner{
            Database.database().reference().child("USER").child(realPartner.id).observe(.value) { (snap) in
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let timeLabel : UILabel = {
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = timeLabel.font.withSize(10)
        timeLabel.layer.masksToBounds = true
        return timeLabel
    }()
    let statusBulb : UIView = {
        let bulb = UIView(frame: CGRect(x: 46, y: 12, width: 10, height: 10))
        bulb.layer.cornerRadius = 5
        bulb.translatesAutoresizingMaskIntoConstraints = false
        bulb.layer.masksToBounds = true
        bulb.backgroundColor = .gray
        return bulb
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(timeLabel)
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        timeLabel.textColor = .black

        addSubview(statusBulb)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func relativePast(for date : Date) -> String {

        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())

        if components.year! > 0 {
            return "\(components.year!) " + (components.year! > 1 ? "years ago" : "year ago")

        } else if components.month! > 0 {
            return "\(components.month!) " + (components.month! > 1 ? "months ago" : "month ago")

        } else if components.weekOfYear! > 0 {
            return "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks ago" : "week ago")

        } else if (components.day! > 0) {
            return (components.day! > 1 ? "\(components.day!) days ago" : "Yesterday")

        } else if components.hour! > 0 {
            return "\(components.hour!) " + (components.hour! > 1 ? "hours ago" : "hour ago")

        } else if components.minute! > 0 {
            return "\(components.minute!) " + (components.minute! > 1 ? "minutes ago" : "minute ago")

        } else {
            return "\(components.second!) " + (components.second! > 1 ? "seconds ago" : "second ago")
        }
    }
}

