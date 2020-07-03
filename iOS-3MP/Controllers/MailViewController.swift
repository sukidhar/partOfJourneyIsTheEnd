//
//  MailViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 02/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class MailViewController: UIViewController {

    var selectedCourses : [String]?
    var selectedNames :  [String]?
    
    let keychain = DataService().keyChain
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
       
        let user = Auth.auth().currentUser
        if user != nil{
            user?.reload(completion: { (error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                self.keychain.set(user!.uid, forKey: "uid")
                self.createUserDocumentInDB(email: self.keychain.get("email")!)
                if user!.isEmailVerified{
                    self.performSegue(withIdentifier: "onboard", sender: nil)
                    }
                    else{
                    let alert = UIAlertController(title: "Request", message: "Please verify your email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Check Email", style: .default, handler: { (action) in
                    let mailURL = URL(string: "message://")!
                    defer{
                            sender.setTitle("Continue", for: .normal)
                    }
                    if UIApplication.shared.canOpenURL(mailURL as URL) {
                        UIApplication.shared.open(mailURL as URL, options: [:], completionHandler: nil)
                     }
                    }))
                    self.present(alert, animated: true)
                    }
                }
            )
        }
    }
    func createUserDocumentInDB(email : String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.date(from: keychain.get("dob")!)
        
        print(keychain.get("isAmbassador")!)
     keychain.set("\(keychain.get("firstName")!) \(keychain.get("lastName")!)", forKey: "name")
     
        Firestore.firestore().collection("USER").document(self.keychain.get("uid")!).setData([
            "data" : ["averageMarks" : Int(keychain.get("avgMarks") ?? "") ?? "", "coursesOfInterest" : selectedCourses ?? [], "countriesOfInterest" : selectedNames ?? [], "currentInstitute" : keychain.get("institute") ?? "", "type" : keychain.get("type") ?? "" ],
            "dateOfBirth" : date!,
            "email" : keychain.get("email")!,
            "gender" : keychain.get("gender")! as String,
            "isAmbassador" : keychain.getBool("isAmbassador")!,
            "name" : keychain.get("name")!,
            "profileImage" : "default",
            "phone" : keychain.get("phone")!,
            "country" : keychain.get("country")!,
            "favoriteUnis" : [String]()
            ], merge: true)
        
        if keychain.getBool("isAmbassador")!{
            Firestore.firestore().collection("university").document(keychain.get("universityId")!).getDocument { (snap, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                snap?.reference.updateData(["ambassadors" : FieldValue.arrayUnion([self.keychain.get("uid")!])])
            }
        }
    }
}
