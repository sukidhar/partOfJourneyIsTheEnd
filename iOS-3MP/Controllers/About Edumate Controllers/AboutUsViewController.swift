//
//  AboutUsViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 03/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Checkers().isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        // Do any additional setup after loading the view.
    }
    @objc fileprivate func applicationIsActive() {
        canLogin()
        guard let uid = DataService().keyChain.get("uid") else{
            return
        }
        
        OnlineOfflineService.online(for: uid, status: "online") { (bool) in
            print(bool)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        canLogin()
    }
    func canLogin(){
        if Checkers().dateObserver() < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    
    func goToLoginScreen(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
