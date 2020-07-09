//
//  FAQViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 03/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit
class FAQ{
    var question : String?
    var answer : String?
    var isSelected : Bool?
    var isAnswer : Bool
    
    init(question: String?, answer: String? , isSelected: Bool?, isAnswer: Bool) {
        self.question = question
        self.answer = answer
        self.isSelected = isSelected
        self.isAnswer = isAnswer
    }
}

class FAQViewController: UIViewController , UITableViewDataSource,UITableViewDelegate{
    
    
    @IBOutlet weak var faqTable: UITableView!

    var dataSource = [
        FAQ(question: "What services does Edumates offer?", answer: nil , isSelected: false, isAnswer: false),
        FAQ(question: nil , answer: "Edumates helps students connect to university representative via a designated chat-box. The aim of the project is to create a seamless experience for potential students to connect to their respected representative of the university (ambassadors) in order obtain accurate information and make an educated decision to opt for university." , isSelected: nil, isAnswer: true),
        FAQ(question: "What are the Edumates working hours?", answer: nil , isSelected: false, isAnswer: false),
        FAQ(question: nil , answer: "Our team works in accordance with the standard working hours in India/ United Kingdom. However, we understand that our target group is coming from all around the globe where they live in different time zones. Therefore you can leave a message to us via social media and we will stay in touch with you all the time. Your comfort does matter!" , isSelected: nil, isAnswer: true),
        FAQ(question: "How is Edumates different?", answer: nil , isSelected: false, isAnswer: false),
        FAQ(question: nil , answer: "One of the many advantages of Edumates is the personalised support for the students in terms of the emotional help in adjusting to the new culture of universities, explore their interests and understand the implications of their choices (how they choose to spend their time at the university, what modules they choose, if the course is the right fit for them) along with the added benefit of having a relatively less stressful academic year as it carries little to none weightage in deciding the overall grade of the degree of university. We were in your shoes, so there is no one like us to understand you better." , isSelected: nil, isAnswer: true),
        FAQ(question: "How can I become a partner with Edumates?", answer: nil , isSelected: false, isAnswer: false),
        FAQ(question: nil , answer: "Please contact us through our website or social app, our team will arrange a meeting with you." , isSelected: nil, isAnswer: true),
        FAQ(question: "Do I need to be a student to use Edumates service?", answer: nil , isSelected: false, isAnswer: false),
        FAQ(question: nil , answer: "No, you do not need to be a student. We provide our service to everyone that might benefit from it." , isSelected: nil, isAnswer: true)
    ]
    
    
       let checkers = Checkers()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            checkers.isGoingToBackground()
            faqTable.dataSource = self
            faqTable.delegate = self
            Observers.shared.addObservers(for: self, with: #selector(applicationIsActive))
           faqTable.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "ResuableCell")
            faqTable.register(UINib(nibName: "answerCell", bundle: nil), forCellReuseIdentifier: "ReusableAnswerCell")
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
        
        
        func goToLoginScreen(){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }
        @IBAction func backButtonPressed(_ sender: UIButton) {
self.navigationController?.popViewController(animated: true)
            
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let data = dataSource[indexPath.row]
       if !data.isAnswer{
           let cell = tableView.dequeueReusableCell(withIdentifier: "ResuableCell", for: indexPath) as! QuestionCell
            cell.label.text = data.question
            cell.label.isUserInteractionEnabled = false
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
           return cell
       }else{
           let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableAnswerCell", for: indexPath) as! answerCell
            cell.backgroundColor = .clear
            cell.label.text = data.answer
            cell.selectionStyle = .none
            cell.label.isUserInteractionEnabled = false
           return cell
       }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row%2 == 0 {
            tableView.beginUpdates()
            let data = dataSource[indexPath.row]
            data.isSelected = !(data.isSelected!)
            tableView.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .middle)
            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataSource[indexPath.row]
        var size : CGRect
        if !data.isAnswer{
            size = estimateFrameForText(data.question!)
            return max(50, size.height + 30)
        }
        if indexPath.row%2==1 && dataSource[indexPath.row-1].isSelected! {
            size = estimateFrameForText(data.answer!)
            return max(50, size.height + 35)
        }
        return 0
    }
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: self.view.frame.width - 60, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 15)]), context: nil)
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

