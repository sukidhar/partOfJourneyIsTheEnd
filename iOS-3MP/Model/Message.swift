//
//  Message.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase
class Message: NSObject {
    
    var keychain = DataService().keyChain
    var receiverId: String?
    var senderId: String?
    var timestamp : Double?
    var content: String?
    
    func chatPartnerId() -> String? {
        let condition1 = self.senderId == keychain.get("uid")
        let condition2 = self.receiverId == keychain.get("uid")
        if condition1 || condition2 {
            if condition1{
                return receiverId
            }
            else{
                return senderId
            }
        }
        else{
            return nil
        }
    }
}
