//
//  DataService.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 13/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//



import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift

let DB_BASE = Database.database().reference()

class DataService {
    private var _keyChain = KeychainSwift()
    private var _refDatabase = DB_BASE
    
    var keyChain: KeychainSwift {
        get {
            return _keyChain
        } set {
            _keyChain = newValue
        }
    }
}
