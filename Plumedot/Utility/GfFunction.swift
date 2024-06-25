//
//  GfFunction.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import UIKit

class GFunction: NSObject {
    
    static let shared   : GFunction = GFunction()
    let activityIndicator = UIActivityIndicatorView(style: .white)
    let viewBGLoder: UIView = UIView()
    let snackbar: TTGSnackbar = TTGSnackbar()
    let snackBarNetworkReachability : TTGSnackbar = TTGSnackbar()
    
    enum ConvertType {
        case LOCAL,UTC,NOCONVERSION
    }
    

    
    //MARK:- Custom Alert
    
    func showSnackBar(_ message : String, duration : TTGSnackbarDuration = .short ,isError : Bool = false, animation : TTGSnackbarAnimationType = .slideFromTopBackToTop) {
        snackbar.message = message
        snackbar.duration = duration
        // Change the content padding inset
        snackbar.contentInset = UIEdgeInsets.init(top: UIApplication.safeArea.top + 20, left: 8, bottom: 8, right: 8)
        
        // Change margin
        snackbar.leftMargin = 0
        snackbar.rightMargin = 0
        snackbar.topMargin = -UIApplication.safeArea.top
        
        // Change message text font and color
        snackbar.messageTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        snackbar.messageTextFont = UIFont.systemFont(ofSize: 14)
        
        // Change snackbar background color
        snackbar.backgroundColor = UIColor.purple
        
        snackbar.onTapBlock = { snackbar in
            snackbar.dismiss()
        }
        
        snackbar.onSwipeBlock = { (snackbar, direction) in
            
            // Change the animation type to simulate being dismissed in that direction
            if direction == .right {
                snackbar.animationType = .slideFromLeftToRight
            } else if direction == .left {
                snackbar.animationType = .slideFromRightToLeft
            } else if direction == .up {
                snackbar.animationType = .slideFromTopBackToTop
            } else if direction == .down {
                snackbar.animationType = .slideFromTopBackToTop
            }
            
            snackbar.dismiss()
        }
        
        // snackbar.cornerRadius = 0.0
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        // Animation type
        snackbar.animationType = animation
        snackbar.show()
    }
    
    func showNoNetworkSnackBar(_ message : String = "No Internet Connection") {
        
        snackBarNetworkReachability.message = message
        snackBarNetworkReachability.duration = .forever
        // Change the content padding inset
        snackBarNetworkReachability.contentInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        
        // Change margin
        snackBarNetworkReachability.leftMargin = 0
        snackBarNetworkReachability.rightMargin = 0
        snackBarNetworkReachability.topMargin = 20
        
        // Change message text font and color
        snackBarNetworkReachability.messageTextColor = UIColor.white
        snackBarNetworkReachability.messageTextAlign = .center
        snackBarNetworkReachability.messageTextFont = UIFont.systemFont(ofSize: 14)
        
        // Change snackbar background color
        snackBarNetworkReachability.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6274509804, blue: 0.6980392157, alpha: 1).withAlphaComponent(0.9)
        
        //        snackBarNetworkReachability.cornerRadius = 0.0
        // Change animation duration
        snackBarNetworkReachability.animationDuration = 0.5
        
        // Animation type
        snackBarNetworkReachability.animationType = .topSlideFromRightToLeft
        snackBarNetworkReachability.show()
    }
    
    func removeNoNetworkSnackBar(){
        
        snackBarNetworkReachability.dismiss()
    }
    

    
    //MARK:- Get window
    
    func getWindow() -> UIWindow? {
        return UIApplication.shared.windows.first
    }
    //MARK:- Add/Remove Loader
    
    func addLoader(_ message : String? = "Loading...") {
        removeLoader()
        
        self.viewBGLoder.frame = UIScreen.main.bounds
        self.viewBGLoder.backgroundColor = .clear
        self.viewBGLoder.tag = 1307966
        
        activityIndicator.center = UIApplication.shared.windows.first?.center ?? .zero
        activityIndicator.color = UIColor.purple
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.viewBGLoder.addSubview(activityIndicator)
        UIApplication.shared.windows.first?.addSubview(viewBGLoder)
    }
    
    func removeLoader() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        UIApplication.shared.windows.first?.viewWithTag(1307966)?.removeFromSuperview()
        self.viewBGLoder.removeFromSuperview()
    }

    func isBackspace(_ inputString : String) -> Bool {
        let  char = inputString.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        } else {
            return false
        }
    }
    func setDefaultScreen(){
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "home") as! HomeViewController
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func saveImage(image: UIImage){
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return
        } catch {
            print(error.localizedDescription)
            return 
        }
    }
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func deleteImage() {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        let fileURL = directory.appendingPathComponent("fileName.png")
        do {
            try FileManager.default.removeItem(at: fileURL!)
        } catch {
            print(error.localizedDescription)
        }
    }

    

    func makeCall(_ strNumber : String = "1234567890") {
        
        var phoneNumber : String = "telprompt://\(strNumber)"
        phoneNumber = self.makeValidNumber(phoneNumber)
        
        if UIApplication.shared.canOpenURL(URL(string: phoneNumber)!) {
            UIApplication.shared.open(URL(string: phoneNumber)!, options: [:]) { (sucess) in
                
            }
        } else {
            
            GFunction.shared.showSnackBar("Carrier service not available")
        }
    }
    
    func makeValidNumber(_ phoneNumber : String) -> String {
        
        var number : String = phoneNumber
        number = number.replacingOccurrences(of: "+", with: "")
        number = number.replacingOccurrences(of: " ", with: "")
        number = number.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return number
    }

    
    //MARK: - User Defaults (Set/Get)
     func setStringValueWithKey(_ data: String, key: String) {
        
        let appData = UserDefaults.standard
        appData.set(data, forKey: key)
        appData.synchronize()
    }
    
     func setBoolValueWithKey(_ data: Bool, key: String) {
        
        let appData = UserDefaults.standard
        appData.set(data, forKey: key)
        appData.synchronize()
    }
    
     func setIntValueWithKey(_ data: Int, key: String) {
        
        let appData = UserDefaults.standard
        appData.set(data, forKey: key)
        appData.synchronize()
    }
    
     func getStringValueForKey(_ key: String) -> String {
        
        let appData = UserDefaults.standard
        if let value = appData.object(forKey: key) as? String {
            return value
        }
        return ""
    }
    
     func getBoolValueForKey(_ key: String) -> Bool {
        
        let appData = UserDefaults.standard
        if let value = appData.object(forKey: key) as? Bool {
            return value
        }
        return false
    }
    
     func getIntValueForKey(_ key: String) -> Int {
        
        let appData = UserDefaults.standard
        if let value = appData.object(forKey: key) as? Int {
            return value
        }
        return -1
    }
    
     func removeValue(_ key: String) {
        
        let appData = UserDefaults.standard
        appData.removeObject(forKey: key)
        appData.synchronize()
    }
    
    //Save data into userdefaults
    func saveDataIntoUserDefault (object : AnyObject, key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    //remove data from userdefaults
    func removeUserDefaults (key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    
    //------------------------------------------------------
    
    //MARK:- Int to two decomal float
    
    
    
    
    func alertWithAction(view: UIViewController, msg: String,title: String, actionButtonClosure: @escaping () -> Void){
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.purple
            let action1 = UIAlertAction(title: title, style: .default) { (action) in
                actionButtonClosure()
            }
        
            let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                print("Cancel is pressed......")
            }

            alertController.addAction(action1)
            alertController.addAction(action2)
            view.present(alertController, animated: true, completion: nil)

        }

}
