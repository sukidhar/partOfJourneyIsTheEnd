//
//  placeModel.swift
//  mapsSubProject
//
//  Created by Sukidhar Darisi on 22/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import GoogleMaps

class Place {
    let id : String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: [String]
    var photoReference: String?
    var photo: UIImage?
//    var rating : Float!
    var marker : GMSMarker?
    var internationalContact : String?
    var website : String?
    
    init(dictionary: [String: Any])
    {
        let json = JSON(dictionary)
        id = json["place_id"].string!
        name = json["name"].stringValue
        address = json["vicinity"].stringValue
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        photoReference = json["photos"][0]["photo_reference"].string
        placeType = (json["types"].arrayObject as? [String]) ?? []
//        let rate = json["rating"].float
//        rating = rate
        internationalContact = " "
        website = " "
        DispatchQueue.main.async {
            self.marker = GMSMarker(position: self.coordinate)
            self.marker?.title = self.name
            self.marker?.snippet = self.address
        }
    }
}
