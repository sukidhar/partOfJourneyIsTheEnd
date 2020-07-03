//
//  ViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 12/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//

import UIKit

class pageControlViewController: UIViewController{
    
    var pageViewController : PageViewController!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("pageNumber"), object: nil)
    }
    //MARK: - - - - - Method for receiving Data through Post Notificaiton - - - - -
       @objc func methodOfReceivedNotification(notification: Notification) {
        pageControl.currentPage = notification.object as! Int
        if pageControl.currentPage == 3{
            nextButton.setTitle("Dive right in", for: .normal)
            skipButton.isHidden = true
        }
        else{
            nextButton.setTitle("Next", for: .normal)
            skipButton.isHidden = false
        }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customView" {
            pageViewController = segue.destination as? PageViewController
        }
    }
    @IBAction func nextPressed(_ sender: UIButton) {
        pageViewController.pressed(sender: sender)
        pageControl.currentPage = pageViewController.i
        if sender.titleLabel?.text == "Dive right in"{
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginZoneViewController
            self.view.window?.rootViewController = loginVC
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func skipPressed(_ sender : UIButton)
    {
        pageViewController.skipPressed(sender : sender)
        pageControl.currentPage = pageViewController.i
    }
}

