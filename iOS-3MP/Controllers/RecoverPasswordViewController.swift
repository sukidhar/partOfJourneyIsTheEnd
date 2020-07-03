//
//  RecoverPasswordViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 31/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class RecoverPasswordViewController: UIViewController {
    
    @IBOutlet weak var email: SkyFloatingLabelTextField!

       var emailT : String!
       var e = false
       let emailPred = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
      
       
       override func viewDidLoad() {
           super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
           
       }
       //Utility Function of TAP GESTURE
    @objc func dismissKeyboard() {
              //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func emailFieldEntering(_ sender: SkyFloatingLabelTextField) {
        emailT = sender.text?.lowercased()
        sender.errorMessage = ""
    }
    @IBAction func emailEntered(_ sender: SkyFloatingLabelTextField) {
            if emailPred.evaluate(with: emailT){
                sender.lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                sender.errorMessage = ""
                e = true
            }
            else{
                e = false
                sender.errorMessage = "Invalid Email"
            }
       }
       @IBAction func ResetPasswordClicked(_ sender: UIButton) {
           if e {
               Auth.auth().sendPasswordReset(withEmail: emailT) { (error) in
                   if let error = error{
                       print(error.localizedDescription)
                       let alert = UIAlertController(title: "Alert", message: "Oops! seems like no user exists with this email", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                       self.present(alert, animated: true)
                    return
                   }
                    self.performSegue(withIdentifier: "password", sender: self)
               }
           }
       }
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//let alert = UIAlertController(title: "Alert", message: "Please reset through the link sent in mail", preferredStyle: UIAlertController.Style.alert)
// alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
//     alert.dismiss(animated: true, completion: nil)
// }))
//alert.addAction(UIAlertAction(title: "Check Email", style: .default, handler: { (action) in
//    defer{
//    self.navigationController?.popViewController(animated: true)
//    }
//    let mailURL = URL(string: "message://")!
//    if UIApplication.shared.canOpenURL(mailURL as URL) {
//       UIApplication.shared.open(mailURL as URL, options: [:], completionHandler: nil)
//    }
//    }))
//    self.present(alert, animated: true)
