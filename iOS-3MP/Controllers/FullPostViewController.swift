//
//  FullPostViewController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 06/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class FullPostViewController: UIViewController {
    
    var postContent = "post Content"
    var userName = "author Name"
    var userId = "userID"
    var likes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postText.text = postContent
        authorName.text = userName
        likeCount.text = String(likes)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var postText: UITextView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
