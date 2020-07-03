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
class ChatController: UITableViewController {
    
    //MARK: -  Variables
    let keychain = DataService().keyChain
    var db = Firestore.firestore()
    let checkers = Checkers()
    override func viewWillDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //observers for going to background and active
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        
        //Rightside nav bar icon
        
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
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
    }
    //MARK: - oberseves active status
    @objc fileprivate func applicationIsActive() {
        canLogin()
        guard let uid = DataService().keyChain.get("uid") else{
            return
        }
        
        OnlineOfflineService.online(for: uid, status: "online") { (bool) in
            print(bool)
        }
    }
    //MARK: - can login
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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
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
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    
//  New Methods and Varibales being used
    
    
    var partners = [Partner]()
    
    func observeUserMessages(){
        partners = []
        if let uid = keychain.get("uid"){
            
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
                    if self.partners.contains(where: { (partner) -> Bool in
                        return partner.id == child.key
                    }){
                        let index = self.partners.firstIndex { (partner) -> Bool in
                            return partner.id == child.key
                        }
                        self.partners[index!] = newPartner
                    }
                    else{
                         self.partners.append(newPartner)
                    }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        partners.sort { (partner1, partner2) -> Bool in
            let timeDifference = partner1.lastActive - partner2.lastActive
            return timeDifference > 0
        }
        return partners.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let partner = partners[indexPath.row]
        Firestore.firestore().collection("USER").document(partner.id).getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = snap?.data(){
                let newUser =  UserModel()
                newUser.id = partner.id
                  newUser.name = data["name"] as? String
                  newUser.email = data["email"] as? String
                  newUser.uni = data["university"] as? String
                  newUser.imageUrl = data["imageUrl"] as? String
                self.showChatController(rUser: newUser, for : partner.chatID)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        cell.partner = partners[indexPath.row]
        return cell
    }
    
}
