//
//  ContactUsViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 03/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate{

    @IBOutlet weak var heightOfTextView: NSLayoutConstraint!
    @IBOutlet weak var subjectField: UITextView!
    @IBOutlet weak var textField: UITextView!
    let checkers = Checkers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkers.isGoingToBackground()
        Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
        subjectField.delegate = self
        // Do any additional setup after loading the view.
    }
    @objc fileprivate func applicationIsActive() {
        canLogin()
        DBAccessor.shared.goOnline()
    }
    override func viewDidAppear(_ animated: Bool) {
        canLogin()
    }
    func canLogin(){
        if Checkers().dateObserver() < 0 {
            DBAccessor.shared.logOut()
            goToLoginScreen()
        }
    }
    

    
    func textViewDidChange(_ textView: UITextView) {
        
        textView.isScrollEnabled = !(textView.numberOfLines < 3)
        if !textView.isScrollEnabled {
            heightOfTextView.constant = estimateFrameForText(textView.text).height + 20
        }
        
        
    }
    
    func goToLoginScreen(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }

   @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func messageSendingButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            guard let text = textField.text else{
                let alert = UIAlertController(title: "Oops!", message: "Please enter some text", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact@edumates.co"])
            mail.setSubject(subjectField.text ?? "Please Enter The Subject")
            mail.setMessageBody("<p>\(text)</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Sorry, We cant send your message at the moment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
    
    @IBAction func instagramButton(_ sender: UIButton) {
        let url = URL(string: "https://www.instagram.com/edumates.co/")!
        let application = UIApplication.shared
        // Check if the facebook App is installed
        if application.canOpenURL(url) {
            application.open(url)
        } else {
            // If Facebook App is not installed, open Safari with Facebook Link
            application.open(URL(string: "https://www.instagram.com/edumates.co/")!)
        }
    }
    
    @IBAction func linkedinButton(_ sender: UIButton) {
              let url = URL(string: "https://www.linkedin.com/organization-guest/company/edumates?challengeId=AQFU_z4iBjrx7QAAAXL1bp5-MpCANNqVgAGX9lN_sGeSFJdPJ0WSpZy_ancL_eUcI_B_miLpftGahYjC01zJHlSPONkT9MtmiA&submissionId=54bc6c22-7f61-1c16-f949-727d7bd8c14a")!
               let application = UIApplication.shared
               // Check if the facebook App is installed
               if application.canOpenURL(url) {
                   application.open(url)
               } else {
                   // If Facebook App is not installed, open Safari with Facebook Link
                   application.open(URL(string: "https://www.linkedin.com/organization-guest/company/edumates?challengeId=AQFU_z4iBjrx7QAAAXL1bp5-MpCANNqVgAGX9lN_sGeSFJdPJ0WSpZy_ancL_eUcI_B_miLpftGahYjC01zJHlSPONkT9MtmiA&submissionId=54bc6c22-7f61-1c16-f949-727d7bd8c14a")!)
               }
    }
    @IBAction func facebookButton(_ sender: UIButton) {
       let url = URL(string: "fb://profile/101707294909891")!
        let application = UIApplication.shared
        // Check if the facebook App is installed
        if application.canOpenURL(url) {
            application.open(url)
        } else {
            // If Facebook App is not installed, open Safari with Facebook Link
            application.open(URL(string: "https://www.facebook.com/EduMates-101707294909891")!)
        }
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: self.textField.frame.width, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    
    fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
        return input.rawValue
    }
}
