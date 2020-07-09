//
//  SideViewController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 31/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase
import Strongbox

class SideViewController: UIViewController {

    var notGoingToHome : Bool?
    @IBOutlet weak var heightOfHidableViews: NSLayoutConstraint!
    @IBOutlet weak var wishlistIcon: UIImageView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var aboutEdumatesICon: UIImageView!
    @IBOutlet weak var newsfeedIcon: UIImageView!
    @IBOutlet weak var accountSettingsView: UIView!
    @IBOutlet weak var accountSettingsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsFeedText: UILabel!
    @IBOutlet weak var newsFeedButton: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var aboutEdumates: UILabel!
    @IBOutlet weak var discovetText: UILabel!
    @IBOutlet weak var wishListText: UILabel!
    @IBOutlet weak var aboutUs: UIButton!
    @IBOutlet weak var contactUs: UIButton!
    @IBOutlet weak var FAQ: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    var activityIndicator : UIActivityIndicatorView?
    let keychain = DataService().keyChain
    var accountSettingsPressed = false
    var index : Int?
    let checkers = Checkers()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        NotificationCenter.default.addObserver(self, selector: #selector(updateImage(notification:)), name: NSNotification.Name("profileImageUploadedSuccessfully"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startActivityIndicator(notification:)), name: NSNotification.Name("imagePicked"), object: nil)
       
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.newsFeedButton.layer.cornerRadius = 12
        self.discoverButton.layer.cornerRadius = 12
        self.wishlistButton.layer.cornerRadius = 12
        index = self.tabBarController?.selectedIndex
        if index != nil {
            passIndex()
        }
    }
    @objc func startActivityIndicator(notification : Notification){
        print("i am changed")
        showActivityIndicatory(view: profileImage)
    }
    func showActivityIndicatory(view : UIImageView){
        self.activityIndicator = UIActivityIndicatorView(style: .gray)
        self.activityIndicator?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.activityIndicator?.center = view.center
        self.activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
    }
    @objc func updateImage(notification : Notification){
        if let url = notification.object as? String{
            if let indicator = activityIndicator{
                indicator.stopAnimating()
            }
            profileImage.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
        }
    }
    func passIndex() {
        newsFeedButton.backgroundColor = .none
        discoverButton.backgroundColor = .none
        wishlistButton.backgroundColor = .none
        FAQ.titleLabel?.textColor = .white
        newsFeedText.textColor = .white
        discovetText.textColor = .white
        wishListText.textColor = .white
        newsfeedIcon.tintColor = .white
        searchIcon.image = #imageLiteral(resourceName: "Group 1950")
        wishlistIcon.tintColor = .white
        
        guard let isAmb = keychain.getBool("isAmbassador") else{
            return
        }
        if isAmb{
            wishListText.text = "My University"
            heightOfHidableViews.constant = 0
            discovetText.isHidden = true
            discoverButton.isHidden = true
            searchIcon.isHidden = true
            switch index {
            case 0:
                newsFeedButton.backgroundColor = .white
                newsFeedText.textColor = .black
                newsfeedIcon.tintColor = .black
            case 1 :
                wishlistButton.backgroundColor = .white
                wishListText.textColor = .black
                wishlistIcon.image = #imageLiteral(resourceName: "Icon awesome-university").resize(20, 20)
            default:
                print("unknown index")
            }
            return
        }
        switch index {
            case 0:
                newsFeedButton.backgroundColor = .white
                newsFeedText.textColor = .black
                newsfeedIcon.tintColor = .black
            case 1:
                discoverButton.backgroundColor = .white
                discovetText.textColor = .black
                searchIcon.image =  #imageLiteral(resourceName: "Group 1950-1")
            case 2:
                wishlistButton.backgroundColor = .white
                wishListText.textColor = .black
                wishlistIcon.tintColor = .black
            default:
                print("Unknown Button")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        notGoingToHome = false
        accountSettingsView.isHidden = true
        accountSettingsHeightConstraint.constant = 0
        nameLabel.text = keychain.get("name") ?? ""
        profileImage.round(corners: .allCorners, cornerRadius: Double(profileImage.frame.height)/2)
        profileImage.sd_setImage(with: URL(string: keychain.get("profileImage") ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
    }
 
    
    @IBAction func newFeedTapped(_ sender: Any) {
        self.hidesBottomBarWhenPushed = false
        self.loadTabBarController(atIndex: 0)
    }
    
    @IBAction func discoverButtonTapped(_ sender: Any) {
        self.loadTabBarController(atIndex: 1)
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
    @IBAction func accountSettingsButtonPressed(_ sender: UIButton){
        accountSettingsPressed = !accountSettingsPressed
        accountSettingsHeightConstraint.constant = accountSettingsPressed ? 100 : 0
        accountSettingsView.isHidden = !accountSettingsPressed
        aboutUs.isHidden = accountSettingsView.isHidden
        contactUs.isHidden = accountSettingsView.isHidden
        FAQ.isHidden = accountSettingsView.isHidden
    }
    
    @IBAction func wishListButtonTapped(_ sender: Any) {
        guard let isAmb = keychain.getBool("isAmbassador") else{
            return
        }
        if isAmb{
          self.loadTabBarController(atIndex: 1)
            return
        }
        self.loadTabBarController(atIndex: 2)
    }
    @IBOutlet weak var discoverButton: UIButton!
    
    @IBOutlet weak var wishlistButton: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    var tabBarIndex: Int?

    //function that will trigger the **MODAL** segue
    private func loadTabBarController(atIndex: Int){
        if self.tabBarController?.selectedIndex == atIndex{
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        self.tabBarController?.selectedIndex = atIndex
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func LogoutPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure to log out?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            DBAccessor.shared.logOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
    @IBAction func ContactUsPressed(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
        notGoingToHome = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func aboutUsPressed(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
        notGoingToHome = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func FAQpressed(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
        notGoingToHome = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let bool = notGoingToHome{
            if !bool{
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        return
    }
}
