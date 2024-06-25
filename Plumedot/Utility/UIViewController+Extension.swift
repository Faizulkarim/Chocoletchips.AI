//
////
////  UIViewController+Extension.swift
////  Plumedot
////
////  Created by Md Faizul karim on 7/2/23.
////
//
//import UIKit
//import DZNEmptyDataSet
//
//extension UIViewController : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
//    
//    class var storyboardID : String {
//        return "\(self)"
//    }
//    
//    open override func awakeFromNib() {
////        self.view.backgroundColor = UIColor.ColorWhite
//    }
//    
//    /**
//     To pop view controller
//     
//     - Parameter sender: AnyObject
//     
//     */
//    @IBAction func popViewController(sender : AnyObject) {
//        _ = self.navigationController?.popViewController(animated: true)
//    }
//    
//    /**
//     To dismiss view controller
//     
//     - Parameter sender: AnyObject
//     
//     */
//    @IBAction func dismissViewController(sender : AnyObject) {
//        _ = self.dismiss(animated: true, completion: nil)
//    }
//    
//    /**
//     To pop to root view controller
//     
//     - Parameter sender: AnyObject
//     
//     */
//    @IBAction func popToRootViewController(sender : AnyObject) {
//        _ = self.navigationController?.popToRootViewController(animated: true)
//    }
//    
//    @IBAction func btnMenuClick(sender : UIBarButtonItem) {
//            
//        self.toggleLeft()
//        
//    }
//
//    
//    static func instantiate(fromAppStoryboard appStoryboard: UIStoryboard) -> Self {
//        return appStoryboard.viewController(viewControllerClass: self)
//    }
//    
//    //MARK:- Empty Data Set Delegate
//    
//    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "Logo")
//        
//    }
//    
//    public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//
//        let emptyDataSetText : String = ValidationMessage.ErrorEmptyDataSetTitle.rawValue
//        let attribute = GFunction.shared.getAttributedText(emptyDataSetText, attributeDic: [NSAttributedString.Key.foregroundColor : UIColor.ColorTextColor , NSAttributedString.Key.font : UIFont.applyFont(fontType: .FontRegular, fontSize: kFontSize18, true)], range: (emptyDataSetText as NSString).range(of: emptyDataSetText))
//        
//        return attribute
//    }
//    
//    public func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        
//        let emptyDataSetDiscription : String = ValidationMessage.ErrorEmptyDataSetDiscription.rawValue
//        
//        let paragraphStyle1 = NSMutableParagraphStyle()
//        paragraphStyle1.lineSpacing = 10
//        paragraphStyle1.alignment = .center
//        let attribute = GFunction.shared.getAttributedText(emptyDataSetDiscription, attributeDic: [NSAttributedString.Key.foregroundColor : UIColor.ColorTextColor , NSAttributedString.Key.font : UIFont.applyFont(fontType: .FontRegular, fontSize: kFontSize13, true) , NSAttributedString.Key.paragraphStyle : paragraphStyle1], range: (emptyDataSetDiscription as NSString).range(of: emptyDataSetDiscription))
//        
//        return attribute
//    }
//    
//    func hideTabBar() {
//        self.tabBarController?.tabBar.isHidden = true
//        if let tabBar = self.tabBarController as? TabbarMainVC {
//            tabBar.vwBack.isHidden = true
//        }
//    }
//    
//    func showTabBar() {
//        self.tabBarController?.tabBar.isHidden = false
//        if let tabBar = self.tabBarController as? TabbarMainVC {
//            tabBar.vwBack.isHidden = false
//        }
//    }
//}
