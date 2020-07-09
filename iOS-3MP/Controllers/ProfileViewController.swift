//
//  ProfileViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 13/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var password : String! = ""
    var confirmPass : String = ""
    var oldPasssword : String = ""
    let keychain = DataService().keyChain
    @IBOutlet weak var oldPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var stregnthIndicator: UIProgressView!
    @IBOutlet weak var confirmPassword: SkyFloatingLabelTextField!
    
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var university: UILabel!
    @IBOutlet weak var country: UILabel!
    
    
    
    var imageChanged = false
    
   var testResult : Float = 0.0
   let test = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
   let test1 = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
   let test2 = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
   let test3 = NSPredicate(format: "SELF MATCHES %@",".*[!&^%$#@()/]+.*")
   let test4 = NSPredicate(format: "SELF MATCHES %@", "^.{6,20}$")
    
    
    var entered = false
    var passCheck = false
    var matcher = false
    
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        setLabel(label: nameLabel, meta: "Name : ", data: keychain.get("name")!)
        setLabel(label: email, meta: "Email : ", data: keychain.get("email")!)
        setLabel(label: university, meta: "Institute : ", data: keychain.get("institute")!)
        setLabel(label: country, meta: "Country : ", data: keychain.get("country")!)
        
        profileImageView.round(corners: .allCorners, cornerRadius: Double(profileImageView.frame.height)/2)
        profileImageView.sd_setImage(with: URL(string: keychain.get("profileImage") ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
    }
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
    }
    func canLogin(){
        if Checkers().dateObserver()  < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    
    func goToLoginScreen(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    
    func setLabel(label : UILabel, meta : String, data : String){
        let boldAttribute = [
           NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20.0)!
        ]
        let regularAttribute = [
           NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 20.0)!
        ]
        let boldText = NSAttributedString(string: meta, attributes: boldAttribute)
        let regularText = NSAttributedString(string: data, attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        label.attributedText = newString
    }
    @IBAction func oldPasswordBeingEntered(_ sender: SkyFloatingLabelTextField) {
        oldPasssword = sender.text ?? ""
        sender.errorMessage = ""
    }
    
    @IBAction func oldPasswordEntered(_ sender: SkyFloatingLabelTextField) {
        if oldPasssword.count < 6{
            sender.errorMessage = "Forgot This"
            entered = false
        }
        else{
            sender.errorMessage = ""
            sender.lineColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            entered = true
        }
    }
    @IBAction func passwordEntered(_ sender:
                 SkyFloatingLabelTextField) {
               password = sender.text
               
               // performs all tests and set the results as far as evalution by predicates and regex
               
               var locTest : Float = 0.0
                
               if test.evaluate(with: password) {
                   locTest += 0.2
               }
               
               if test1.evaluate(with: password){
                   locTest += 0.2
               }
               
               if test2.evaluate(with: password){
                   locTest += 0.2
               }
               
               if test3.evaluate(with: password){
                   locTest += 0.2
               }
               
               print(locTest)
               testResult = locTest
               
               if test4.evaluate(with: password)
               {
                   stregnthIndicator.setProgress(testResult + 0.2, animated: true)
               }
               else{
                   stregnthIndicator.setProgress(testResult, animated: true)
               }
               
               if testResult >= 0.4 && test4.evaluate(with: password){
                   passCheck = true
       //            sender.errorMessage = ""
                   sender.lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                   stregnthIndicator.tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
               }
               else if !test4.evaluate(with: password){
                   passCheck = false
                   stregnthIndicator.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
               }
               else{
                   passCheck = false
                   stregnthIndicator.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
               }
               if password.count == 0{
                   passCheck = false
               }
               
             }
             @IBAction func passwordEditingBeginned(_ sender: SkyFloatingLabelTextField) {
               stregnthIndicator.isHidden = false
               sender.errorMessage = ""
             }
             @IBAction func passwordEditingEnded(_ sender: SkyFloatingLabelTextField) {
               stregnthIndicator.isHidden = true
               if passCheck {
                   sender.errorMessage = ""
               }
               else{
                   sender.errorMessage = "Invalid Format"
               }
             }
       @IBAction func confirmPasswordEntering(_ sender: SkyFloatingLabelTextField) {
        confirmPass = sender.text ?? ""
           sender.errorMessage  = ""
       }
       @IBAction func cpasswordEntered(_ sender:
               SkyFloatingLabelTextField) {
           if confirmPass == password {
               sender.errorMessage = ""
               sender.lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
               matcher = true
           }
           else{
               matcher = false
               sender.errorMessage = "Passwords mismatch"
           }
         }
    @IBAction func confirmPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if matcher && passCheck && entered{
            changePassword(email: keychain.get("email")!, currentPassword: oldPasssword, newPassword: password) { (error) in
                if error != nil{
                    let alert = UIAlertController(title: "Oops! Error", message: "Invalid old password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                let alert = UIAlertController(title: "Successful", message: "Password successfully reset to new password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
            
        }
    }
    func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                completion(error)
            }
            else {
                Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                    completion(error)
                })
            }
        })
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        if imageChanged{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
                NotificationCenter.default.post(name: Notification.Name("imagePicked"), object: true)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func editPressed(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.allowsEditing = true
        image.delegate = self
        let alert = UIAlertController(title: "Image Source", message: "Choose from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                image.sourceType = .camera
                self.present(image, animated: true, completion: nil)
            }else{
                print("camera is not available")
            }
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            image.sourceType = .photoLibrary
            self.present(image, animated: true, completion: nil)
        }))
        if keychain.get("profileImage") ?? "default" != "default"{
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                let confirmer = UIAlertController(title: "Delete", message: "Are you sure you want to remove the profile picture", preferredStyle: .alert)
                confirmer.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.profileImageView.image = #imageLiteral(resourceName: "default")
                    Firestore.firestore().collection("USER").document(self.keychain.get("uid")!).getDocument { (snap, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        snap?.reference.updateData(["profileImage" : "default"])
                        self.keychain.set("default", forKey: "profileImage")
                        Storage.storage().reference(forURL: "gs://mpfirebaseproject-7ff28.appspot.com/profileImages").child(self.keychain.get("uid")!).delete { error in
                            if let error = error {
                                print(error)
                            } else {
                               DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name("profileImageUploadedSuccessfully"), object: "default")
                                }
                            }
                        }
                    }
                }))
                confirmer.addAction(UIAlertAction(title: "Cance;", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(confirmer, animated: true, completion: nil)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageChanged = true
        if let image = info[.originalImage] as? UIImage{
            profileImageView.image = image
            
            // image is set. without any failure
            if let imageData = image.jpegData(compressionQuality: 0.6){
                let storage = Storage.storage().reference(forURL: "gs://mpfirebaseproject-7ff28.appspot.com/profileImages").child(keychain.get("uid")!)
                let metadeta = StorageMetadata()
                metadeta.contentType = "image/jpg"
                storage.putData(imageData,metadata: metadeta,completion: {(storageMetadata,error) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    storage.downloadURL { (url,error) in
                    if let error = error{
                            print(error.localizedDescription)
                            return
                    }
                    if let metaUrl = url?.absoluteString{
                            Database.database().reference().child("USER").child(self.keychain.get("uid")!).child("image").setValue(metaUrl)
                            self.keychain.set(metaUrl, forKey: "profileImage")
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name("profileImageUploadedSuccessfully"), object: metaUrl)
                            }
                            Firestore.firestore().collection("USER").document(self.keychain.get("uid")!).getDocument {(snap, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            snap?.reference.updateData(["imageUrl" : metaUrl])
                        }
                        }
                    }
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
