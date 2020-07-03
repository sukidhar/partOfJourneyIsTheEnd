//
//  PlaceMarker.swift
//  mapsSubProject
//
//  Created by Sukidhar Darisi on 22/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//
import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
  let place: Place
  
  init(place: Place) {
    self.place = place
    super.init()
    
    position = place.coordinate
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = .pop
  }
}

