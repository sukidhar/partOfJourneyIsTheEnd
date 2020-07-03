//
//  SplashViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 12/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Strongbox
class SplashViewController: UIViewController {

    var homeViewController : UITabBarController!
    let keychain = DataService().keyChain
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadToMainScreen), name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func loadToMainScreen(){
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    override func viewDidAppear(_ animated: Bool) {
        if let isAmb = DataService().keyChain.getBool("isAmbassador"){
            
               if isAmb{
                let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! UINavigationController
                let uniVC = self.storyboard?.instantiateViewController(withIdentifier: "UniversityPage") as! UniversityViewController
                   let data = Strongbox().unarchive(objectForKey: "data") as! [String:Any]
                   if let universityId = data["universityId"] as? String{
                       Firestore.firestore().collection("university").document(universityId).getDocument { (snap, error) in
                           if let error = error{
                               print(error.localizedDescription)
                               return
                           }
                           if let data = snap?.data(){
                               if let title = data["name"] as? String, let coordinates = data["location"] as? GeoPoint{
                                   let long = coordinates.longitude
                                   let latt = coordinates.latitude
                                   var departments = data["department"] as? [Dictionary<String,String>]
                                   if departments == nil{
                                       departments = data["department "] as? [[String:String]]
                                   }
                                   let loc = CLLocationCoordinate2D(latitude: latt, longitude: long)
                                   let newUni = UniversityModel(ID: snap!.documentID, description: data["description"] as? String, imageURL: data["image"] as? String ?? "" , title: title, coordinates: loc, address: "", rawDept: departments ?? [[:]], Departments: [Department](), FAQ: data["FAQ link"] as? String ?? "", logo: data["logo"] as? String ?? "", videoURL: data["video"] as? String ?? "")
                                   uniVC.university = newUni
                                   let vc2 = UINavigationController(rootViewController: uniVC)
                                   self.homeViewController.viewControllers = [vc1,vc2] as [UIViewController]
                                   self.homeViewController.tabBar.items?[1].image = #imageLiteral(resourceName: "Icon awesome-university").resize(25 , 25)
                                   self.homeViewController.tabBar.items?[1].title = "My University"
                                NotificationCenter.default.post(name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
                                
                               }
                           }
                       }
                   }
               }
               else{
                let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! UINavigationController
                let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverView") as! UINavigationController
                let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "FavoritesView") as! UINavigationController
                homeViewController.viewControllers = [vc1,vc2,vc3] as [UIViewController]
                NotificationCenter.default.post(name: NSNotification.Name("canLoadToHomeScreen"), object: nil)
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
                self.view.window?.rootViewController = loginVC
                self.view.window?.makeKeyAndVisible()
            }
        }
    }

}
