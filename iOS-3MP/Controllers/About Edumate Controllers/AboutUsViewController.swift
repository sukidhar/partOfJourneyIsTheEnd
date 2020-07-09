//
//  AboutUsViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 03/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        // Do any additional setup after loading the view.
    }
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
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
    @IBAction func backButtonPressed(_ sender: UIButton) {
self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
