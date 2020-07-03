//
//  LogOutViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 13/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class LogOutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func SignOut (_ sender: Any){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        DataService().keyChain.delete("uid")
        dismiss(animated: true, completion: nil)
    }

}
