//
//  SearchViewController.swift
//  Mine
//
//  Created by ingenuo-yag on 13/05/20.
//  Copyright © 2020 ingenuo-yag. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import KeychainSwift
import SDWebImage
import Strongbox
import SwiftyJSON

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var selectedIndex : Int?
    let keychain = DataService().keyChain
    var universities = [UniversityModel]()
    var basicUniversities = [UniversityModel](){
        didSet{
            print("hello")
            UniversityCollectionView.reloadData()
        }
    }
    let navSearchBar = UISearchBar()
    var filteredData = [UniversityModel]()
    var searchTextCountIsZero = true {
        didSet{
            UniversityCollectionView.reloadData()
        }
    }
    let sb = Strongbox()
    var initialUniversites = [String]()
    @IBOutlet weak var UniversityCollectionView: UICollectionView!
//    @IBOutlet weak var searchbar: UISearchBar!
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        Checkers().isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        navSearchBar.barTintColor = .white
        if #available(iOS 13.0, *) {
            navSearchBar.searchTextField.backgroundColor = .white
        } else {
            // Fallback on earlier versions
            let textFieldInsideSearchBar = navSearchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = .black
            textFieldInsideSearchBar?.backgroundColor = .white
        }
        navSearchBar.sizeToFit()
        navSearchBar.delegate = self
        navigationItem.titleView = navSearchBar
        navSearchBar.isHidden = true
        globalValues.universties = sb.unarchive(objectForKey: "wishlist") as? [String] ?? []
        globalValues.data = sb.unarchive(objectForKey: "data") as? Dictionary<String,Any> ?? Dictionary<String, Any>()
        globalValues.dateOfBirth = sb.unarchive(objectForKey: "dob") as? Timestamp ?? Timestamp()
        UniversityCollectionView.delegate = self
        UniversityCollectionView.dataSource = self
        UniversityCollectionView.register(UINib(nibName: "UniversityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "card")
        loadUniversities()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        UniversityCollectionView.reloadData()
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initialUniversites = globalValues.universties
        canLogin()
    }
    @IBAction func searchPressed(_ sender: UIBarButtonItem) {
        if navSearchBar.isHidden {
            navSearchBar.becomeFirstResponder()
            navSearchBar.isHidden = false
            if #available(iOS 13.0, *) {
                sender.image = UIImage(systemName: "xmark")
            } else {
                // Fallback on earlier versions
                sender.image = #imageLiteral(resourceName: "xmark")
            }
        }
        else{
            navSearchBar.isHidden = true
            sender.image = #imageLiteral(resourceName: "Group 1950")
            navSearchBar.endEditing(true)
            if #available(iOS 13.0, *) {
                navSearchBar.searchTextField.text = ""
            } else {
                // Fallback on earlier versions
                let textFieldInsideSearchBar = navSearchBar.value(forKey: "searchField") as? UITextField
                textFieldInsideSearchBar?.text = ""
            }
            searchTextCountIsZero = true
            UniversityCollectionView.reloadData()
        }
    }
    @IBAction func showMenu(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideMenu") as! SideViewController
        viewController.index = self.tabBarController?.selectedIndex
        self.navigationController?.pushViewControllerFromLeft(controller: viewController)
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
    func loadUniversities()
    {
        universities = []
        filteredData = []
        basicUniversities = []
        db.collection("university").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let snaps = snapshot?.documents{
                defer{
                    self.basicUniversities = self.universities
                }
                for snap in snaps{
                    defer{
                        DispatchQueue.main.async {
                            self.UniversityCollectionView.reloadData()
                        }
                    }
                    let data = snap.data()
                    if let title = data["name"] as? String, let coordinates = data["location"] as? GeoPoint{
                    let long = coordinates.longitude
                    let latt = coordinates.latitude
                    var departments = data["department"] as? [[String:String]]
                    if departments == nil{
                        departments = data["department "] as? [[String:String]]
                    }
                    let loc = CLLocationCoordinate2D(latitude: latt, longitude: long)
                    let newUni = UniversityModel(ID: snap.documentID, description: data["description"] as? String ?? data["description "] as? String, imageURL: data["image"] as? String ?? "" , title: title, coordinates: loc, address: "", rawDept: departments ?? [[:]], Departments: [Department](), FAQ: data["FAQ link"] as? String ?? "",logo : data["logo"] as? String ?? "", videoURL: data["video"] as? String ?? "")
                    self.universities.append(newUni)
                    }
                }
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchTextCountIsZero{
            return basicUniversities.count
        }
        else{
            return filteredData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var uni : UniversityModel
        if searchTextCountIsZero{
            uni = basicUniversities[indexPath.row]
        }
        else{
            uni = filteredData[indexPath.row]
        }
        let card = UniversityCollectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! UniversityCollectionViewCell
         
         card.imageView.sd_setImage(with: URL(string: uni.logo), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: SDWebImageOptions.highPriority, context: nil)
        if globalValues.universties.contains(uni.ID){
            card.featherImage.image = #imageLiteral(resourceName: "Icon awesome-bookmark")
        }else{
            card.featherImage.image = #imageLiteral(resourceName: "Icon feather-bookmark")
        }
        card.starButton.imageView?.contentMode = .scaleAspectFit
         card.titleLabel.text = uni.title
         card.starButton.tag = indexPath.row
        card.featherImage.tag = indexPath.row
         card.starButton.addTarget(self, action: #selector(didPressed(_:)), for: .touchUpInside)
         return card
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextCountIsZero = searchText.count == 0 ? true : false
        filteredData = universities.filter { (university) -> Bool in
            return university.title.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.UniversityCollectionView.reloadData()
        }
    }
    @objc func didPressed(_ sender : UIButton)
    {
        var favorite : UniversityModel!
        if self.searchTextCountIsZero{
         favorite = self.basicUniversities[sender.tag]
        }else{
         favorite = self.filteredData[sender.tag]
        }
        if globalValues.universties.contains(favorite.ID){
            let alert = UIAlertController(title: "Bookmark", message: "Are you sure you want to add this to Bookmarks", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.db.collection("USER").document(self.keychain.get("uid")!).getDocument { (snapshot, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    else{
                        defer {
                            if let card = self.UniversityCollectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? UniversityCollectionViewCell{
                                card.featherImage.image = #imageLiteral(resourceName: "Icon feather-bookmark")
                            }
                        }
                        globalValues.universties.remove(at: globalValues.universties.firstIndex(of: favorite.ID)!)
                        let _ = Strongbox().archive(globalValues.universties, key: "wishlist")
                        snapshot?.reference.updateData(["favoriteUnis" : globalValues.universties])
                    }
                }
            }))
            present(alert, animated: true)
            return
        }
        else if globalValues.universties.count == 0{
            addingAlert(tag: sender.tag, favorite: favorite)
        }
        else if globalValues.universties.count < 10{
            self.db.collection("USER").document(self.keychain.get("uid")!).getDocument { (snapshot, error) in
                if let error = error{
                    print(error.localizedDescription)
                }
                else{
                    defer {
                        if let card = self.UniversityCollectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? UniversityCollectionViewCell{
                             card.featherImage.image = #imageLiteral(resourceName: "Icon awesome-bookmark")
                         }
                        }
                    globalValues.universties.append(favorite.ID)
                    let _ = Strongbox().archive(globalValues.universties, key: "wishlist")
                    snapshot?.reference.updateData(["favoriteUnis" : globalValues.universties])
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Sorry", message: "You can't wishlist more than 10 Universities", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert,animated: true)
        }
    }
    func addingAlert(tag : Int, favorite : UniversityModel){
       let alert = UIAlertController(title: "Bookmark", message: "Are you sure you want to add this to Bookmarks", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
           alert.dismiss(animated: true, completion: nil)
       }))
       alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
           self.db.collection("USER").document(self.keychain.get("uid")!).getDocument { (snapshot, error) in
               if let error = error{
                   print(error.localizedDescription)
               }
               else{
                   defer {
                       if let card = self.UniversityCollectionView.cellForItem(at: IndexPath(row: tag, section: 0)) as? UniversityCollectionViewCell{
                            card.featherImage.image = #imageLiteral(resourceName: "Icon awesome-bookmark")
                        }
                       }
                   globalValues.universties.append(favorite.ID)
                   let _ = Strongbox().archive(globalValues.universties, key: "wishlist")
                   snapshot?.reference.updateData(["favoriteUnis" : globalValues.universties])
               }
           }
       }))
       present(alert, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "univPage", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! UniversityViewController
        if searchTextCountIsZero{
        vc.university = basicUniversities[selectedIndex!]
        }
        else{
            vc.university = filteredData[selectedIndex!]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if initialUniversites.elementsEqual(globalValues.universties){
            NotificationCenter.default.post(name: NSNotification.Name("favChanges"), object: false)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name("favChanges"), object: true)
        }
    }
}
