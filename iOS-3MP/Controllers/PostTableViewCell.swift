//
//  PostTableViewCell.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 20/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

protocol PostTableViewCellDelegate {
    func viewFullPost(_ cell: PostTableViewCell)
}

public class PostTableViewCell: UITableViewCell,UITextViewDelegate,
UITextFieldDelegate {

    
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var imagePostView: UIImageView!
    

    @IBOutlet weak var tapForMoreButton: UIButton!
    
    @IBOutlet weak var likeHeartImage: UIImageView!
    var postCellDelegate: PostTableViewCellDelegate?
    
    @IBAction func tapForMoreButtonTapped(_ sender: Any) {
        //print("tapForMoreTapped")
        self.postCellDelegate?.viewFullPost(self)
    }
    
    lazy var doubleTapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        
        tapRecognizer.numberOfTapsRequired = 2
        
        return tapRecognizer
    }()
    
    @objc func didDoubleTap(){
        likeHeartImage.image = UIImage(named: "heart")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postText.delegate = self
        tapForMoreButton.isHidden = true;
        imagePostView.addGestureRecognizer(doubleTapRecognizer)
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
   
}

