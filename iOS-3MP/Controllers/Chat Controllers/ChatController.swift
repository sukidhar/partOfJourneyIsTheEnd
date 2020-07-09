//
//  ChatController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import KeychainSwift


struct Partner {
    let id : String
    let chatID : String
    var lastActive : Double
    var latest : String
    let name : String
}
class ChatController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{
    
    
    
    
    lazy var searchController : UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        s.obscuresBackgroundDuringPresentation = false
        s.dimsBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Search People"
        s.searchBar.searchBarStyle = .prominent
        s.searchBar.scopeButtonTitles = []
        s.searchBar.delegate = self
        return s
    }()
    //MARK: -  Variables
    var filteredPartners = [Partner]()
    let keychain = DataService().keyChain
    var db = Firestore.firestore()
    override func viewWillDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
    }
    
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        //observers for going to background and active
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))

        //Rightside nav bar icon
        self.navigationItem.searchController = searchController
        let image = UIImage(named: "new_message_icon")
        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        // separator style
        self.tableView.separatorStyle = .none
        //navigationBar setup
        navigationItem.title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewChat))
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        UIBarButtonItem.appearance().tintColor = .black
        tableView.reloadData()
        observeUserMessages()
    }
    //MARK: - oberseves active status
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
    }
    //MARK: - can login
    func canLogin(){
        if Checkers().dateObserver()  < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    
    //MARK: - User is no more paid then to redirect to login screen
    func goToLoginScreen(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Chats"
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - reload data whenever view appears because we then can show recent relative tim
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - show  chat screen when user clicks on a cell
    func showChatController(rUser: UserModel, for chatID : String ){
        //Responsible for View Controller to go into Chat
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.hidesBottomBarWhenPushed = true
        chatController.rUser = rUser
        chatController.chatID = chatID
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @objc func handleNewChat() {
        //Handles New Chat
        let chatViewController = ChatViewController()
        chatViewController.partners = partners
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    
    //MARK: - Data base query
    var partners = [Partner]()
    //partner model is for showing user cells
    func observeUserMessages(){
        partners = []
        if let uid = keychain.get("uid"){
            // continuously observe in real time database value changes, .childAdded wont work here because the current childs are only changed and might be added with a new child
            let db = Database.database().reference().child("userChats").child(uid)
            db.observe(.value) { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                   if let data = child.value as? [String : AnyObject]{
                        let partnerID = child.key
                        let chatID = data["chat"] as! String
                        let lastActive = data["lastActive"] as! Double
                        let latest = data["latest"] as! String
                        let name = data["name"] as! String
                    let newPartner = Partner(id: partnerID, chatID: chatID, lastActive: lastActive, latest: latest, name: name)
                    //incase we already have the child then change the content of the child
                    if self.partners.contains(where: { (partner) -> Bool in
                        return partner.id == child.key
                    }){
                        let index = self.partners.firstIndex { (partner) -> Bool in
                            return partner.id == child.key
                        }
                        self.partners[index!] = newPartner
                    }
                    else{
                        //else just append the new child into partners
                         self.partners.append(newPartner)
                    }
                    //reload the table view once this is done
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    //MARK: - Table View data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !shouldShowSearchContent(){
            partners.sort { (partner1, partner2) -> Bool in
                //sort the data retrived based on time stamps just before they are loaded
                let timeDifference = partner1.lastActive - partner2.lastActive
                return timeDifference > 0
            }
            return partners.count
        }else{
            filteredPartners.sort { (partner1, partner2) -> Bool in
                //sort the data retrived based on time stamps just before they are loaded
                let timeDifference = partner1.lastActive - partner2.lastActive
                return timeDifference > 0
            }
            return filteredPartners.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //default height of cell to be 72
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var partner : Partner
        if shouldShowSearchContent(){
            partner = filteredPartners[indexPath.row]
        }else{
            partner = partners[indexPath.row]
        }
        //chat user has been selected so the chat log controller will be shown from here after the fetching of minimal data is done
        
        getUser(partner: partner.id) { (user) in
            if let user = user{
                user.id = partner.id
                user.name = partner.name
               self.showChatController(rUser: user, for : partner.chatID)
                return
            }
        }
    }
    
    func getUser(partner : String,handler : @escaping (_ user : UserModel?)->Void) {
        let ref = Database.database().reference().child("USER").child(partner)
        ref.observeSingleEvent(of: .value) { (snap) in
            if let data = snap.value as? [String:Any]{
                print(data)
                let user = UserModel()
                user.imageUrl = data["imageUrl"] as? String
                user.uni = data["university"] as? String
                user.course = data["course"] as? String
                handler(user)
            }else{
                 handler(nil)
            }
        }
        ref.removeAllObservers()
        
    }
    // cell for each partner
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        if shouldShowSearchContent(){
            cell.partner = filteredPartners[indexPath.row]
        }else{
            cell.partner = partners[indexPath.row]
        }
        return cell
    }
    func shouldShowSearchContent()->Bool{
        return !isSearchEmpty() && searchController.isActive
    }
    func isSearchEmpty()->Bool{
        return searchController.searchBar.text?.count == 0
    }
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if isSearchEmpty(){
            tableView.reloadData()
            return
        }
        filteredPartners = partners.filter({ (partner) -> Bool in
            return partner.name.lowercased().contains(text!.lowercased())
        })
        tableView.reloadData()
    }

}
