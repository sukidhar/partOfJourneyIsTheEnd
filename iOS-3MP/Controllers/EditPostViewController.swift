//
//  EditPostViewController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 02/07/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class EditPostViewController: UIViewController {

    var postContent = "post Content"
    var posTitle = "post Title"
    var imageURL = "url"
    var id = ""
    var db = Firestore.firestore()
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var postTitle: UITextView!
    @IBOutlet weak var postText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postText.text = postContent
        postTitle.text = posTitle
        if imageURL != "url" {
            imageButton.sd_setImage(with:URL(string: imageURL), for: .normal)

        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9960784314, green: 0.5882352941, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        let docRef = db.collection("posts").document(self.id)

        // Set the "capital" field of the city 'DC'
        docRef.updateData([
            "content": postText.text as Any,
            "title" : postTitle.text as Any
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
