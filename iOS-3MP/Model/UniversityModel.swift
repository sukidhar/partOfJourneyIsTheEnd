//
//  UniversityModel.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 15/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//


import UIKit
import CoreLocation

struct UniversityModel : Codable{
    let ID : String
    let description : String?
    let imageURL : String
    let title : String
    let longitude : Double
    let lattitude : Double
    let address : String
    let rawDept : [[String:String]]
    var Departments : [Department]
    let FAQ : String
    let logo : String
    let videoURL : String
}
