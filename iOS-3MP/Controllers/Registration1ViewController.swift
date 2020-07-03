//
//  RegistrationViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 12/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
import GoogleSignIn
import FBSDKLoginKit


class RegistrationViewController: UIViewController, LoginButtonDelegate {
    
    let db = Firestore.firestore()
    
    let keychain = DataService.init().keyChain
    var email : String!
    var name : String!
    var password : String!
    @IBOutlet weak var passWordConditions: UILabel!
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    var signUpTapped = false
    @IBOutlet weak var OTPField: SkyFloatingLabelTextField!

    @IBOutlet weak var RegisterButton : UIButton!
    var fbLoginButton = FBLoginButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        //google sign in setup
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //facebook sign in setup

        fbLoginButton.isHidden = true
        fbLoginButton.permissions = ["public_profile", "email"]
        fbLoginButton.delegate = self
        
        //Basic Checks
        checkName(nameField, UIColor.white, error: "")
        checkEmail(emailField, UIColor.white, error: "")
        checkPassword(passwordField, UIColor.white, error: "")
        

    
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    //MARK: - email
    @IBAction func emailEntered(_ sender: SkyFloatingLabelTextField) {
        
        sender.errorMessage = ""
        checkEmail(sender,UIColor.red, error: "Invalid Email")
    }
    func checkEmail(_ sender : SkyFloatingLabelTextField, _ color : UIColor, error : String){
        if let text = sender.text{
            if text.contains("@") && text.hasSuffix(".com"){
                email = text;
                sender.lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
            else{
                sender.errorMessage = error
                sender.errorColor = color
            }
        }
    }
    //MARK: - name
    @IBAction func nameEntered(_ sender: SkyFloatingLabelTextField) {
        sender.errorMessage = ""
        checkName(sender, UIColor.red, error: "Invalid Name")
        
        
    }
    func checkName(_ sender : SkyFloatingLabelTextField, _ color : UIColor, error : String){
        
        if let text = sender.text{
            name = text
            sender.errorColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        else{
            sender.errorMessage = error
            sender.errorColor = color
        }
    }
    //MARK: - password
    @IBAction func passwordEntered(_ sender:
        SkyFloatingLabelTextField) {
        sender.errorMessage = ""
        checkPassword(sender,UIColor.red, error: "Invalid Password")
  
    }
    @IBAction func passwordEditingBeginned(_ sender: SkyFloatingLabelTextField) {
        passWordConditions.isHidden = false
    }
    @IBAction func passwordEditingEnded(_ sender: SkyFloatingLabelTextField) {
        passWordConditions.isHidden = true
    }
    
    func checkPassword(_ sender : SkyFloatingLabelTextField, _ color : UIColor, error : String){
        if let text = sender.text{
            if text.count >= 6{
                password = text;
                sender.lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
            else{
                sender.errorMessage = error
                sender.errorColor = color
            }
        }
    }
    
    //MARK: - sign up button
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        if let safeEmail = email, let safePassword = password {
            
            Auth.auth().createUser(withEmail: safeEmail, password: safePassword) { (authResult, error) in
                
                // if an error occurs while creating user, it is most probably that user is already registered
                if error != nil {
                    //user is registered
                    //tiny bug, if email isnt verified but registered , he can again use this method to sign in
                    Auth.auth().signIn(withEmail: safeEmail, password: safePassword) { (result, error) in
                        if error == nil{
                        // no error, which means user registered and asked for verification
                        if let user = Auth.auth().currentUser {
                            // email verification successful and segue
                            if(user.isEmailVerified){
                                self.keychain.set(user.uid, forKey: "uid")
                                self.keychain.set(safeEmail, forKey: "email")
                                self.keychain.set(safePassword, forKey: "password")
                                self.createUserDocumentInDB(email: safeEmail)
                                self.performSegue(withIdentifier: "registrationToHomePage", sender: nil)
                            }
                        }
                        }else{
                            // user is alredy created and trying to create account again
                            //alert for prompting user is already existing and redirect to home page if user wants to login
                            let alert = UIAlertController(title: "SignUpError❌", message: "User Already Exists", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                                do{try Auth.auth().signOut()}
                                catch{
                                    print("error signing out")
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "Login?", style: .default, handler: {(action) in
                                // dismiss the view
                                self.dismiss(animated: true) {
                                    do{ try Auth.auth().signOut()}
                                     catch{
                                         print("error signing out")
                                     }
                                }
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
                else{
                    // user newly registered so prompt for email verification
                    guard let user = Auth.auth().currentUser else{return}
                    // verify user via email
                    user.sendEmailVerification { (error) in
                        if(error != nil){
                            print("email sent")
                        }
                        else{
                            print(error?.localizedDescription ?? "")
                        }
                        // alert to handle email verification
                        let alert = UIAlertController(title: "Alert", message: "Please Verify through the link sent in mail", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                            do{
                           try Auth.auth().signOut()
                            }
                            catch{
                                print("error signing out")
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Check Email", style: .default, handler: { (action) in
                            let mailURL = URL(string: "message://")!
                            self.RegisterButton.setTitle("continue", for: .normal)
                            if UIApplication.shared.canOpenURL(mailURL as URL) {
                                UIApplication.shared.open(mailURL as URL, options: [:], completionHandler: nil)
                             }
                            }))
                        self.present(alert, animated: true)
                        }
                    }
                }
        }else{
            // incase blank fields are tried to create sign up process
            if emailField.text == nil{
                emailField.errorMessage = "Invalid Email"
            }
            if passwordField.text == nil{
                passwordField.errorMessage = "Invalid Password"
            }
        }
    }
 //MARK: - google sign in
    @IBAction func GoogleSignInPressed(_ sender: UIButton) {
        //we are not having default button provided by google so implemented this
        GIDSignIn.sharedInstance()?.signIn()
    }
    //MARK: - gacebook sign in
    @IBAction func FaceBookButttonPressed(_ sender: UIButton) {
        //since its a cutsom button, we are sending an event
        fbLoginButton.sendActions(for: .touchUpInside)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil{
            print(error?.localizedDescription ?? "")
            return
        }
        
        let accessToken = AccessToken.current
        
        guard let token = accessToken?.tokenString else {
            return
        }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: token)
        
        var FBEmail : String!
        Auth.auth().signIn(with: credentials) { (result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
                return
            }
            guard let uid = result?.user.uid else { return }
            self.keychain.set(uid, forKey: "uid")
            GraphRequest(graphPath: "/me", parameters: ["fields" : "id,name,email"]).start { (connection, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else{
                DispatchQueue.main.async {

                    if let saferesponse = response as? Dictionary<String, String>{
                        FBEmail = saferesponse["email"] ?? saferesponse["id"]!
                    }
                    self.keychain.set(FBEmail, forKey: "email")
                    self.createUserDocumentInDB(email: FBEmail)
                    }
                }
            }
            self.performSegue(withIdentifier: "registrationToHomePage", sender: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did Log out")
    }
    
    func createUserDocumentInDB(email : String){
        
        db.collection("USER").document(email).setData([
                                    "email" : email,
                                    "imageURL" : "default",
                                    "id" : self.keychain.get("uid")! ,
                                    "flag" : true,
                                    "WishList" : [String]()
                                ], merge: true)
        
    }
}
