//
//  UIApplication.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//
import  UIKit

extension UIApplication {
    /**
     TO get the top view controller of the application.
     
     - Parameter controller: RootViewController of the application
     
     - Returns: UIViewController
     
     
     */

    class func topViewController(controller: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static var loginAnimation: UIView.AnimationOptions = .transitionFlipFromRight
    static var logoutAnimation: UIView.AnimationOptions = .transitionCrossDissolve
    
    public static func setRootView(_ viewController: UIViewController,
                                   options: UIView.AnimationOptions = .transitionFlipFromRight,
                                   animated: Bool = true,
                                   duration: TimeInterval = 0.5,
                                   completion: (() -> Void)? = nil) {
        guard animated else {
            UIWindow.key?.rootViewController = viewController
            return
        }
        
        UIView.transition(with: UIWindow.key!, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            UIWindow.key?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
    class var safeArea : UIEdgeInsets {
        if UIApplication.shared.windows.count > 0{
            if #available(iOS 11.0, *) {
                return UIApplication.shared.windows[0].safeAreaInsets
            } else {
                return UIEdgeInsets.zero
                // Fallback on earlier versions
            }
        }
        return UIEdgeInsets.zero
    }
}
extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
