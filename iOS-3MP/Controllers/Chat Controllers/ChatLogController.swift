//
//  ChatLogController.swift
//  iOS-3MP
//
//  Created by ingenuo-yag on 27/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    let db = Database.database().reference()
    var refresher : UIRefreshControl!
    var didSetValues = false
    let keychain = DataService().keyChain
    let headerId = "headerView"
    var boxView : UIView!
    var ai : UIActivityIndicatorView!
    var rUser:UserModel? {
        didSet{
            setNavBar()
        }
    }
    var chatID : String?{
        didSet{
           observeChat()
            didSetValues = true
        }
    }
    private var daysOfTheWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var previousIndex : Int?
    var selectedIndex : Int?
    let containerView = UIView()
    var heightConstraintOfContainerView : NSLayoutConstraint!
    var noMoreMessages = false
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    func setNavBar(){
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 64, height: 64))

        let titleView:UIView = UIView(frame: rect)
        
        let imageView = UIImageView()
        imageView.sd_setImage(with: URL(string: rUser?.imageUrl ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        imageView.center = CGPoint(x: titleView.center.x-70, y: titleView.center.y-10)
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
        imageView.layer.masksToBounds = true
        titleView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: -10, y: 10, width: UIScreen.main.bounds.width/2, height: 24))
        label.text = rUser?.name
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        titleView.addSubview(label)
        
        let statusBulb : UIView = {
            let bulb = UIView(frame: CGRect(x: imageView.center.x+10, y: imageView.center.y-20, width: 10, height: 10))
            bulb.layer.cornerRadius = 5
            bulb.translatesAutoresizingMaskIntoConstraints = false
            bulb.layer.masksToBounds = true
            bulb.backgroundColor = .gray
            return bulb
        }()
        if let id = rUser!.id{
        Database.database().reference().child("USER").child(id).observe(.value) { (snap) in
                if let data = snap.value as? [String : Any]{
                    if data["status"] as? String ?? "offline" == "online"{
                        statusBulb.backgroundColor = .green
                    }
                    else{
                        statusBulb.backgroundColor = .gray
                    }
                }
            }
        }
        titleView.addSubview(statusBulb)
        self.navigationItem.titleView = titleView
    }
    
    struct NewMessage {
        let id : String
        let content : String
        let sender : String
        let timeStamp : Double
    }
    
    
    var chatMessages = [NewMessage]()
    
    @objc func observeChat(){
        if let id = chatID{
            let chat = db.child("chats").child(id).queryOrderedByKey().queryLimited(toLast: 50)
            uploadView()
            defer{
                if chatMessages.count == 0{
                    NotificationCenter.default.post(name: NSNotification.Name("noreMoreMessages"), object: true)
                }
            }
            chat.observe(.childAdded) { (snap) in
                defer{
                     let actualMessages = self.chatMessages.filter { (message) -> Bool in
                         return message.id != "dateChanged"
                     }
                    if actualMessages.count < 50 {
                         NotificationCenter.default.post(name: NSNotification.Name("noreMoreMessages"), object: true)
                     }else{
                         NotificationCenter.default.post(name: NSNotification.Name("noreMoreMessages"), object: false)
                     }
                }
                if let messageData = snap.value as? [String:Any]{
                    let id = snap.key
                    let content = messageData["content"] as! String
                    let sender = messageData["sender"] as! String
                    let timestamp = messageData["timestamp"] as! Double
                    let message = NewMessage(id: id, content: content.trimmingCharacters(in: .whitespacesAndNewlines)+" ", sender: sender, timeStamp: timestamp)
                    self.chatMessages.append(message)
                    if self.chatMessages.count == 1 {
                        let dateLabelingMessage = NewMessage(id: "dateChanged", content: self.cellContentForTimestamps(for : Date(timeIntervalSince1970: message.timeStamp/1000)), sender: "system", timeStamp: .nan)
                        self.chatMessages.insert(dateLabelingMessage, at: 0)
                    }else {
                        if !(Date(timeIntervalSince1970: self.chatMessages[self.chatMessages.count-2].timeStamp/1000).shortDate == Date(timeIntervalSince1970: message.timeStamp/1000).shortDate)  {
                            let dateLabelingMessage = NewMessage(id: "dateChanged", content: self.cellContentForTimestamps(for : Date(timeIntervalSince1970: message.timeStamp/1000)), sender: "system", timeStamp: .nan)
                            self.chatMessages.insert(dateLabelingMessage, at: self.chatMessages.count-1)
                        }
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.collectionView.scrollToItem(at: IndexPath(item: self.chatMessages.count-1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
        }
    }
    
    var moreMessages = [NewMessage]()
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -90 {
            if let id = chatID{
                if chatMessages.count == 0{
                    observeChat()
                    return
                }
                if noMoreMessages{
                    return
                }
                let mid = chatMessages[1].id
                let chat = Database.database().reference().child("chats").child(id).queryOrderedByKey().queryLimited(toLast: 100).queryEnding(atValue: mid)
                NotificationCenter.default.post(name: NSNotification.Name("loadingMessages"), object: nil)
                chat.observe(.childAdded) { (snap) in
                    if let messageData = snap.value as? [String:Any]{
                        let id = snap.key
                        if id == mid{
                           
                            let count = self.moreMessages.count
                            self.moreMessages.reverse()
                            for message in self.moreMessages{
                                if Date(timeIntervalSince1970: message.timeStamp/1000).shortDate == Date(timeIntervalSince1970: self.chatMessages[1].timeStamp/1000).shortDate {
                                    self.chatMessages.insert(message, at: 1)
                                }else{
                                    self.chatMessages.insert(message, at: 0)
                                    let dateLabelingMessage = NewMessage(id: "dateChanged", content: self.cellContentForTimestamps(for : Date(timeIntervalSince1970: message.timeStamp/1000)), sender: "system", timeStamp: .nan)
                                    self.chatMessages.insert(dateLabelingMessage, at: 0)
                                }
                            }
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                if count > 5
                                {
                                  self.collectionView.scrollToItem(at: IndexPath(item: count-1, section: 0), at: .bottom, animated: false)
                                }
                                if count < 99{
                                    NotificationCenter.default.post(name: NSNotification.Name("noreMoreMessages"), object: true)
                                }else{
                                    NotificationCenter.default.post(name: NSNotification.Name("noreMoreMessages"), object: false)
                                }
                            }
                            self.moreMessages = []
                            return
                        }
                        let content = messageData["content"] as! String
                        let sender = messageData["sender"] as! String
                        let timestamp = messageData["timestamp"] as! Double
                        
                        let message = NewMessage(id: id, content: content + " ", sender: sender, timeStamp: timestamp)
                        self.moreMessages.append(message)
                    }
                }
            }
        }
    }
    
    func cellContentForTimestamps(for date : Date)->String{
        let calendar = Calendar.current
        if calendar.isDateInYesterday(date){
            return "Yesterday"
        }
        if calendar.isDateInToday(date){
            return "Today"
        }
        let units = Set<Calendar.Component>([.weekday,.day])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())
        if components.day! <= 7 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayInWeek = dateFormatter.string(from: date)
            return dayInWeek
        }else{
            return date.mediumDate
        }
    }
    
    @objc func shouldShowLoader(){
        uploadView()
    }
    
    @objc func shouldHideLoader(_ notification : Notification){
        if let moreMessages = notification.object as? Bool{
            if !moreMessages{
                noMoreMessages = false
            }else{
                noMoreMessages = true
                collectionView.reloadData()
            }
            removeLoader()
        }
    }
    
    
    lazy var inputTextView : UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.delegate = self
        view.keyboardType = .default
        view.text = "Enter message......"
        view.textColor = .lightGray
        view.dataDetectorTypes = .all
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = view.font?.withSize(14)
        view.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 6, right: 4)
        return view
    }()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: self.chatMessages.count-1, section: 0), at: .bottom, animated: true)
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    

    func textViewDidChange(_ textView: UITextView) {
        NotificationCenter.default.post(name: NSNotification.Name("numberOfLines"), object: textView.numberOfLines)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter message......"
            textView.textColor = UIColor.lightGray
        }
    }
    

    @objc fileprivate func applicationIsActive() {
        canLogin()
        guard let uid = DataService().keyChain.get("uid") else{
            return
        }
        
        OnlineOfflineService.online(for: uid, status: "online") { (bool) in
            print(bool)
        }
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
    
    let checkers = Checkers()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowLoader), name: NSNotification.Name("loadingMessages"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldHideLoader(_ :)), name: NSNotification.Name("noreMoreMessages"), object: nil)
        keyboardNotifications()
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        navigationController?.navigationBar.prefersLargeTitles = false
        self.additionalSafeAreaInsets.top = 30
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        self.view.addGestureRecognizer(tap)
        self.tabBarController?.tabBar.isHidden = true
        collectionView.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        setUpBottomBar()
        UIBarButtonItem.appearance().tintColor = .black
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func uploadView() {
        // You only need to adjust this frame to move it anywhere you want
       boxView = UIView(frame: CGRect(x: view.frame.midX - 140, y: 110, width: 280, height: 50))
       boxView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
       boxView.alpha = 0.8
       boxView.layer.cornerRadius = 10
        ai = UIActivityIndicatorView()
        ai.color = .white
        ai.style = .white
        ai.hidesWhenStopped = true
        ai.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ai.startAnimating()

        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.white
        textLabel.text = "loading previous messages"

       
        boxView.addSubview(ai)
        boxView.addSubview(textLabel)

        view.addSubview(boxView)
    }
    
    func removeLoader(){
        ai.stopAnimating()
        boxView.removeFromSuperview()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderCollectionView
        if noMoreMessages {
            if let user = rUser{
                header.user = user
            }
            return header
        }
        else{
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if noMoreMessages{
            return CGSize(width: self.view.frame.width, height: 110)
        }else{
            return CGSize(width: self.view.frame.width, height: 0)
        }
        
    }
    var bottomConstraintForKeyboard: NSLayoutConstraint!

    @objc func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraintForKeyboard.constant = k - view.safeAreaLayoutGuide.layoutFrame.height + 5
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: self.chatMessages.count-1, section: 0), at: .bottom, animated: true)
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraintForKeyboard.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func clearKeyboard() {
        view.endEditing(true)
    }

    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        navigationItem.titleView?.isHidden = false
    }
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        navigationItem.titleView?.isHidden = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = chatMessages[indexPath.item]
        if message.id == "dateChanged"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            for view in cell.subviews{
                view.removeFromSuperview()
            }
            let label : UILabel = {
                let text = UILabel()
                text.translatesAutoresizingMaskIntoConstraints = false
                text.font = text.font.withSize(13)
                text.textAlignment = .center
                text.textColor = .gray
                
                return text
            }()
            label.text = message.content
            cell.addSubview(label)
            label.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 3).isActive = true
            label.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -3).isActive = true
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0).isActive = true
            label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0).isActive = true
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        
        cell.textView.text = message.content
        if message.sender == keychain.get("uid"){
          //outgoing msgs orange
            if #available(iOS 13.0, *) {
                cell.textView.backgroundColor = .systemGray5
            } else {
                cell.textView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 1)
            }
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = true
            cell.textViewRightAnchor?.isActive = true
            cell.textViewLeftAnchor?.isActive = false
            cell.statusBulb.isHidden = true
            cell.timestamp.textAlignment = .right
            cell.timestamp.textColor = .black
        }
        else{
            cell.profileImageView.sd_setImage(with: URL(string: rUser?.imageUrl ?? "default"), placeholderImage: #imageLiteral(resourceName: "default"), options: .progressiveLoad)
            cell.profileImageView.isHidden = false
            cell.textViewRightAnchor?.isActive = false
            cell.textViewLeftAnchor?.isActive = true
            cell.statusBulb.isHidden = false
            cell.textView.backgroundColor = .orange
            cell.textView.textColor = UIColor.white
            cell.timestamp.textAlignment = .left
            cell.timestamp.textColor = .white
        }
        cell.timestamp.font = cell.timestamp.font.withSize(12)
        cell.timestamp.text = Date(timeIntervalSince1970: message.timeStamp/1000).shortTime
        status(cell: cell, message: message)
        cell.textView.isUserInteractionEnabled = false
        cell.textView.isScrollEnabled = false
        cell.textViewWidthAncor?.constant = (estimateFrameForText(message.content).width < 32 ? 60 : estimateFrameForText(message.content).width) + 35
        cell.textView.layer.cornerRadius = 18
        return cell
    }
    
   
    
    func cell(for indexPath : IndexPath)->ChatMessageCell{
        let cell = collectionView.cellForItem(at: indexPath) as! ChatMessageCell
        return cell
    }
    
    private func status(cell : ChatMessageCell, message: NewMessage){
        let id = message.sender
        Database.database().reference().child("USER").child(id).observe(.value) { (snap) in
                if let data = snap.value as? [String : Any]{
                    if data["status"] as? String ?? "offline" == "online"{
                        cell.statusBulb.backgroundColor = .green
                    }
                    else{
                        cell.statusBulb.backgroundColor = .gray
                    }
                }
            }
    }
    
    @objc func dismissEditing(_ sender : UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if chatMessages[indexPath.item].id == "dateChanged"{
            return CGSize(width: view.frame.width, height: 20)
        }
        let height = estimateFrameForText(chatMessages[indexPath.item].content).height + 25
        
        return CGSize(width: view.frame.width, height: height + 15)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 205, height: .max)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    
    func setUpBottomBar(){
       NotificationCenter.default.addObserver(self, selector: #selector(changeHeightOfTextView), name: NSNotification.Name("numberOfLines"), object: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        view.bringSubviewToFront(containerView)
        containerView.backgroundColor = .white
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor , constant: 0).isActive = true
        bottomConstraintForKeyboard = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor , constant: 0).isActive = true
        heightConstraintOfContainerView = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 75)
         NSLayoutConstraint.activate([bottomConstraintForKeyboard,heightConstraintOfContainerView])
        let textViewHolder = UIView()
        textViewHolder.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textViewHolder)
        textViewHolder.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        textViewHolder.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        textViewHolder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25).isActive = true
        
        textViewHolder.layer.borderWidth = 1
        textViewHolder.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        textViewHolder.layer.cornerRadius = 20
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25).isActive = true
        textViewHolder.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0).isActive = true
        
        textViewHolder.addSubview(inputTextView)
        inputTextView.leftAnchor.constraint(equalTo: textViewHolder.leftAnchor, constant: 8).isActive = true
        inputTextView.topAnchor.constraint(equalTo: textViewHolder.topAnchor, constant: 6).isActive = true
        inputTextView.rightAnchor.constraint(equalTo: textViewHolder.rightAnchor, constant: 0).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: textViewHolder.bottomAnchor, constant: -6).isActive = true
        inputTextView.centerYAnchor.constraint(equalTo: textViewHolder.centerYAnchor, constant: 0).isActive = true
    }
    
    
    
    @objc func changeHeightOfTextView(){
        let maxHeight = inputTextView.font!.lineHeight * CGFloat(inputTextView.numberOfLines)
        if inputTextView.numberOfLines > 4 {
            inputTextView.isScrollEnabled = true
            return
        }
        if inputTextView.numberOfLines <= 1 {
            heightConstraintOfContainerView.constant = 75
        }else{
            heightConstraintOfContainerView.constant = 75 - 16.1 + maxHeight
        }
    }
    
    @objc func handleSend() {
        if let id = chatID,var text = inputTextView.text{
            if text.count == 0 || inputTextView.textColor == UIColor.lightGray{
                return
            }
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let ref = Database.database().reference().child("chats").child(id).childByAutoId()
            let timestamp = ServerValue.timestamp()
            let child = ["content" : text, "sender" : keychain.get("uid")!, "timestamp" : timestamp] as [String : Any]
            ref.updateChildValues(child) { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Error", message: "Sorry we failed to send the message", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.inputTextView.text = nil
                self.heightConstraintOfContainerView.constant = 75
                self.updateUserChats(text: text, timestamp: timestamp)
                self.updatePartnerChats(text: text, timestamp: timestamp)
            }
        }
    }
    
    func updateUserChats(text  : String, timestamp : [AnyHashable : Any] ){
        if let uid = keychain.get("uid"), let partnerID = rUser?.id, let id = chatID{
            let values = ["chat" : id, "lastActive" : timestamp, "latest" : text, "name" : rUser?.name! as Any ] as [String : Any]
            Database.database().reference().child("userChats").child(uid).child(partnerID).updateChildValues(values) { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    func updatePartnerChats(text : String, timestamp : [AnyHashable : Any]){
        if let uid = keychain.get("uid"), let partnerID = rUser?.id, let id = chatID{
            let values = ["chat" : id, "lastActive" : timestamp, "latest" : text, "name" : keychain.get("name")!] as [String : Any]
            Database.database().reference().child("userChats").child(partnerID).child(uid).updateChildValues(values) { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}



fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

