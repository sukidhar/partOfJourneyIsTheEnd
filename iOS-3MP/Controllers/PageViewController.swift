//
//  PageViewController.swift
//  iOS-3MP
//
//  Created by Sukidhar Darisi on 01/06/20.
//  Copyright © 2020 Sukidhar Darisi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var i = 0
    lazy var orderedViewControllers : [UIViewController] = {
        return [newViewController(viewController: "Onboard1ViewController") as! Onboard1ViewController,
                newViewController(viewController: "Onboard2ViewController") as! Onboard2ViewController,
                newViewController(viewController: "Onboard4ViewController") as! Onboard4ViewController,
                newViewController(viewController: "Onboard3ViewController") as! Onboard3ViewController
        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        // Do any additional setup after loading the view.
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    func newViewController(viewController : String) -> UIViewController {
        if #available(iOS 13.0, *) {
            return (self.storyboard?.instantiateViewController(identifier: viewController))!
        } else {
            // Fallback on earlier versions
            return (self.storyboard?.instantiateViewController(withIdentifier: viewController))!
        }
    }
    
    

    // MARK: Delegate methords
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        let pageContentViewController = pageViewController.viewControllers![0]
//        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!

    }
    
    func pressed(sender: UIButton!) { //next button
        i = i + 1
        NotificationCenter.default.post(name: Notification.Name("pageNumber"), object: i)
        if i < orderedViewControllers.count{
            self.setViewControllers([orderedViewControllers[i]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func skipPressed(sender : UIButton!){
         i = 3
         NotificationCenter.default.post(name: Notification.Name("pageNumber"), object: i)
         self.setViewControllers([orderedViewControllers[3]], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
             return nil
         }
         
         let previousIndex = viewControllerIndex - 1
        print(previousIndex)
         i += -1
        NotificationCenter.default.post(name: Notification.Name("pageNumber"), object: i)
         // User is on the first view controller and swiped left to loop to
         // the last view controller.
         guard previousIndex >= 0 else {
              return nil
         }
         guard orderedViewControllers.count > previousIndex else {
             return nil
         }
         
         return orderedViewControllers[previousIndex]
     }
     
     func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
             return nil
         }
         
         let nextIndex = viewControllerIndex + 1
        
         let orderedViewControllersCount = orderedViewControllers.count
         i = i+1
        
         NotificationCenter.default.post(name: Notification.Name("pageNumber"), object: i)
         // User is on the last view controller and swiped right to loop to
         // the first view controller.
         guard orderedViewControllersCount != nextIndex else {
             return nil
         }
         
         guard orderedViewControllersCount > nextIndex else {
             return nil
         }
         
         return orderedViewControllers[nextIndex]
     }
     
}
