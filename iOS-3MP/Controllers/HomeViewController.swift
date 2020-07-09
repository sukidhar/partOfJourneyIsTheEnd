//
//  HomeViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 12/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import KeychainSwift
import SDWebImage
import Strongbox

class HomeViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostTableViewCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let sb = Strongbox()
    
    let keychain = DataService().keyChain
    var db = Firestore.firestore()
    var posts:[PostModel] = []
    var count = 0
    var clickedPath: IndexPath? = nil
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9960784314, green: 0.5882352941, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globalValues.universties = sb.unarchive(objectForKey: "wishlist") as? [String] ?? []
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.tabBar.isHidden = false
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        loadPosts()
        //print("Universities-")
        //print(globalValues.universties)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 210
        self.tableView.rowHeight = UITableView.automaticDimension
        
       
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
            cell.postCellDelegate = self
            let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
            
            cell.postImage.addGestureRecognizer(imageTap)
            
            if newPost.userId == keychain.get("uid")
            {
                cell.moreButton.isHidden = false
            }
            
            cell.id = newPost.id!
            if(newPost.image != nil)
            {
                
                cell.postImage.isHidden = false
                cell.postImageheightConstraint.constant = 77.0
                
                let pic = newPost.image
                let url = URL(string: pic!)
                
                cell.postImage.layer.cornerRadius = 10
                cell.postImage.layer.borderWidth = 3
                cell.postImage.layer.borderColor = UIColor.white.cgColor
                
                cell.postImage.sd_setImage(with: url, completed: nil)
            }
            else{
                cell.postImage.isHidden = true
                cell.postImageheightConstraint.constant = 0
            }
            cell.likes = newPost.likes!
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
                //cell.likeCount.text = String(newPost.likes!)
            //}
            return cell
        }
    }
    
    @objc func didTapImage(sender: UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        
    }
    
    @objc func dismissFullScreenImage(sender:UITapGestureRecognizer)
    {
        sender.view?.removeFromSuperview()
    }
    
    func viewFullPost(_ cell: PostTableViewCell) {
        //print("tapForMoreTappedInHome")
        if let indexPath = self.tableView.indexPath(for: cell) {
            clickedPath = indexPath
            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPostViewController") as! EditPostViewController
            var selectedIndex = posts[0]
            if keychain.getBool("isAmbassador")!{
                selectedIndex = posts[indexPath.row-1]
            }
            else{
                selectedIndex = posts[indexPath.row]
            }
            if selectedIndex.content != nil{
                postVC.postContent = selectedIndex.content!
            }
            else {
                postVC.postContent = ""
            }
            
            if selectedIndex.title != nil {
                postVC.posTitle = selectedIndex.title!
            }
            if selectedIndex.image != nil {
                postVC.imageURL = selectedIndex.image!
            }
            else {
                postVC.imageURL = ""
            }
            postVC.id = selectedIndex.id!
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let postVC = segue.destination as! EditPostViewController
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
                
                if selectedIndex.content != nil{
                    postVC.postContent = selectedIndex.content!
                }
                else {
                    postVC.postContent = ""
                }
                
                if selectedIndex.title != nil {
                    postVC.posTitle = selectedIndex.title!
                }
                else {
                    postVC.posTitle = ""
                }
                
                if selectedIndex.image != nil {
                    postVC.imageURL = selectedIndex.image!
                }
                else {
                    postVC.imageURL = ""
                }
                postVC.id = selectedIndex.id!
//                postVC.userName = selectedIndex.userName!
//                postVC.likes = selectedIndex.likes!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        } else {
            return UITableView.automaticDimension
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
        let collectionRef = db.collection("posts").order(by: "createdAt", descending: true)
                          collectionRef.getDocuments { (querySnapshot, err) in
                              if let docs = querySnapshot?.documents {
                                  for docSnapshot in docs {
                                    do{
                                        let newPost = PostModel()
                                        newPost.id = docSnapshot.documentID
                                        if docSnapshot.data()["content"] != nil{
                                                newPost.content = (docSnapshot.data()["content"] as! String)
                                        }
                                        else{
                                            newPost.content = ""
                                        }
                                        newPost.title = (docSnapshot.data()["title"] as! String)
                                        newPost.userId = (docSnapshot.data()["userId"] as! String)
                                        newPost.universityID = (docSnapshot.data()["universityId"] as! String)
                                        if docSnapshot.data()["files"] != nil{
                                            let imageArray = docSnapshot.data()["files"]! as! [Any]
                                            //print(imageArray[0])
                                            newPost.image = (imageArray[0] as! String)
                                        }
                                        else{
                                            newPost.image = nil
                                        }
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
                                        
                                        if(globalValues.universties.contains(newPost.universityID!))
                                        {
                                            self.posts.append(newPost)
                                        }
                                       
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
        view.window!.layer.add(transition,forKey: kCATransition)
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
        view.window!.layer.add(transition,forKey: kCATransition)
        popViewController(animated: false)
    }
}

extension UITableViewCell{
    func shadowAndBorderForCell(yourTableViewCell : UITableViewCell){
            // SHADOW AND BORDER FOR CELL
            //yourTableViewCell.contentView.layer.cornerRadius = 5
            yourTableViewCell.contentView.layer.borderWidth = 0.5
            yourTableViewCell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            yourTableViewCell.contentView.layer.masksToBounds = true
            yourTableViewCell.layer.shadowColor = UIColor.gray.cgColor
            yourTableViewCell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            yourTableViewCell.layer.shadowRadius = 2.0
            yourTableViewCell.layer.shadowOpacity = 1.0
            yourTableViewCell.layer.masksToBounds = false
            yourTableViewCell.layer.shadowPath = UIBezierPath(roundedRect:yourTableViewCell.bounds, cornerRadius:yourTableViewCell.contentView.layer.cornerRadius).cgPath
            }
}



