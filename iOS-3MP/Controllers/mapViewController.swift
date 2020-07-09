//
//  ViewController.swift
//  mapsSubProject
//
//  Created by Sukidhar Darisi on 21/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class mapViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var UniversityName : String?
    var UniversityAddress : String?

    @IBOutlet weak var heightOfMap: NSLayoutConstraint!
    @IBOutlet weak var segmentView: UISegmentedControl!
    
    
    var placeCollection : [[Place]] = [[Place]].init(repeating: [Place](), count: 5)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView : GMSMapView!
    
    var mainCamera = GMSCameraPosition()
    
    @IBOutlet weak var mapEnclosingView: UIView!
    
    var coordinates : CLLocationCoordinate2D?
    var camera = GMSCameraPosition()
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        // Do any additional setup after loading the view.
        heightOfMap.constant = UIScreen.main.bounds.height/2
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "tcell")
        camera = GMSCameraPosition.camera(withTarget: coordinates!, zoom: 13.0)
        mapView.camera = camera
        
        mainCamera = camera
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = coordinates!
        marker.title = UniversityName
        marker.snippet = UniversityAddress
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .blue)
        segmentView.selectedSegmentIndex = 0
        tableView.dataSource = self
        tableView.delegate = self
        fetchNearby("\(UniversityName ?? "") Buildings", index: 0)
        fetchNearby("\(UniversityName ?? "") Student Accommodation", index: 1)
        fetchNearby("Food", index: 2)
        fetchNearby("Night Clubs", index: 3)

    }
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        mapView.clear()
        mapView.camera = mainCamera
        if !(sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 4){
            let marker = GMSMarker()
            marker.position = coordinates!
            marker.title = UniversityName
            marker.snippet = UniversityAddress
            marker.map = mapView
            marker.icon = GMSMarker.markerImage(with: .blue)
        }
        for place in placeCollection[sender.selectedSegmentIndex]{
            place.marker?.map = mapView
        }
        tableView.reloadData()
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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = UniversityName
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.01960784314, green: 0.137254902, blue: 0.2392156863, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func goToLoginScreen(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    func fetchNearby(_ placeType : String, index : Int)  {
        if index == 0{
            mapView.clear()
        }
        //stanford+university+buildings
        let placeParameter = placeType.replacingOccurrences(of: " ", with: "+")
        placeCollection[index] = []
        let radius = 10000
        var urlString = """
        https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinates!.latitude),\(coordinates!.longitude)&radius=\(radius)&keyword=\(placeParameter)&rankby=prominence&sensor=true&key=\(googleKey)
        """
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        let url = URL(string: urlString)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let safedata = data {
                defer{
                    self.placeCollection[4].append(contentsOf: self.placeCollection[index])
                }
                let json = try? JSON(data: safedata, options: .mutableContainers)
                print(json!)
                let results = json?["results"].arrayObject as? [[String : Any]]
                for i in results! {
                    let place = Place(dictionary: i)
                    self.placeCollection[index].append(place)
                    DispatchQueue.main.async {
                        if index == 0{
                            place.marker?.icon = GMSMarker.markerImage(with: .blue)
                            place.marker?.map = self.mapView
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeCollection[segmentView.selectedSegmentIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tcell", for: indexPath) as! PlaceTableViewCell
        let place = placeCollection[segmentView.selectedSegmentIndex][indexPath.row]
        cell.textLabel?.text = place.name
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let swipedPlace = placeCollection[segmentView.selectedSegmentIndex][indexPath.row]
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)
             {
                var urlString = "comgooglemaps-x-callback://?q=\(swipedPlace.name)&center=\(swipedPlace.coordinate.latitude),\(swipedPlace.coordinate.longitude)&views=satellite,traffic&zoom=15"
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }
            else{
                var urlString = "http://maps.google.com/maps?q=\(swipedPlace.name)&center=\(swipedPlace.coordinate.latitude),\(swipedPlace.coordinate.longitude)&views=satellite,traffic&zoom=15"
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = placeCollection[segmentView.selectedSegmentIndex][indexPath.row]
        moveCamera(coordinate: place.coordinate)
        mapView.selectedMarker = place.marker
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    func moveCamera (coordinate : CLLocationCoordinate2D)
    {
        camera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16.0)
        mapView.camera = camera
    }
    

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

