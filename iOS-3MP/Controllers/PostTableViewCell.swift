//
//  PostTableViewCell.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 20/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

protocol PostTableViewCellDelegate {
    func viewFullPost(_ cell: PostTableViewCell)
}
public class PostTableViewCell: UITableViewCell,UITextViewDelegate,
UITextFieldDelegate {
    
    var db = Firestore.firestore()
    let keychain = DataService().keyChain
    var id = ""
    var likes = 0
    
    @IBOutlet weak var imagePostView: PostView!
    
    
    @IBOutlet weak var likeCount: UILabel!
    
    
    @IBOutlet weak var postText: UITextView!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var postImageheightConstraint: NSLayoutConstraint!
 
    
    @IBOutlet weak var likeHeartImage: UIImageView!
    
    var postCellDelegate: PostTableViewCellDelegate?
    
   
    @IBAction func moreButtonTapped(_ sender: Any) {
        self.postCellDelegate?.viewFullPost(self)
    }
    
    func deleteButtonTapped(){
        
    }
    lazy var doubleTapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        
        tapRecognizer.numberOfTapsRequired = 2
        
        return tapRecognizer
    }()
    
    @objc func didDoubleTap(){
        likeHeartImage.image = UIImage(named: "heart")
        likes += 1
        likeCount.text = String(likes)
        let docRef = db.collection("posts").document(self.id)
        docRef.updateData([
            "likesCount": likes
        ]) { err in
            if let err = err {
                print("Error adding like: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        var plref: DocumentReference? = nil
        plref = self.db.collection("post_likes").addDocument(data: [
            "postId": self.id,
            "userId": self.keychain.get("uid")!
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(plref!.documentID)")
            }
        }
        //likeCount.text = String(Int(likeCount.text)+1)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postText.delegate = self
        //tapForMoreButton.isHidden = true;
        imagePostView.addGestureRecognizer(doubleTapRecognizer)
        likeCount.text = String(likes)
        moreButton.isHidden = true
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
   
}

