//
//  UniversityChatViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 08/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SJSegmentedScrollView

class UniversityChatViewController: UIViewController {

    var university : UniversityModel?
    @IBOutlet weak var collectionViewHolder: UIView!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = university?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.01960784314, green: 0.137254902, blue: 0.2392156863, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    let first : AmbassadorsViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
        vc.title = "Student Representatives"
        return vc
    }()
    let second : AmbassadorsViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
        vc.title = "EduMates Experts"
        return vc
    }()
    
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        self.navigationController?.navigationBar.prefersLargeTitles = false
            first.university = university
            second.university = university
            let segmentController = SJSegmentedViewController(headerViewController: nil, segmentControllers: [first,second])
            segmentController.selectedSegmentViewColor = .orange
            self.addChild(segmentController)
            collectionViewHolder.addSubview(segmentController.view)
            segmentController.view.frame = collectionViewHolder.bounds
            segmentController.didMove(toParent: self)
    }
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
