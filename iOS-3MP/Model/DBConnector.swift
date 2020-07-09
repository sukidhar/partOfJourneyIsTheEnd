//
//  DBConnector.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 12/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import Foundation
import Firebase
import Strongbox
import CoreLocation

class DBAccessor {
    
    
    static let shared = DBAccessor()
    var userImage : UIImage?
    var userListener : ListenerRegistration?
    let sb = Strongbox()
    var universities = [UniversityModel]()
    
    func listenToUpdatesOnUser(){
        if let uid = DataService().keyChain.get("uid"){
            userListener = Firestore.firestore().collection("USER").document(uid).addSnapshotListener({ (snap, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                if let docData = snap?.data(){
                    let sb = Strongbox()
                    let _ = sb.archive((docData["memberTill"] as! Timestamp).seconds,key: "memberTill")
                }
            })
        }
    }
    
    func logOut(){
        Database.database().reference().child("fcmTokens").child(DataService().keyChain.get("uid")!).setValue(nil)
        DataService().keyChain.clear()
        let strongBox = Strongbox()
        strongBox.remove(key: "wishlist")
        strongBox.remove(key: "dob")
        strongBox.remove(key: "data")
        try? Auth.auth().signOut()
    }
    
    func getChatID(for partner : String, handler : @escaping (_ ID: String)-> Void){
            var found = false
            let ref = Database.database().reference().child("userChats").child(DataService().keyChain.get("uid")!).child(partner)
            let handle = ref.observe(.value, with: { (snap) in
                defer{
                    if !found{
                        let key = ref.childByAutoId().key
                        handler(key!)
                    }
                }
                if let data = snap.value as? [String : AnyObject]{
                    let chatID = data["chat"] as! String
                    handler(chatID)
                }
            })
            ref.removeObserver(withHandle: handle)
    }
    
    func getChatPartner(for partner : String, handler : @escaping (_ partner: Partner?)-> Void){
        var found = false
        let ref = Database.database().reference().child("userChats").child(DataService().keyChain.get("uid")!).child(partner)
        let handle = ref.observe(.value, with: { (snap) in
            defer{
                if !found{
                    handler(nil)
                }
            }
            if let data = snap.value as? [String : AnyObject]{
                let partnerID = snap.key
                let chatID = data["chat"] as! String
                let lastActive = data["lastActive"] as! Double
                let latest = data["latest"] as! String
                let name = data["name"] as! String
                found = true
                let newPartner = Partner(id: partnerID, chatID: chatID, lastActive: lastActive, latest: latest, name: name)
                handler(newPartner)
            }
        })
        ref.removeObserver(withHandle: handle)
    }
    
    
    func goOnline(){
        if status == "offline"{
            OnlineOfflineService.online(for: DataService().keyChain.get("uid")!, status: "online") { (bool) in
                if bool {
                    status = "online"
                }
            }
        }
    }
}

