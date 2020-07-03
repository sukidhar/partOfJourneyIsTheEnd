//
//  AmbassadorsViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 08/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase

class AmbassadorsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var university : UniversityModel?
    var users : [UserModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Checkers().isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        collectionView.register(UINib(nibName: "UserIconCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "userIconCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        loadUsers()
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = users![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userIconCell", for: indexPath) as! UserIconCollectionViewCell
        cell.nameLabel.text = self.users![indexPath.row].name
        cell.imageVIew.sd_setImage(with: URL(string: user.imageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
        return cell
    }
    func loadUsers(){
        users = []
        if let uni = university{
            Firestore.firestore().collection("university").document(uni.ID).addSnapshotListener{ (snap, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                if let data = snap?.data(){
                    if let ids = data["ambassadors"] as? [String]{
                        let splitIds = self.split(for: ids, forSize: 10)
                        let numberOfIterations = ids.count/10 + ids.count%10 != 0 ? 1 : 0
                        
                        for i in 0..<numberOfIterations{
                            self.getUsers(for: splitIds[i])
                        }
                               
                    }
                }
            }
        }
    }
    func split(for s: [String], forSize splitSize: Int) -> [[String]] {
        if s.count <= splitSize {
            return [s]
        } else {
            return [Array<String>(s[0..<splitSize])] + split(for: Array<String>(s[splitSize..<s.count]), forSize: splitSize)
        }
    }
    func getUsers(for ids : [String]){
        Firestore.firestore().collection("USER").whereField(FieldPath.documentID(), in: ids).getDocuments { (snapshots, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snaps = snapshots?.documents{
                for snap in snaps{
                    let user = UserModel()
                    let data = snap.data()
                    if data["isAmbassador"] as! Bool{
                        user.id = snap.documentID
                        user.name = data["name"] as? String
                        user.email = data["email"] as? String
                        user.uni = self.university?.title
                        user.imageUrl = data["profileImage"] as? String
                        if let extraData = data["data"] as? Dictionary<String,Any>{
                            user.type = extraData["type"] as? String
                        }
                        if self.title == "Ambassadors"{
                            if user.type == "ambassador"{
                                self.users?.append(user)
                            }
                        }
                        else if self.title == "Students"{
                            if user.type == "studentRepresentative"{
                                self.users?.append(user)
                            }
                        }
                        else if self.title == "Representatives"{
                            if user.type == "courseRepresentative"{
                                self.users?.append(user)
                            }
                        }
                        else if self.title == "EduMates Expert"{
                            if user.type == "edumatesExpert"{
                                self.users?.append(user)
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    func getUser(for uid : String){
        Firestore.firestore().collection("USER").document(uid).getDocument { (snap, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let data = snap?.data(){
                let user = UserModel()
                if data["isAmbassador"] as! Bool{
                    user.id = uid
                    user.name = data["name"] as? String
                    user.email = data["email"] as? String
                    user.uni = self.university?.title
                    user.imageUrl = data["profileImage"] as? String
                    if let extraData = data["data"] as? Dictionary<String,Any>{
                        user.type = extraData["type"] as? String
                    }
                    if self.title == "Ambassadors"{
                        if user.type == "rep"{
                            self.users?.append(user)
                        }
                    }
                    else if self.title == "Students"{
                        if user.type == "studentRepresentative"{
                            self.users?.append(user)
                        }
                    }
                    else if self.title == "Representatives"{
                        if user.type == "courseRepresentative"{
                            self.users?.append(user)
                        }
                    }
                    else if self.title == "EduMates Expert"{
                        if user.type == "edumatesExpert"{
                            self.users?.append(user)
                        }
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users![indexPath.row]
        showChatController(for: user)
    }
    
     func showChatController(for rUser: UserModel){
        //Responsible for View Controller to go into Chat
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.hidesBottomBarWhenPushed = true
        chatController.rUser = rUser
        getChatID(for: rUser.id!) { (id) in
            chatController.chatID = id
        }
        navigationController?.pushViewController(chatController, animated: true)
    }

    func getChatID(for partner : String, handler : @escaping (_ ID: String)-> Void){
        let ref = Database.database().reference().child("userChats").child(DataService().keyChain.get("uid")!)
        ref.observe(.value, with: { (snap) in
            defer{
                let key = Database.database().reference().child("chats").childByAutoId().key
                handler(key!)
            }
            for child in snap.children.allObjects as! [DataSnapshot]{
                if child.key == partner{
                    let data = child.value as! [String : Any]
                    let ID = data["chat"] as? String
                    handler(ID!)
                }
            }
        })
    }
}
