//
//  PopUpUniversityViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import WebKit
import youtube_ios_player_helper

class PopUpUniversityViewController: UIViewController{
    @IBOutlet weak var handleImage: UIImageView!
    @IBOutlet weak var handleImage2: UIImageView!
    @IBOutlet weak var chatButton : UIButton!
    @IBOutlet weak var exploreButton : UIButton!
    @IBOutlet weak var twinButtonView: UIView!
    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var universityTItle: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var handleBar: UIView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var departmentCollectionView : UICollectionView!
    
    var university : UniversityModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        Checkers().isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        handleBar.layer.cornerRadius = handleBar.frame.height/2
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
    @IBAction func chatButtonPressed(_ sender: UIButton) {
       
    }
    @IBAction func explorePressed(_ sender: UIButton) {
    }
}
