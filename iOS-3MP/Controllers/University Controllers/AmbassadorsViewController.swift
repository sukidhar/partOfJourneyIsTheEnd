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
    var users = [UserModel]()
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        users = []
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        collectionView.register(UINib(nibName: "UserIconCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "userIconCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if self.title == "Student Representatives" {
            loadRepresentatives()
        }else if self.title == "EduMates Experts"{
            loadEdumatesExperts()
        }
    }
    
    func loadRepresentatives(){
        if let university = university{
            let ref = Database.database().reference().child("ambassadors").child(university.ID)
                ref.observe(.value) { (snap) in
                for child in snap.children.allObjects as! [DataSnapshot]{
                    if child.key != DataService().keyChain.get("uid"){
                        self.getUser(partner: child.key) { (partner) in
                            if let user = partner{
                                user.type = child.value as? String
                                self.users.append(user)
                                print(self.users)
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            ref.removeAllObservers()
        }
    }
    
    func loadEdumatesExperts(){
        Database.database().reference().child("experts").observe(.value) { (snap) in
            for child in snap.children.allObjects as! [DataSnapshot]{
                self.getUser(partner: child.key) { (partner) in
                    if let user = partner{
                        user.type = "Edumates Experts"
                        self.users.append(user)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getUser(partner : String,handler : @escaping (_ user : UserModel?)->Void) {
        let ref = Database.database().reference().child("USER").child(partner)
        ref.observeSingleEvent(of: .value) { (snap) in
            if let data = snap.value as? [String:Any]{
                let user = UserModel()
                user.id = partner
                user.name = data["name"] as? String
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
    
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
      
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
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = users[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userIconCell", for: indexPath) as! UserIconCollectionViewCell
        cell.nameLabel.text = self.users[indexPath.row].name
        cell.courseLabel.text = self.users[indexPath.row].course
        cell.imageVIew.sd_setImage(with: URL(string: user.imageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        showChatController(for: user)
    }
    
     func showChatController(for rUser: UserModel){
        //Responsible for View Controller to go into Chat
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.hidesBottomBarWhenPushed = true
        chatController.rUser = rUser
        DBAccessor.shared.getChatID(for: rUser.id!) { (id) in
            chatController.chatID = id
        }
        navigationController?.pushViewController(chatController, animated: true)
    }

    
}
