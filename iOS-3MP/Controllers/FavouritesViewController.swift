//
//  FavouritesViewController.swift
//  Mine
//
//  Created by sukidhar on 13/05/20.
//  Copyright © 2020 sukidhar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import KeychainSwift
import SDWebImage
import CoreLocation
import Strongbox

class FavouritesViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    let sb = Strongbox()
    var delegate : TabDelegate?
    // basic variables
    @IBOutlet weak var defaultImage: UIImageView!
    @IBOutlet weak var defaultLabel: UILabel!
    var selectedIndex : Int?
    let keychain = DataService().keyChain
    let db = Firestore.firestore()
    var favorites = [UniversityModel]()
    let searchBar = UISearchBar()
    var searchTextCountIsZero = true {
        didSet{
            self.favoritesCollectionView.reloadData()
        }
    }
    let checkers = Checkers()
    var filteredData = [UniversityModel]()
    
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    func hideDefaultImageAndText(){
        defaultImage.isHidden = true
        defaultLabel.isHidden = true
        favoritesCollectionView.isHidden = false
    }
    func unhideDefaultImageAndText(){
        defaultImage.isHidden = false
        defaultLabel.isHidden = false
        favoritesCollectionView.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        hideDefaultImageAndText()
        NotificationCenter.default.addObserver(self, selector: #selector(loadUnisAgain(notification:)), name: NSNotification.Name("favChanges"), object: nil)
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        globalValues.universties = sb.unarchive(objectForKey: "wishlist") as? [String] ?? []
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 0.6026306748, blue: 0, alpha: 1)
        // Do any additional setup after loading the view.
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.register(UINib(nibName: "UniversityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "card")
        searchBar.barTintColor = .white
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .white
        } else {
            // Fallback on earlier versions
            let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = .black
            textFieldInsideSearchBar?.backgroundColor = .white
        }
        searchBar.delegate = self
        searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar
        searchBar.isHidden = true
        loadWishlist()
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
        Checkers().alertMaker(view: self)
        if Checkers().dateObserver()  < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
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
    @IBAction func searchEnabled(_ sender: UIBarButtonItem) {
        if searchBar.isHidden {
            searchBar.isHidden = false
            if #available(iOS 13.0, *) {
                sender.image = UIImage(systemName: "xmark")
                searchBar.searchTextField.becomeFirstResponder()
            } else {
                // Fallback on earlier versions
                sender.image = #imageLiteral(resourceName: "xmark")
                let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
                textFieldInsideSearchBar?.becomeFirstResponder()
            }
        }
        else{
            searchBar.isHidden = true
            sender.image = #imageLiteral(resourceName: "Group 1950")
            searchBar.endEditing(true)
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.text = ""
            } else {
                // Fallback on earlier versions
                let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
                textFieldInsideSearchBar?.text = ""
            }
        }
    }
    
    @objc func loadUnisAgain(notification : Notification){
        let value =  notification.object as! Bool
        print(value)
        if value{
            loadWishlist()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if favorites.count == 0 {
            if globalValues.universties.count == 0{
              unhideDefaultImageAndText()
            }
            return 0
        }else if !searchTextCountIsZero{
            if filteredData.count == 0{
                unhideDefaultImageAndText()
            }
            return filteredData.count
        }
        else{
            hideDefaultImageAndText()
            if searchTextCountIsZero{
                return favorites.count
            }
            else{
                return filteredData.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var favorite : UniversityModel!
        if searchTextCountIsZero{
            favorite = favorites[indexPath.row]
        }else{
            favorite = filteredData[indexPath.row]
        }
        let card = favoritesCollectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! UniversityCollectionViewCell
        
        card.imageView.sd_setImage(with: URL(string: favorite.logo), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: SDWebImageOptions.highPriority, context: nil)
        card.titleLabel.text = favorite.title
        card.starButton.tag = indexPath.row
        print(card.starButton.tag)
        card.starButton.addTarget(self, action: #selector(didPressed(_:)), for: .touchUpInside)
        return card
    }
    func loadWishlist(){
        favorites = []

        let numberOfIterations = globalValues.universties.count/10 + globalValues.universties.count%10 != 0 ? 1 : 0
        let idContainer = self.split(for: globalValues.universties, forSize: 10)
        
        for i in 0..<numberOfIterations{
            self.db.collection("university").whereField(FieldPath.documentID(), in: idContainer[i]).getDocuments { (snap, error) in
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                if let docs = snap?.documents{
                    for doc in docs{
                        let data = doc.data()
                        if let title = data["name"] as? String, let coordinates = data["location"] as? GeoPoint{
                            defer {
                                DispatchQueue.main.async {
                                    self.favoritesCollectionView.reloadData()
                                }
                            }
                            let long = coordinates.longitude
                            let latt = coordinates.latitude
                            var departments = data["department"] as? [Dictionary<String,String>]
                            if departments == nil{
                                departments = data["department "] as? [[String:String]]
                            }
                            let loc = CLLocationCoordinate2D(latitude: latt, longitude: long)
                            let newUni = UniversityModel(ID: doc.documentID, description: data["description"] as? String, imageURL: data["image"] as? String ?? "" , title: title, coordinates: loc, address: "", rawDept: departments ?? [[:]], Departments: [Department](), FAQ: data["FAQ link"] as? String ?? "", logo: data["logo"] as? String ?? "", videoURL: data["video"] as? String ?? "")
                            self.favorites.append(newUni)
                        }
                    }
                }
            }
        }
    }
    // methods to fetch university objects and reload table view
    func split(for s: [String], forSize splitSize: Int) -> [[String]] {
        if s.count <= splitSize {
            return [s]
        } else {
            return [Array<String>(s[0..<splitSize])] + split(for: Array<String>(s[splitSize..<s.count]), forSize: splitSize)
        }
    }
    func convertDictionaryToDepartmentModel(dict : [String:String]) -> Department{
        let name = dict["name"]
        let link = dict["link"]
        let department = Department(name : name ?? "", link : link ?? "")
        return department
    }
    func removeItemFromWishList(id : String)
    {
        for i in 0..<globalValues.universties.count{
            if globalValues.universties[i] == id {
                globalValues.universties.remove(at: i)
                let _ = sb.archive(globalValues.universties, key: "wishlist")
                break
            }
        }
    }
    
    @objc func didPressed(_ sender : UIButton)
    {
        let alert = UIAlertController(title: "Delete", message: "Are you sure to remove a bookmark", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            var favorite : UniversityModel!
            if self.searchTextCountIsZero{
             favorite = self.favorites[sender.tag]
            }else{
             favorite = self.filteredData[sender.tag]
            }
            self.db.collection("USER").document(self.keychain.get("uid")!).getDocument { (snapshot, error) in
                if let error = error{
                    print(error.localizedDescription)
                }
                else{
                    self.removeFavorite(favorite: favorite)
                    self.removeItemFromWishList(id: favorite.ID)
                    snapshot?.reference.updateData(["favoriteUnis" : globalValues.universties])
                    DispatchQueue.main.async {
                        self.favoritesCollectionView.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    func removeFavorite(favorite : UniversityModel)
    {
        defer {
            favoritesCollectionView.reloadData()
        }
        favorites = favorites.filter({ (university) -> Bool in
            return university.ID != favorite.ID
        })
        if !searchTextCountIsZero{
            filteredData = filteredData.filter({ (university) -> Bool in
            return university.ID != favorite.ID
            })
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextCountIsZero = searchText.count == 0 ? true : false
        filteredData = favorites.filter { (university) -> Bool in
            return university.title.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.favoritesCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
//        Firestore.firestore().collection("university").document(favorites[indexPath.item].ID).getDocument { (snap, error) in
//            if let error = error{
//                print(error)
//                return
//            }else{
//                snap?.reference.updateData(["department" : self.favorites[self.selectedIndex!].Departments])
//                snap?.reference.updateData(["department " : "nomoredata"])
//            }
//        }
        performSegue(withIdentifier: "universityPage", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! UniversityViewController
        if searchTextCountIsZero {
            vc.university = favorites[selectedIndex!]
        }else{
            vc.university = filteredData[selectedIndex!]
        }
        
    }
    
}



