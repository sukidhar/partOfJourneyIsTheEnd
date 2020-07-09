//
//  UniversityViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import SafariServices
import WebKit

class UniversityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    

    @IBOutlet weak var universityImage: UIImageView!
    var  university  : UniversityModel?
    enum CardState {
        case expanded
        case collapsed
    }
    static var i = 0
    @IBOutlet weak var backButton: UIButton!
    var popUpUniversityViewController : PopUpUniversityViewController!
    var visualEffectView : UIVisualEffectView!
    
    let cardHeight:CGFloat = UIScreen.main.bounds.height * (4/5)
    let cardHandleAreaHeight:CGFloat =  UIScreen.main.bounds.height * (1.3/4)
    var departments : [Department] = []
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    let url = "https://youtu.be/embed/OVQflPxD8ik"
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        
        UniversityViewController.i = 0
        setupCard()
        if let uni = university{
            defer{
                popUpUniversityViewController.departmentCollectionView.reloadData()
            }
            for dept in uni.rawDept{
                departments.append(convertDictionaryToDepartmentModel(dict: dept))
            }
        }
        
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        loadWebView()
               // Do any additional setup after loading the view.
        universityImage.sd_setImage(with: URL(string: university!.imageURL), placeholderImage: nil, options: .progressiveLoad)
        popUpUniversityViewController.departmentCollectionView.delegate = self
        popUpUniversityViewController.departmentCollectionView.dataSource = self
        popUpUniversityViewController.departmentCollectionView.register(UINib(nibName: "DepartmentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "deptCell")
    }
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        if self.tabBarController?.tabBar.items?[1].title == "My University"{
            self.hidesBottomBarWhenPushed = false
            backButton.isHidden = true
            self.tabBarController?.tabBar.isHidden = false
            if let isAmb = DataService().keyChain.getBool("isAmbassador"){
                self.tabBarController?.tabBar.isHidden = !isAmb
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        canLogin()
    }
    func canLogin(){
        Checkers().alertMaker(view: self)
        let value = Checkers().dateObserver()
        if value < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    func goToLoginScreen(){
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
           self.view.window?.rootViewController = vc
           self.view.window?.makeKeyAndVisible()
    }
    func loadWebView(){
        let roughUrl = university!.videoURL
        guard let id = roughUrl.youtubeID else{
            return
        }
        let playvarsDic = ["controls": 1, "playsinline": 1, "showinfo": 1, "modestbranding": 1]
        popUpUniversityViewController.videoView.load(withVideoId: id, playerVars: playvarsDic)
    }
    func convertDictionaryToDepartmentModel(dict : [String:String]) -> Department{
        let name = dict["name"]
        let link = dict["link"]
        print(UniversityViewController.i)
        UniversityViewController.i+=1
        let department = Department(name : name ?? "", link : link ?? "")
        return department
    }
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        self.visualEffectView.removeFromSuperview()
        
        popUpUniversityViewController = PopUpUniversityViewController(nibName:"PopUpUniversityViewController", bundle:nil)
        self.addChild(popUpUniversityViewController)
        self.view.addSubview(popUpUniversityViewController.view)
        
        popUpUniversityViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        popUpUniversityViewController.view.clipsToBounds = true
        self.popUpUniversityViewController.view.round(corners: [.topLeft,.topRight], cornerRadius: 44)
        
        popUpUniversityViewController.universityTItle.text = university?.title
        popUpUniversityViewController.descriptionLabel.text =  university?.description ?? ""
        let frame = NSString(string: popUpUniversityViewController.descriptionLabel.text).boundingRect(
            with: CGSize(width: self.view.frame.width - 60, height: .infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font : UIFont(name: "helvetica neue", size: 15)!],
            context: nil)
        let height = frame.size.height + 20
        print(height)
        popUpUniversityViewController.descriptionLabel.isScrollEnabled = false
        popUpUniversityViewController.heightOfDescription.constant = height
        popUpUniversityViewController.heightOfEntireCard.constant = 1128 + height
        popUpUniversityViewController.heightOfDescriptionHolder.constant = 148 + height
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UniversityViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UniversityViewController.handleCardPan(recognizer:)))
        
        popUpUniversityViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        popUpUniversityViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        popUpUniversityViewController.exploreButton.addTarget(self, action: #selector(explorePressed(_ :)), for: .touchUpInside)
        popUpUniversityViewController.chatButton.addTarget(self, action: #selector(chatPressed(_ :)), for: .touchUpInside)
        popUpUniversityViewController.segmentControl.addTarget(self, action: #selector(typeChanged(_ :)), for: .valueChanged)
    }
    @objc func typeChanged(_ sender : UISegmentedControl){
        if sender.selectedSegmentIndex == 1{
            defer{
                sender.selectedSegmentIndex = 0
            }
            let urlString = university?.FAQ
            if urlString != ""{
                guard let url = URL(string: urlString!) else { return }
                let safariVC = SFSafariViewController(url: url)
                present(safariVC,animated:  true)
            }
        }
    }
    func loadDepartments(){
            if let uni = university{
                for dept in uni.rawDept{
                    departments.append(convertDictionaryToDepartmentModel(dict: dept))
                    DispatchQueue.main.async {
                        self.popUpUniversityViewController.departmentCollectionView.reloadData()
                    }
                }
            }
    }
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.5)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.8)
            popUpUniversityViewController.scrollView.isScrollEnabled = false
        case .changed:
            let translation = recognizer.translation(in: self.popUpUniversityViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            print(fractionComplete)
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
            popUpUniversityViewController.scrollView.isScrollEnabled = true
        default:
            break
        }
        
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
           if runningAnimations.isEmpty {
               animateTransitionIfNeeded(state: state, duration: duration)
           }
           for animator in runningAnimations {
               animator.pauseAnimation()
               animationProgressWhenInterrupted = animator.fractionComplete
           }
       }
       
       func updateInteractiveTransition(fractionCompleted:CGFloat) {
           for animator in runningAnimations {
               animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
           }
       }
       
       func continueInteractiveTransition (){
           for animator in runningAnimations {
               animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
           }
       }
    
        func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.flip(first: self.popUpUniversityViewController.handleImage, second:  self.popUpUniversityViewController.handleImage2, bool: true)
                        self.popUpUniversityViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    case .collapsed:
                        self.flip(first: self.popUpUniversityViewController.handleImage, second:  self.popUpUniversityViewController.handleImage2, bool: false)
                        self.popUpUniversityViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                        self.popUpUniversityViewController.scrollView.setContentOffset(.zero, animated: true)
                    }
                }
                
                frameAnimator.addCompletion { _ in
                    self.cardVisible = !self.cardVisible
                    self.runningAnimations.removeAll()
                }
                
                frameAnimator.startAnimation()
                runningAnimations.append(frameAnimator)
                
                
                let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                    switch state {
                    case .expanded:
                        self.popUpUniversityViewController.view.round(corners: [.topLeft, .topRight], cornerRadius: 35)
                    case .collapsed:
                        self.popUpUniversityViewController.view.round(corners: [.topLeft, .topRight], cornerRadius: 35)
                    }
                }
                
                cornerRadiusAnimator.startAnimation()
                runningAnimations.append(cornerRadiusAnimator)
                
                let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    case .collapsed:
                        self.visualEffectView.effect = nil
                    }
                }
                
                blurAnimator.startAnimation()
                runningAnimations.append(blurAnimator)
                
            }
        }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chatPressed(_ sender : UIButton){
        if let storyboard = self.storyboard{
            if let vc = storyboard.instantiateViewController(withIdentifier: "UniversityChatViewController") as? UniversityChatViewController{
                vc.university = university
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func explorePressed(_ sender : UIButton)
    {
        if let storyboard = self.storyboard{
            if let mapVC = storyboard.instantiateViewController(withIdentifier: "mapViewController") as? mapViewController{
                mapVC.navigationItem.title =  university?.title ?? "Explore"
                mapVC.coordinates = CLLocationCoordinate2D(latitude: university!.lattitude, longitude: university!.longitude)
                mapVC.UniversityName = university?.title ?? ""
                mapVC.UniversityAddress = university?.address ?? ""
                self.navigationController?.pushViewController(mapVC, animated: true)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController{
            
            if let mapVC = nav.topViewController as? mapViewController{
                mapVC.navigationItem.title =  university?.title ?? "Explore"
                mapVC.coordinates = CLLocationCoordinate2D(latitude: university!.lattitude, longitude: university!.longitude)
                mapVC.UniversityName = university?.title ?? ""
                mapVC.UniversityAddress = university?.address ?? ""
            }
            
            if let chatVC = nav.topViewController as? UniversityChatViewController{
                chatVC.university = university
            }
            
        }
    }
    
    //MARK: - TODO
    
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //have added this so build doesnt fail when u clone it now
            return departments.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            //have added this so build doesnt fail when u clone it now
           // let titleLabel = keys?[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deptCell", for: indexPath) as! DepartmentCollectionViewCell
            cell.titleLabel.text = departments[indexPath.row].name
            cell.crestImage.sd_setImage(with: URL(string: university!.logo), placeholderImage: nil, options: .progressiveLoad)
                   return cell
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let url = URL(string: departments[indexPath.row].link){
            let safariVC = SFSafariViewController(url: url)
            present(safariVC,animated:  true)
            }
        }
        
    func flip(first view1 : UIImageView, second view2 : UIImageView, bool : Bool) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]

            UIImageView.transition(with: view1, duration: 1.0, options: transitionOptions, animations: {
                view1.isHidden = bool
            })

            UIImageView.transition(with: view2, duration: 1.0, options: transitionOptions, animations: {
                view2.isHidden = !bool
            })
    }
}
