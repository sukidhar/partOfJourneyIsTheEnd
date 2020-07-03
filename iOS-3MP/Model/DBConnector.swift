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
        DataService().keyChain.clear()
        let strongBox = Strongbox()
        strongBox.remove(key: "wishlist")
        strongBox.remove(key: "dob")
        strongBox.remove(key: "data")
        try? Auth.auth().signOut()
    }
    
}

