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

    
    @IBOutlet weak var heightOfHidableViews: NSLayoutConstraint!
    @IBOutlet weak var wishlistIcon: UIImageView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var calendarGroupIcon: UIImageView!
    @IBOutlet weak var aboutEdumatesICon: UIImageView!
    @IBOutlet weak var newsfeedIcon: UIImageView!
    @IBOutlet weak var accountSettingsView: UIView!
    @IBOutlet weak var accountSettingsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsFeedText: UILabel!
    @IBOutlet weak var newsFeedButton: UIButton!
    @IBOutlet weak var CalendarButton: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var aboutEdumates: UILabel!
    @IBOutlet weak var calendarText: UILabel!
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
    override func viewDidLoad() {
        Checkers().isGoingToBackground()
        NotificationCenter.default.addObserver(self, selector: #selector(updateImage(notification:)), name: NSNotification.Name("profileImageUploadedSuccessfully"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startActivityIndicator(notification:)), name: NSNotification.Name("imagePicked"), object: nil)
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.newsFeedButton.layer.cornerRadius = 12
        self.discoverButton.layer.cornerRadius = 12
        self.CalendarButton.layer.cornerRadius = 12
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
        CalendarButton.backgroundColor = .none
        FAQ.titleLabel?.textColor = .white
        newsFeedText.textColor = .white
        calendarText.textColor = .white
        discovetText.textColor = .white
        wishListText.textColor = .white
        newsfeedIcon.image = #imageLiteral(resourceName: "Group-1916")
        calendarGroupIcon.image = #imageLiteral(resourceName: "calendar-dates")
        searchIcon.image = #imageLiteral(resourceName: "Group 1950")
        wishlistIcon.image = #imageLiteral(resourceName: "MenuWishListIcon")
        
        guard let isAmb = keychain.getBool("isAmbassador") else{
            return
        }
        if isAmb{
            wishListText.text = "My University"
            heightOfHidableViews.constant = 0
            calendarText.isHidden = true
            discovetText.isHidden = true
            calendarGroupIcon.isHidden = true
            discoverButton.isHidden = true
            CalendarButton.isHidden = true
            searchIcon.isHidden = true
            switch index {
            case 0:
                newsFeedButton.backgroundColor = .white
                newsFeedText.textColor = .black
                newsfeedIcon.image = #imageLiteral(resourceName: "Group 1916")
            case 1 :
                wishlistButton.backgroundColor = .white
                wishListText.textColor = .black
                wishlistIcon.image = #imageLiteral(resourceName: "iconForTabWIshList")
            default:
                print("unknown index")
            }
            return
        }
        switch index {
            case 0:
                newsFeedButton.backgroundColor = .white
                newsFeedText.textColor = .black
                newsfeedIcon.image = #imageLiteral(resourceName: "Group 1916")
            case 1:
                discoverButton.backgroundColor = .white
                discovetText.textColor = .black
                searchIcon.image = #imageLiteral(resourceName: "searchtb")
            case 2:
                wishlistButton.backgroundColor = .white
                wishListText.textColor = .black
                wishlistIcon.image = #imageLiteral(resourceName: "iconForTabWIshList")
            case 3:
                CalendarButton.backgroundColor = .white
                calendarText.textColor = .black
                calendarGroupIcon.image = #imageLiteral(resourceName: "calendar")
            default:
                print("Unknown Button")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
        self.loadTabBarController(atIndex: 3)
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
        accountSettingsHeightConstraint.constant = accountSettingsPressed ? 120 : 0
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
        self.tabBarController?.selectedIndex = atIndex
        self.navigationController?.popToRootViewController(animated: true)
    }

    //in here you set the index of the destination tab and you are done
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         if segue.identifier == "showTabBar" {
//             let tabbarController = segue.destination as! UITabBarController
//             tabbarController.selectedIndex = self.tabBarIndex!
//         }
//    }
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
}
