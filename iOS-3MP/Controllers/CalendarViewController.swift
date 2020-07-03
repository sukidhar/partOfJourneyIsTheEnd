//
//  CalendarViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 13/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    var delegate : TabDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 0.6026306748, blue: 0, alpha: 1)
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
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

    @IBAction func showMenu(_ sender: Any) {
          let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideMenu") as! SideViewController
              viewController.index = self.tabBarController?.selectedIndex
              self.navigationController?.pushViewControllerFromLeft(controller: viewController)
    }

}
