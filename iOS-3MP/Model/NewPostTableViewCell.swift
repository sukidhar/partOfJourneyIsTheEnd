//
//  NewPostTableViewCell.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 20/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import KeychainSwift

public class NewPostTableViewCell:
    UITableViewCell,
    UITextViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
   
    var db = Firestore.firestore()
    let keychain = DataService().keyChain
        

    @IBOutlet weak var uniName: UILabel!
    @IBOutlet weak var newPostText: UITextView!
    @IBOutlet weak var authorName: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func postButtonClicked(_ sender: Any) {
        var imagesArray = [AnyObject]()
        self.newPostText.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, newPostText.text.count), options: []) { (value, range, true) in
            
            if(value is NSTextAttachment)
             {
                 let attachment = value as! NSTextAttachment
                 var image : UIImage? = nil
                 
                 if(attachment.image !== nil)
                 {
                     image = attachment.image!
                     imagesArray.append(image!)
                 }
                 else
                 {
                     print("No image found")
                 }
             }
        }
        
        let postLength = newPostText.text.count
        let numImages = imagesArray.count
        let key = UUID().uuidString
        let storageRef = Storage.storage().reference()
        let picRef = storageRef.child("postFiles/\(key)")
        
        
        if (postLength>0 && numImages>0)
        {
        let lowResImageData = (imagesArray[0] as! UIImage).jpegData(compressionQuality: 0.50)
         
            let uploadTask = picRef.putData(lowResImageData!,metadata: nil, completion: { (metadata, error) in

             if error != nil, metadata != nil {
                 print(error ?? "")
                 return

             }

             picRef.downloadURL(completion: { (url, error) in
                 if error != nil {
                     print(error!.localizedDescription)
                     return
                 }
                if let postImageUrl = url?.absoluteString {
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("posts").addDocument(data: [
                        "content": self.newPostText.text as Any,
                        "createdAt": NSDate(),
                        "likesCount" : 0,
                        "title": "Title",
                        "universityId": "MIKA6Z0X2z4twp9WTj0M",
                        "files":postImageUrl,
                        "userId": self.keychain.get("uid")!
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                 }
             })
         })
        }
        else if(postLength > 0)
        {
            var ref: DocumentReference? = nil
            ref = self.db.collection("posts").addDocument(data: [
                "content": self.newPostText.text as Any,
                "createdAt": NSDate(),
                "likesCount" : 0,
                "title": "Title",
                "universityId": "MIKA6Z0X2z4twp9WTj0M",
                "userId": self.keychain.get("uid")!
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
        else if(numImages>0)
        {
            let lowResImageData = (imagesArray[0] as! UIImage).jpegData(compressionQuality: 0.50)
            
            let uploadTask = picRef.putData(lowResImageData!,metadata: nil, completion: { (metadata, error) in

                if error != nil, metadata != nil {
                    print(error ?? "")
                    return

                }

                picRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                   if let postImageUrl = url?.absoluteString {
                       var ref: DocumentReference? = nil
                       ref = self.db.collection("posts").addDocument(data: [
                           "content": "" as Any,
                           "createdAt": NSDate(),
                           "likesCount" : 0,
                           "title": "Title",
                           "universityId": "MIKA6Z0X2z4twp9WTj0M",
                           "files":postImageUrl,
                           "userId": self.keychain.get("uid")!
                       ]) { err in
                           if let err = err {
                               print("Error adding document: \(err)")
                           } else {
                               print("Document added with ID: \(ref!.documentID)")
                           }
                       }
                    }
                })
            })
        }
            
        
        
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

    @IBAction func selectPhotos(_ sender: Any) {
        //open the photo gallery
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            //self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //uniName.text = keychain.get("institute")
        //authorName.text = "Yash Agrawal"
        //authorName.text = "\(keychain.get("firstName")!) \(keychain.get("lastName")!)"
        newPostText.delegate = self
        newPostText.textColor = UIColor.lightGray

    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        
    }

}
