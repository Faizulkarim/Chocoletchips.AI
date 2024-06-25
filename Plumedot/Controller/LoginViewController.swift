//
//  LoginViewController.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var loginButton : UIButton!
    @IBOutlet weak var passShowHide : UIImageView!
    var loginResponse: LoginModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAction()
//        overrideUserInterfaceStyle = .light
//        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
//        statusBarView.backgroundColor = .purple // Set the desired background color
//        view.addSubview(statusBarView)
        // Do any additional setup after loading the view.
    }
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    func isValidView() -> Bool {
        self.view.endEditing(true)
        if self.email.text!.empty(){
            GFunction.shared.showSnackBar(ValidationMessage.invalidEmail.rawValue)
            return false
        }
        if self.password.text!.empty(){
            GFunction.shared.showSnackBar(ValidationMessage.invalidPasswrod.rawValue)
            return false
        }
        
        return true
    }
    func navigationToHome(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomeViewController
        homeViewController.modalPresentationStyle = .overFullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }

    func setupUI(){
        self.email.layer.cornerRadius = 20
        self.email.clipsToBounds = true
        self.password.layer.cornerRadius = 20
        self.password.clipsToBounds = true
        self.loginButton.layer.cornerRadius = 20
        self.loginButton.clipsToBounds = true
        self.email.setLeftPaddingPoints(8)
        self.password.setLeftPaddingPoints(8)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        loginButton.handleTapToAction {
            if self.isValidView() {
                self.login(uName: self.email.text ?? "", Password: self.password.text ?? "")
            }
        }
    }
    
    func setupAction(){
        self.passShowHide.handleTapToAction {
            if self.passShowHide.image == UIImage(named: "passShwo"){
                self.passShowHide.image = UIImage(named: "passHide")
                self.password.isSecureTextEntry = false
            }else{
                self.passShowHide.image = UIImage(named: "passShwo")
                self.password.isSecureTextEntry = true
            }
        }
    }

}

extension LoginViewController {


    func login(uName: String, Password: String) {
        let parameters: [String: Any] = [
            "username": uName,
            "password": Password,
        ]
        GFunction.shared.addLoader()
        print(parameters)

        guard let url = URL(string: loginUrl) else { return}
        AF.request(url, method: .post, parameters: parameters).validate().responseDecodable(of: LoginModel.self)  { (response) in
            switch response.result {
            case .success(let data):
                self.loginResponse = data
                GFunction.shared.setBoolValueWithKey(true, key: "isLogin")
                GFunction.shared.setStringValueWithKey((self.loginResponse?.access)!, key: "token")
                GFunction.shared.setStringValueWithKey(self.email.text ?? "", key: "userName")
                GFunction.shared.removeLoader()
                print(data)
                self.navigationToHome()
            case .failure(let error):
                GFunction.shared.removeLoader()
                self.sendAlert(title: "", message: "No active account found with the given credentials")
                print("Error: \(error)")
            }
        }
    }
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
