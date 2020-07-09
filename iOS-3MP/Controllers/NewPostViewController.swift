//
//  NewPostViewController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 30/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class NewPostViewController: UIViewController,
    UITextViewDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    var db = Firestore.firestore()
    let keychain = DataService().keyChain
    
    @IBOutlet weak var postTitleTextView: UITextView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBAction func uploadImageButtonTapped(_ sender: Any) {
        //imageButton.setImage(UIImage(named: "LoginScreenBackground"), for: .normal)
        let imagecontroller = UIImagePickerController()
        imagecontroller.delegate = self
        imagecontroller.allowsEditing = true
        imagecontroller.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagecontroller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = editedImage
        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = originalImage
        }
        
        imageButton.setImage(selectedImage, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        if (imageButton.currentImage?.isEqual(UIImage(named: "loose")))!{
            var ref: DocumentReference? = nil
            ref = self.db.collection("posts").addDocument(data: [
                "content": self.postTextView.text as Any,
                "createdAt": NSDate(),
                "likesCount" : 0,
                "title": self.postTitleTextView.text as Any,
                "universityId": self.keychain.get("uid")!,
                "userId": self.keychain.get("uid")!
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
        else {
            var uuid = UUID().uuidString
            uuid = uuid.replacingOccurrences(of: "-", with: "")
            let storageRef = Storage.storage().reference().child("postFiles/\(uuid).jpg")
            
            guard let uploadData = self.imageButton.currentImage!.jpegData(compressionQuality: 0.50) else { return }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                if error != nil{
                    print(error as Any)
                    return
                }
                else{
                    storageRef.downloadURL { (url, error) in
                        if error != nil{
                            print(error as Any)
                            return
                        }
                        else {
                            var urlArray = [String]()
                            urlArray.append(url!.absoluteString)
                            var ref: DocumentReference? = nil
                            ref = self.db.collection("posts").addDocument(data: [
                                "content": self.postTextView.text as Any,
                                "createdAt": NSDate(),
                                "likesCount" : 0,
                                "files" : [url?.absoluteString],
                                "title": self.postTitleTextView.text as Any,
                                "universityId": "MIKA6Z0X2z4twp9WTj0M",
                                "userId": self.keychain.get("uid")!
                            ])
                            { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
        
        
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9960784314, green: 0.5882352941, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageButton.setImage(UIImage(named: "loose"), for: .normal)
        postTitleTextView.delegate = self
        postTextView.delegate = self
        postTitleTextView.textColor = UIColor.lightGray
        postTextView.textColor = UIColor.lightGray
        postTitleTextView.layer.cornerRadius = 5
        postTitleTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        postTitleTextView.layer.borderWidth = 0.5
        postTitleTextView.clipsToBounds = true
        
        postTextView.layer.cornerRadius = 5
        postTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        postTextView.layer.borderWidth = 0.5
        postTextView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
