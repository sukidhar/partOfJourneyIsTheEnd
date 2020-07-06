//
//  LoginZoneViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 31/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import MaterialComponents
import Strongbox
import KeychainSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import Strongbox
import CoreLocation
class LoginZoneViewController: UIViewController {

    
    //MARK: - Variables
    var signInTapped = false
    var eb = false, pb = false
    var email : String!
    var password : String!
    let keychain = DataService().keyChain
    var homeViewController : UITabBarController!
    //MARK: - Outlets

    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var emailField: MDCOutlinedTextField!
    @IBOutlet weak var passwordField: MDCOutlinedTextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - Tap Detection
        //Looks for single or multiple taps.
               let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

               //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
               //tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
        //Set them to Empty from Nil
        email = ""
        password = ""
        
        //Set Titles for TextFields
        emailField.label.text = "Email Address"
        emailField.setFloatingLabelColor(.blue, for: .editing)
        passwordField.label.text = "Password"
        passwordField.setFloatingLabelColor(.blue, for: .editing)
        eyeButton.isHidden = true
        
        homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadToMainScreen), name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
    }
    
    @objc func loadToMainScreen(){
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    //Utility Function of TAP GESTURE
    @objc func dismissKeyboard() {
           //Causes the view (or one of its embedded text fields) to resign the first responder status.
           view.endEditing(true)
       }

    //MARK: - Email Entry Validator Methods
    
    @IBAction func emailEntryFired(_ sender: MDCOutlinedTextField) {
        sender.setOutlineColor(.blue, for: .normal)
        sender.setOutlineColor(.blue, for: .editing)
        sender.leadingAssistiveLabel.isHidden = true
        
    }
    @IBAction func emailEntered(_ sender: MDCOutlinedTextField) {
        email = sender.text?.lowercased()
        sender.leadingAssistiveLabel.isHidden = true
    }
    @IBAction func emailEnteringFinishedOff(_ sender: MDCOutlinedTextField) {
        if isValidEmail(email){
            sender.leadingAssistiveLabel.isHidden = true
            sender.setFloatingLabelColor(#colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1), for: .normal)
            sender.setOutlineColor(#colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1), for: .normal)
            sender.label.textColor = #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1)
            eb =  true
        }
        else{
            sender.leadingAssistiveLabel.isHidden = false
            sender.leadingAssistiveLabel.textColor = .red
            sender.leadingAssistiveLabel.text = "Please check your email Address"
            sender.setOutlineColor(UIColor.red, for: .normal)
            sender.setFloatingLabelColor(.red, for: .normal)
            sender.label.textColor = .red
            eb = false
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK: - Password Entry Validation
    
    @IBAction func passwordSecureFieldEntryToggled(_ sender: UIButton) {
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
        if passwordField.isSecureTextEntry{
            eyeButton.setImage(#imageLiteral(resourceName: "icons8-closed-eye-24"), for: .normal)
        }else{
            eyeButton.setImage(#imageLiteral(resourceName: "icons8-eye-24"), for: .normal)
        }
        passwordField.becomeFirstResponder()
    }

    @IBAction func passwordEntryFiredOff(_ sender: MDCOutlinedTextField) {
        eyeButton.isHidden = false
         eyeButton.setImage(#imageLiteral(resourceName: "icons8-closed-eye-24"), for: .normal)
        sender.setOutlineColor(.blue, for: .normal)
        sender.setOutlineColor(.blue, for: .editing)
        sender.leadingAssistiveLabel.isHidden = true
    }
    @IBAction func passwordEntered(_ sender: MDCOutlinedTextField) {
        sender.leadingAssistiveLabel.isHidden = true
        password = sender.text
    }
    @IBAction func passwordEnteringFinshedOff(_ sender: MDCOutlinedTextField) {
        if password.count >= 6 {
            sender.leadingAssistiveLabel.isHidden = true
            sender.setFloatingLabelColor(#colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1), for: .normal)
            sender.setOutlineColor(#colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1), for: .normal)
            sender.label.textColor = #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8745098039, alpha: 1)
            pb = true
        }
        else{
            sender.leadingAssistiveLabel.isHidden = false
            sender.leadingAssistiveLabel.textColor = .red
            sender.leadingAssistiveLabel.text = "Password cant be shorter than 6 Characters"
            sender.setOutlineColor(UIColor.red, for: .normal)
            sender.setFloatingLabelColor(.red, for: .normal)
            sender.label.textColor = .red
            pb = false
        }
        sender.isSecureTextEntry = true
        eyeButton.isHidden = true
    }
    //MARK: - Sign In Method
    
    @IBAction func signInPressed(_ sender: UIButton) {
            self.view.endEditing(true)
            if  eb && pb{
//                 checks if password and email are not null
                if sender.currentTitle != "Continue"{
                // once the button is clicked if user has to make email verification, the title will be set to Continue, to have some better visual experience, thats why it checks if title hasnt been set to Continue
                Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
    //                tries to sign in with email and password
                            if error == nil{
                                // if no error occured
                                guard let user = Auth.auth().currentUser else{
                                    // if error occured, while getting user, it just returns
                                    return
                                }
                                // verifies user, check code definition for method definition
                                self.verifyUser(user)
                                sender.setTitle("Continue", for: .normal)
                            }
                            else{
                                //incase there's an error, alert is passed to check email or password is invalid
                                let alert = UIAlertController(title: "Alert", message: "Invalid Email Or Password", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                                self.present(alert, animated: true)
                                self.emailField.leadingAssistiveLabel.isHidden = false
                                self.passwordField.leadingAssistiveLabel.isHidden = false
                                self.passwordField.leadingAssistiveLabel.text = "Check your password please"
                    }
                }
            }
//            incase the user is not pressing for first time
            else{
                if let user = Auth.auth().currentUser{
                    //verify the user
                    verifyUser(user)
                }
            }
            }else{
                // if this also fails user will be notified that invalid email and password is entered
                if !eb {
                    self.emailField.setOutlineColor(.red, for: .normal)
                    self.emailField.leadingAssistiveLabel.isHidden = false
                    self.emailField.leadingAssistiveLabel.text = "Please Check You Email"
                }
                if !pb{
                    self.passwordField.setOutlineColor(.red, for: .normal)
                    self.passwordField.leadingAssistiveLabel.isHidden = false
                    self.passwordField.leadingAssistiveLabel.text = "Please Check You Password"
                }
            }
        }
        func verifyUser(_ user : User){
            if(user.isEmailVerified){
                    keychain.set(user.uid, forKey: "uid")
                    getDocument()
                    // sets the value to key chain for uid
                    }
                    else{
                    //incase email is registered but not verified
                        user.sendEmailVerification { (error) in
                        if(error != nil){
                            print("email sent")
                        }
                        else{
                            print(error?.localizedDescription ?? "")
                        }
                        // alert that redirects to default mail app inbox or user will be logged out incase of he was signed in
                        self.presentAlert()
                }
            }
        }
        func presentAlert(){
    //        alert view is added here
            let alert = UIAlertController(title: "Alert", message: "Please Verify through the link sent in mail", preferredStyle: UIAlertController.Style.alert)
            // cancel functionality
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                do{
               try Auth.auth().signOut()
                    //sign out functionality
                }
                catch{
                    print("error signing out")
                }
            }))
            // redirects to default email box
            alert.addAction(UIAlertAction(title: "Check Email", style: .default, handler: { (action) in
                let mailURL = URL(string: "message://")!
                self.LoginButton.setTitle("continue", for: .normal)
                if UIApplication.shared.canOpenURL(mailURL as URL) {
                    UIApplication.shared.open(mailURL as URL, options: [:], completionHandler: nil)
                 }
                }))
            self.present(alert, animated: true)
        }
    func getDocument(){
        
        Firestore.firestore().collection("USER").document(self.keychain.get("uid")!).getDocument { (snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                if let docData = snapshot?.data(){
                    let sb = Strongbox()
                    let data = docData["data"] as? Dictionary<String,Any>
                    if let memberTill = docData["memberTill"] as? Timestamp{
                        let _ = sb.archive(memberTill.seconds ,key: "memberTill")
                    }
                    globalValues.data = data ?? ["":""]
                    self.keychain.set((docData["country"] as? String) ?? "", forKey: "country")
                    let universities = docData["favoriteUnis"] as? [String] ?? []
                    let _ = sb.archive(universities, key: "wishlist")
                    let _ = sb.archive(globalValues.dateOfBirth, key: "dob")
                    let _ = sb.archive(data, key: "data")
                    self.keychain.set((docData["gender"] as? String) ?? "", forKey: "gender")
                    self.keychain.set((docData["profileImage"] as? String) ?? "", forKey: "profileImage")
                    self.keychain.set((docData["isAmbassador"] as? Bool) ?? false, forKey: "isAmbassador")
                    self.keychain.set((docData["name"] as? String) ?? "", forKey: "name")
                    self.keychain.set((docData["phone"] as? String) ?? "", forKey: "phone")
                    self.keychain.set( data?["currentInstitute"] as? String ?? "nil", forKey: "institute")
                    let name = self.keychain.get("name")!
                    let nameComponents = name.split(separator: " ").map({ (substring) in
                        return String(substring)
                    })
                    self.keychain.set(self.email, forKey: "email")
                    self.keychain.set(nameComponents[0], forKey: "firstName")
                    self.keychain.set(nameComponents[1], forKey: "lastName")
                    self.setFcmToken()
                    if self.keychain.getBool("isAmbassador")!{
                        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! UINavigationController
                        let uniVC = self.storyboard?.instantiateViewController(withIdentifier: "UniversityPage") as! UniversityViewController
                           let data = Strongbox().unarchive(objectForKey: "data") as! [String:Any]
                           if let universityId = data["universityId"] as? String{
                               Firestore.firestore().collection("university").document(universityId).getDocument { (snap, error) in
                                   if let error = error{
                                       print(error.localizedDescription)
                                       return
                                   }
                                   if let data = snap?.data(){
                                       if let title = data["name"] as? String, let coordinates = data["location"] as? GeoPoint{
                                           let long = coordinates.longitude
                                           let latt = coordinates.latitude
                                           var departments = data["department"] as? [Dictionary<String,String>]
                                           if departments == nil{
                                               departments = data["department "] as? [[String:String]]
                                           }
                                           let loc = CLLocationCoordinate2D(latitude: latt, longitude: long)
                                           let newUni = UniversityModel(ID: snap!.documentID, description: data["description"] as? String, imageURL: data["image"] as? String ?? "" , title: title, coordinates: loc, address: "", rawDept: departments ?? [[:]], Departments: [Department](), FAQ: data["FAQ link"] as? String ?? "", logo: data["logo"] as? String ?? "", videoURL: data["video"] as? String ?? "")
                                           uniVC.university = newUni
                                           let vc2 = UINavigationController(rootViewController: uniVC)
                                           self.homeViewController.viewControllers = [vc1,vc2] as [UIViewController]
                                           self.homeViewController.tabBar.items?[1].image = #imageLiteral(resourceName: "Icon awesome-university").resize(25 , 25)
                                           self.homeViewController.tabBar.items?[1].title = "My University"
                                        NotificationCenter.default.post(name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
                                        
                                       }
                                   }
                               }
                           }
                       }
                       else{
                        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! UINavigationController
                        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverView") as! UINavigationController
                        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "FavoritesView") as! UINavigationController
                        self.homeViewController.viewControllers = [vc1,vc2,vc3] as [UIViewController]
                        NotificationCenter.default.post(name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
                    }
                }
            }
        }
    }
    func setFcmToken(){
        if let uid = keychain.get("uid"){
            Database.database().reference().child("fcmToken").child(uid).setValue(UserDefaults.standard.string(forKey: "fcmToken"))
        }
    }
}
