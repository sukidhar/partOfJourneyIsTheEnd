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
    @IBOutlet weak var collectionVIewHolder: UIView!
    var users : [UserModel]?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.01960784314, green: 0.137254902, blue: 0.2392156863, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        
        if let storyboard = self.storyboard{
            
            let first = storyboard.instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
            let third = storyboard.instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
            let second = storyboard.instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
            let fourth = storyboard.instantiateViewController(withIdentifier: "Ambassadors") as! AmbassadorsViewController
            first.title = "Ambassadors"
            second.title = "Students"
            third.title = "Representatives"
            fourth.title = "EduMates Expert"
            first.university = university
            second.university = university
            third.university = university
            fourth.university = university
            
            let segmentController = SJSegmentedViewController(headerViewController: nil, segmentControllers: [first,second,third,fourth])
            
            self.addChild(segmentController)
            collectionVIewHolder.addSubview(segmentController.view)
            segmentController.view.frame = collectionVIewHolder.bounds
            segmentController.didMove(toParent: self)
        }
    }
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
