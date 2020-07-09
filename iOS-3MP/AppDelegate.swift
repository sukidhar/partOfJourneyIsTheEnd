//
//  AppDelegate.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 11/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GooglePlaces
import GoogleMaps
import IQKeyboardManagerSwift
import UserNotifications
import FirebaseMessaging

let googleKey = "AIzaSyAkU6z7jNV_DyUCPJhVYKjEzHfNJsYjEPI"
let gcmMessageIDKey = "gcm.message_id"
var status = "offline"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        setNotificationConfiguration()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()

        application.applicationIconBadgeNumber = 0
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatLogController.self)
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatLogController.self]
        Database.database().isPersistenceEnabled = true
        if let uid = DataService().keyChain.get("uid"){
            if status == "offline"{
                OnlineOfflineService.online(for: uid, status: "online") { (bool) in
                    status = "online"
                }
            }
        }
        if let launchOptions = launchOptions,
            let userInfo = launchOptions[.remoteNotification] as? [AnyHashable: Any]
        {
            if let threadId = userInfo["threadId"] as? String,let title = userInfo["title"] as? String{
              showChatViewController(threadId: threadId, title: title)
            }
        }
        
        GMSServices.provideAPIKey(googleKey)
        GMSPlacesClient.provideAPIKey(googleKey)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let uid = DataService().keyChain.get("uid"){
            OnlineOfflineService.online(for: uid, status: "offline") { (bool) in
                print(bool)
            }
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let uid = DataService().keyChain.get("uid"){
            OnlineOfflineService.online(for: uid, status: "online") { (bool) in
                print(bool)
            }
        }
    }
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func setNotificationConfiguration(){
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions : UNAuthorizationOptions = [.alert,.badge,.sound]
        
        let viewAction = UNNotificationAction(identifier: "view", title: "View", options: [.authenticationRequired])
        
        let replyAction = UNTextInputNotificationAction(identifier: "reply", title: "Reply", options: [.authenticationRequired])
        
        let category = UNNotificationCategory(identifier: "eduMatesNotification", actions: [viewAction,replyAction], intentIdentifiers: [],hiddenPreviewsBodyPlaceholder: "", options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iOS_3MP")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    Messaging.messaging().appDidReceiveMessage(userInfo)
    print("notification")
    if isChatController(){
        completionHandler([])
    }else if isChatLogController(senderId: userInfo["threadId"] as? String){
        completionHandler([])
    }
    else{
        completionHandler([[.alert,.badge,.sound]])
    }
  }
    
    private func isChatController()->Bool{
        guard let tabBarVC = UIApplication.shared.windows.filter( {$0.rootViewController is UITabBarController } ).first?.rootViewController as? UITabBarController else { return false }
        let firstNavbar = tabBarVC.selectedViewController as? UINavigationController
        let topVC = firstNavbar?.topViewController
        if topVC is ChatController{
            return true
        }
        return false
    }
    
    private func isChatLogController(senderId : String?)->Bool{
        guard let id = senderId else {return false}
        guard let tabBarVC = UIApplication.shared.windows.filter( {$0.rootViewController is UITabBarController } ).first?.rootViewController as? UITabBarController else { return false}
        let firstNavbar = tabBarVC.selectedViewController as? UINavigationController
        if let topVC = firstNavbar?.topViewController as? ChatLogController{
            if topVC.rUser?.id == id {
                return true
            }
        }
        return false
    }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    if let senderId = userInfo["threadId"] as? String{
        print(response.actionIdentifier)
        if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" || response.actionIdentifier == "view"{
            let title = response.notification.request.content.title
            showChatViewController(threadId: senderId,title : title)
        }else if response.actionIdentifier == "reply"{
            if let textResponse = response as? UNTextInputNotificationResponse{
                var text = textResponse.userText
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                DBAccessor.shared.getChatPartner(for: senderId) { (sender) in
                    if let partner = sender{
                        let ref = Database.database().reference().child("chats").child(partner.chatID).childByAutoId()
                        let timestamp = ServerValue.timestamp()
                        let child = ["content" : text, "sender" : DataService().keyChain.get("uid")!, "timestamp" : timestamp, "recv" : senderId, "senderName" : DataService().keyChain.get("name")!] as [String : Any]
                        ref.setValue(child)
                        self.updateUserChats(text: text, timestamp: timestamp, partner: partner)
                        self.updatePartnerChats(text: text, timestamp: timestamp, partner: partner)
                    }
                }
            }
        }
    }
    completionHandler()
  }
    
    func updateUserChats(text  : String, timestamp : [AnyHashable : Any] , partner : Partner){
        if let uid = DataService().keyChain.get("uid"){
            let values = ["chat" : partner.chatID, "lastActive" : timestamp, "latest" : text, "name" : partner.name as Any ] as [String : Any]
            Database.database().reference().child("userChats").child(uid).child(partner.id).updateChildValues(values) { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    func updatePartnerChats(text : String, timestamp : [AnyHashable : Any], partner : Partner){
        if let uid = DataService().keyChain.get("uid"){
            let values = ["chat" : partner.chatID, "lastActive" : timestamp, "latest" : text, "name" : DataService().keyChain.get("name")!] as [String : Any]
            Database.database().reference().child("userChats").child(partner.id).child(uid).updateChildValues(values) { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    

    
    func showChatViewController(threadId : String,title : String){
        guard let tabBarVC = UIApplication.shared.windows.filter( {$0.rootViewController is UITabBarController } ).first?.rootViewController as? UITabBarController else { return }
        tabBarVC.selectedIndex = 0
        guard let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatController") as? ChatController else {
            return }
        
        if let navController = tabBarVC.viewControllers?[0] as? UINavigationController {
           navController.popToRootViewController(animated: false)
           navController.pushViewController(chatVC, animated: false)
            let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            DBAccessor.shared.getChatID(for: threadId) { (string) in
                let chatId = string
                chatVC.getUser(partner: threadId) { (partnerUser) in
                    if let user = partnerUser{
                        user.id = threadId
                        user.name = title
                        chatVC.hidesBottomBarWhenPushed = true
                        chatController.rUser = user
                        chatController.chatID = chatId
                        if navController.topViewController is ChatLogController{
                            navController.popToViewController(chatVC, animated: false)
                        }
                        navController.pushViewController(chatController, animated: false)
                    }
                }
            }
        }
        
    }
    
    func getUniversity()->UniversityModel?{
        if let savedUni = UserDefaults.standard.object(forKey: "ambassadorUniversity") as? Data{
            let decoder = JSONDecoder()
            if let university = try? decoder.decode(UniversityModel.self, from: savedUni){
                return university
            }
        }
        return nil
    }
    
}

extension AppDelegate: MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let keychain = DataService().keyChain
        print(fcmToken)
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        // sending the changed token to database fcmToken
        if let uid = keychain.get("uid"){
            Database.database().reference().child("fcmToken").child(uid).setValue(fcmToken)
        }
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
