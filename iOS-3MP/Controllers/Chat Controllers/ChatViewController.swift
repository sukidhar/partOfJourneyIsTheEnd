//
//  ChatViewController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 24/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import KeychainSwift


class ChatViewController: UITableViewController {

    let keychain = DataService().keyChain
    var users = [UserModel]()
    let cellId = "cellId"
    var partners = [Partner]()
    var db = Firestore.firestore()
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //let firstName = keychain.get("firstName")!
        //let lastName = keychain.get("lastName")!
        //change name here
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        self.navigationItem.title = keychain.get("name")!
        tabBarController?.tabBar.isHidden = true
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        UIBarButtonItem.appearance().tintColor = .black
        fetchUsers()
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
    @objc func showChatController(rUser: UserModel){
        //Responsible for View Controller to go into Chat
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.hidesBottomBarWhenPushed = true
        chatController.rUser = rUser
        chatController.chatID = checkIfFirstTime(user: rUser)
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func checkIfFirstTime(user : UserModel)->String?{
        if partners.count == 0{
            let key = Database.database().reference().child("chats").childByAutoId().key
            return key
        }
        if partners.contains(where: { (partner) -> Bool in
            return partner.id == user.id
        }){
            let partner = partners.first { (partner) -> Bool in
                return partner.id == user.id
            }
            return partner?.chatID
        }else{
            let key = Database.database().reference().child("chats").childByAutoId().key
            partners.append(Partner(id: user.id!, chatID: key!, lastActive: Date().timeIntervalSince1970, latest: "", name: user.name!))
            return key
        }
    }
    
    // Function To fetch users from RTDb
    func fetchUsers(){
        
        db.collection("university")
        
        
        
        let collectionRef = db.collection("USER")
               collectionRef.getDocuments { (querySnapshot, err) in
                   if let docs = querySnapshot?.documents {
                       for docSnapshot in docs {
                           defer{
                             let newUser =  UserModel()
                            newUser.id = docSnapshot.documentID
                            newUser.name = docSnapshot.data()["name"] as? String
                            newUser.email = docSnapshot.data()["email"] as? String
                            newUser.uni = docSnapshot.data()["university"] as? String
                            newUser.imageUrl = docSnapshot.data()["imageURL"] as? String
                             self.users.append(newUser)
                            
                           }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                    }
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let cUser = users[indexPath.row]
        cell.textLabel?.text = cUser.name
        cell.detailTextLabel?.text = cUser.uni
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ruser = users[indexPath.row]
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.hidesBottomBarWhenPushed = true
        chatController.rUser = ruser
        chatController.chatID = checkIfFirstTime(user: ruser)
        navigationController?.pushViewController(chatController, animated: true)    }
}
