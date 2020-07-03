//
//  ButtonView.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 13/05/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import Strongbox
import UIKit
import FirebaseDatabase

class ButtonView: UIView {

    // the button is a subview of this view... try to tap it
    
    // normally, you can't touch a subview's region outside its superview
    // but you can *see* a subview outside its superview if the superview doesn't clip to bounds,
    // so why shouldn't you be able to touch it?
    // this hitTest override makes it possible
    // try the example with hitTest commented out and with it restored to see the difference
    override func hitTest(_ point: CGPoint, with e: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with:e) {
            return result
        }
        for sub in self.subviews.reversed() {
            let pt = self.convert(point, to:sub)
            if let result = sub.hitTest(pt, with:e) {
                return result
            }
        }
        return nil
    }

}

extension UIView {
    
    func round(corners: UIRectCorner, cornerRadius: Double) {
        
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}


enum AIEdge:Int {
    case
    Top,
    Left,
    Bottom,
    Right,
    Top_Left,
    Top_Right,
    Bottom_Left,
    Bottom_Right,
    All,
    None
}

extension UIView {

    func applyShadowWithCornerRadius(color:UIColor, opacity:Float, radius: CGFloat, edge:AIEdge, shadowSpace:CGFloat)    {

        var sizeOffset:CGSize = CGSize.zero

        switch edge {
        case .Top:
            sizeOffset = CGSize(width: 0, height: -shadowSpace)
        case .Left:
            sizeOffset = CGSize(width: -shadowSpace, height: 0)
        case .Bottom:
            sizeOffset = CGSize(width: 0, height: shadowSpace)
        case .Right:
            sizeOffset = CGSize(width: shadowSpace, height: 0)


        case .Top_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace)
        case .Top_Right:
            sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace)
        case .Bottom_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace)
        case .Bottom_Right:
            sizeOffset = CGSize(width: shadowSpace, height: shadowSpace)


        case .All:
            sizeOffset = CGSize(width: 0, height: 0)
        case .None:
            sizeOffset = CGSize.zero
        }

        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true;

        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = sizeOffset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false

        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.layer.cornerRadius).cgPath
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        return (self as NSString).substring(with: result.range)
    }
}

extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}
extension Formatter {
    static let date = DateFormatter()
}
extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                           in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
}
extension Date {

    var fullDate: String   { localizedDescription(dateStyle: .full,   timeStyle: .none) }
    var longDate: String   { localizedDescription(dateStyle: .long,   timeStyle: .none) }
    var mediumDate: String { localizedDescription(dateStyle: .medium, timeStyle: .none) }
    var shortDate: String  { localizedDescription(dateStyle: .short,  timeStyle: .none) }

    var fullTime: String   { localizedDescription(dateStyle: .none,   timeStyle: .full) }
    var longTime: String   { localizedDescription(dateStyle: .none,   timeStyle: .long) }
    var mediumTime: String { localizedDescription(dateStyle: .none,   timeStyle: .medium) }
    var shortTime: String  { localizedDescription(dateStyle: .none,   timeStyle: .short) }

    var fullDateTime: String   { localizedDescription(dateStyle: .full,   timeStyle: .full) }
    var longDateTime: String   { localizedDescription(dateStyle: .long,   timeStyle: .long) }
    var mediumDateTime: String { localizedDescription(dateStyle: .medium, timeStyle: .medium) }
    var shortDateTime: String  { localizedDescription(dateStyle: .short,  timeStyle: .short) }
}
    private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
               return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t = textField.text{
            textField.text = String(t.prefix(maxLength))
        }
    }
}



class Observers {
    
    static let shared = Observers()
    
    func addObservers(for viewController : UIViewController, with selector : Selector) {
          NotificationCenter.default.addObserver(viewController,
                                                 selector: selector,
                                                 name: UIApplication.didBecomeActiveNotification,
                                                 object: nil)
        }

    func removeObservers() {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}

class Checkers
{
    func dateObserver()->Int{
        let sb = Strongbox()
        let value =   Date().timeIntervalSince1970 - TimeInterval(sb.unarchive(objectForKey: "memberTill") as? Int64 ?? Int64(Date().timeIntervalSince1970))
        print(value)
        return Int(-value)
    }
    func alertMaker(view : UIViewController)
    {
        if !CheckInternet.Connection(){
                   let alert = UIAlertController(title: "Connectivity Error", message: "Looks like your connection is offline", preferredStyle: .alert)
                   let alertImage = UIImageView()
                   alertImage.image = #imageLiteral(resourceName: "icons8-brake-warning-50")
                   alert.view.addSubview(alertImage)
                   alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                   view.present(alert,animated: true)
        }
    }
    func isGoingToBackground(){
           if #available(iOS 13.0, *) {
               NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
           } else {
               NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
           }
    }
    @objc func willResignActive(_ notification: Notification) {
        if let uid = DataService().keyChain.get("uid"){
            OnlineOfflineService.online(for: uid, status: "offline") { (bool) in
                print("offline",bool)
            }
        }
    }

}
protocol TabDelegate {
    func passIndex(_ viewController : UIViewController, index : Int)
}

extension UITextField
{
    func setTextFieldCornerRadiusWithBorder(radius : CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 0.5
        self.clipsToBounds = true
    }

    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}



struct OnlineOfflineService {
    
    static func online(for uid: String, status: String, success: @escaping (Bool) -> Void) {
        let onlinesRef = Database.database().reference().child("USER").child(uid).child("status")
        onlinesRef.setValue(status) {(error, _ ) in

            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            success(true)
        }
    }
}

extension UITextView {
    var numberOfLines: Int {
        // Get number of lines
        let numberOfGlyphs = self.layoutManager.numberOfGlyphs
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
            self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
          index = NSMaxRange(lineRange)
          numberOfLines += 1
        }

        return numberOfLines
    }
}

extension UIImage {
    func resize(_ width: CGFloat, _ height:CGFloat) -> UIImage? {
        let widthRatio  = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
