//
//  HomeViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 12/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//
import SideMenu
import UIKit
import FirebaseFirestore
import FirebaseAuth
import KeychainSwift


class HomeViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostTableViewCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let keychain = DataService().keyChain
    var db = Firestore.firestore()
    var posts:[PostModel] = []
    var count = 0
    var clickedPath: IndexPath? = nil
    
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.hidesBottomBarWhenPushed = false
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .done, target: self, action: #selector(pushFromLeftBarButtonItemTapped))
//        loadPosts()
//        for post in posts{
//            print("\(post.content)")
//        }
//        self.tableView.dataSource = self
//        self.tableView.delegate = self
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func showPhotos(_ sender: Any) {
        if  UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker,animated: true,completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage: UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        var attributedString = NSMutableAttributedString()
        let indexPath = NSIndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! NewPostTableViewCell?

        if((cell?.newPostText.text.count)! > 0)
                {
                    attributedString = NSMutableAttributedString(string:(cell?.newPostText.text)!)
                }
                else
                {
                    attributedString = NSMutableAttributedString(string:"What's on your mind?\n")
                }

                let textAttachment = NSTextAttachment()

                textAttachment.image = selectedImage

                let oldWidth:CGFloat = textAttachment.image!.size.width

        let scaleFactor:CGFloat = oldWidth/((cell?.newPostText.frame.size.width)!-50)

                textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)

                let attrStringWithImage = NSAttributedString(attachment: textAttachment)

                attributedString.append(attrStringWithImage)

                cell?.newPostText.attributedText = attributedString
            dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideMenu") as UIViewController
        self.navigationController?.pushViewControllerFromLeft(controller: viewController)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if keychain.getBool("isAmbassador")!{
            return posts.count+1
        }
        else{
            return posts.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //First Cell should be a NewPostTableViewCell for an ambassdor
        if indexPath.row == 0 && keychain.getBool("isAmbassador")!{
                let cell = tableView.dequeueReusableCell(withIdentifier: "newPostTableViewCell") as! NewPostTableViewCell
                // Set up cell.label
                return cell
        }
        else {
            //Remaining Cells should be a PostTableViewCell for users to view
            let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell
            var newPost = PostModel()
            if keychain.getBool("isAmbassador")!{
                newPost = posts[indexPath.row-1]
            }
            else{
                
                newPost = posts[indexPath.row]
            }
            if(newPost.content!.count > 40)
            {
                let str1 = String(newPost.content!.prefix(37))
                let str2 = "....."
//                cell.tapForMoreImg.isHidden = false
                cell.tapForMoreButton.isHidden = false
                
                cell.postText.text = "\(str1) \(str2)"
                let collectionRef = db.collection("USER")
                collectionRef.getDocuments { (querySnapshot, err) in
                    if let docs = querySnapshot?.documents {
                        for docSnapshot in docs {
                            do{
                                if newPost.userId == docSnapshot.documentID{
                                    cell.authorName.text = docSnapshot.data()["name"] as? String
                                }
                            }
                         }
                    }
                }
                //cell.authorName.text = newPost.userId
                cell.likeCount.text = String(newPost.likes!)
                cell.postCellDelegate = self
                //cell.delegate = self
            } else {
                cell.postText.text = newPost.content
                let collectionRef = db.collection("USER")
                collectionRef.getDocuments { (querySnapshot, err) in
                    if let docs = querySnapshot?.documents {
                        for docSnapshot in docs {
                            do{
                                if newPost.userId == docSnapshot.documentID{
                                    cell.authorName.text = docSnapshot.data()["name"] as? String
                                }
                            }
                         }
                    }
                }
                //cell.authorName.text = newPost.userId
                cell.likeCount.text = String(newPost.likes!)
            }
            return cell
        }
    }
    
    func viewFullPost(_ cell: PostTableViewCell) {
        //print("tapForMoreTappedInHome")
        if let indexPath = self.tableView.indexPath(for: cell) {
            clickedPath = indexPath
            performSegue(withIdentifier: "viewFullPost", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFullPost" {
            let postVC = segue.destination as! FullPostViewController
            if let indexPath = clickedPath {
                // get the row
                // access the posts data
                var selectedIndex = posts[0]
                if keychain.getBool("isAmbassador")!{
                    selectedIndex = posts[indexPath.row-1]
                }
                else{
                    selectedIndex = posts[indexPath.row]
                }
                postVC.postContent = selectedIndex.content!
                postVC.userName = selectedIndex.userName!
                postVC.likes = selectedIndex.likes!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        } else {
            return 210
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
        let rotationTranform = CATransform3DTranslate(CATransform3DIdentity, 500, 10, 0)
        cell.layer.transform = rotationTranform
        UIView.animate(withDuration: 1.0) {
            cell.layer.transform = CATransform3DIdentity
            }
        }
    }
    
    
    func loadPosts(){
        // load posts, i.e Posts from database
        let collectionRef = db.collection("posts")
                          collectionRef.getDocuments { (querySnapshot, err) in
                              if let docs = querySnapshot?.documents {
                                  for docSnapshot in docs {
                                      defer{
                                        let newPost = PostModel()
                                        if docSnapshot.data()["content"] != nil{
                                                newPost.content = (docSnapshot.data()["content"] as! String)
                                        }
                                        else{
                                            newPost.content = (docSnapshot.data()["title"] as! String)
                                        }
                                        newPost.title = (docSnapshot.data()["title"] as! String)
                                        newPost.userId = (docSnapshot.data()["userId"] as! String)
                                        newPost.universityID = (docSnapshot.data()["universityId"] as! String)
                                        if docSnapshot.data()["likeCount"] != nil{
                                                newPost.likes = (docSnapshot.data()["likeCount"] as! Int)
                                        }
                                        else{
                                            newPost.likes = 0
                                        }
                                        
                                        let collectionRef = self.db.collection("USER")
                                        collectionRef.getDocuments { (querySnapshot, err) in
                                            if let docs = querySnapshot?.documents {
                                                for docSnapshot in docs {
                                                    do{
                                                        if newPost.userId == docSnapshot.documentID{
                                                            newPost.userName = docSnapshot.data()["name"] as? String
                                                        }
                                                    }
                                                 }
                                            }
                                        }
                                        self.posts.append(newPost)
                                       
                                   DispatchQueue.main.async {
                                       self.tableView.reloadData()
                                      }
                                    }
                                   }

                              }
                   }
                
    }
    
}

extension UINavigationController {
    func pushViewControllerFromLeft(controller: UIViewController) {
        //This function is to bring in the side menu from the left
        //instead of the default right
        //Change the subType to change Direction
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window?.layer.add(transition,forKey: kCATransition)
        pushViewController(controller, animated: false)
    }
    
    func popViewControllerToLeft() {
        //This function is to bring in the pop side menu to the left
        //instead of the default right
        //Change the subType to change Direction
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window?.layer.add(transition,forKey: kCATransition)
        popViewController(animated: false)
    }
}
