//
//  SignUpViewController.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var signUpButton : UIButton!
    @IBOutlet weak var passShowHide : UIImageView!
    @IBOutlet weak var checkUncehck : UIImageView!
    @IBOutlet weak var termsAndCondition : UILabel!
    @IBOutlet weak var confirmpassShowHide : UIImageView!
    var isCheckMarkSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAction()
    }


    func setupUI(){
        self.email.layer.cornerRadius = 20
        self.email.clipsToBounds = true
        self.password.layer.cornerRadius = 20
        self.password.clipsToBounds = true
        self.fullName.layer.cornerRadius = 20
        self.fullName.clipsToBounds = true
        self.userName.layer.cornerRadius = 20
        self.userName.clipsToBounds = true
        self.signUpButton.layer.cornerRadius = 20
        self.confirmPass.layer.cornerRadius = 20
        self.confirmPass.clipsToBounds = true
        self.signUpButton.clipsToBounds = true
        self.email.setLeftPaddingPoints(8)
        self.password.setLeftPaddingPoints(8)
        self.fullName.setLeftPaddingPoints(8)
        self.userName.setLeftPaddingPoints(8)
        self.confirmPass.setLeftPaddingPoints(8)
        
        let attributedString = NSMutableAttributedString(string: termsAndCondition.text!)
        let range = NSRange(location: 0, length: attributedString.length)
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.purple.cgColor
        border.frame = CGRect(x: 0, y: termsAndCondition.frame.size.height - borderWidth, width: termsAndCondition.frame.size.width, height: termsAndCondition.frame.size.height)
        border.borderWidth = borderWidth
        termsAndCondition.layer.addSublayer(border)
        termsAndCondition.layer.masksToBounds = true

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.purple, range: range)
        termsAndCondition.attributedText = attributedString
   
    }
    func isValidView() -> Bool {
        self.view.endEditing(true)
//        if self.email.text!.empty(){
//            GFunction.shared.showSnackBar(ValidationMessage.invalidEmail.rawValue)
//            return false
//        }
        
        if self.userName.text!.empty(){
            GFunction.shared.showSnackBar(ValidationMessage.invalidUser.rawValue)
            return false
        }
//        if self.fullName.text!.empty(){
//            GFunction.shared.showSnackBar(ValidationMessage.invalidFirstName.rawValue)
//            return false
//        }
        if self.email.text != "" {
            let isValid = isValidEmail(testStr: self.email.text!)
            print(self.email.text!)
            if isValid {
                print("Valid email address!")
            } else {
                GFunction.shared.showSnackBar(ValidationMessage.invalidEmail.rawValue)
                return false
            }
     
        }

        if self.password.text!.empty(){
            GFunction.shared.showSnackBar(ValidationMessage.invalidPasswrod.rawValue)
            return false
        }
        if self.password.text != self.confirmPass.text {
            GFunction.shared.showSnackBar(ValidationMessage.InvalidMatchPass.rawValue)
            return false
        }

        
        return true
    }


    func setupAction(){
        self.checkUncehck.handleTapToAction {
            if self.isCheckMarkSelected {
                self.checkUncehck.image = UIImage(named: "unchecked")
                self.isCheckMarkSelected = false
            }else{
                self.checkUncehck.image = UIImage(named: "check")
                self.isCheckMarkSelected = true
            }
        }
        termsAndCondition.handleTapToAction {
            self.navigationToTerms()
        }
        signUpButton.handleTapToAction {
            if self.isCheckMarkSelected{
                if self.isValidView() {
                    self.signUp(email: self.email.text ?? "" , fullName: self.fullName.text ?? "", uName: self.userName.text ?? "", Password: self.password.text ?? "", ConfirmPasswrod: self.confirmPass.text ?? "")
                }
            }else{
                self.sendAlert(title: "", message: "Please agree to terms and conditions")
            }
     
        }
        self.passShowHide.handleTapToAction {
            if self.passShowHide.image == UIImage(named: "passShwo"){
                self.passShowHide.image = UIImage(named: "passHide")
                self.password.isSecureTextEntry = false
            }else{
                self.passShowHide.image = UIImage(named: "passShwo")
                self.password.isSecureTextEntry = true
            }
        }

        self.confirmpassShowHide.handleTapToAction {
            if self.confirmpassShowHide.image == UIImage(named: "passShwo"){
                self.confirmpassShowHide.image = UIImage(named: "passHide")
                self.confirmPass.isSecureTextEntry = false
            }else{
                self.confirmpassShowHide.image = UIImage(named: "passShwo")
                self.confirmPass.isSecureTextEntry = true
            }
        }

    }
    func navigationToTerms(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "terms") as! TermAndConditionUIViewController
        homeViewController.delegate = self
        homeViewController.modalPresentationStyle = .overFullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    func navigationToLogin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        
        loginViewController.modalPresentationStyle = .overFullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(){
        // Create an alert controller
        let alertController = UIAlertController(title: "Successful", message: "Account created successfully", preferredStyle: .alert)

        // Create an OK action
        let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            self.navigationToLogin()
        })

        // Add the OK action to the alert controller
        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)

    }

}

extension SignUpViewController {


    func signUp(email: String,fullName: String, uName: String, Password: String, ConfirmPasswrod: String) {
        let parameters: [String: Any] = [
            "username": uName,
            "password": Password,
            "password2": ConfirmPasswrod,
            "email":email,
            "first_name":uName,
            "last_name":uName,
        ]
        GFunction.shared.addLoader()
        print(parameters)

        guard let url = URL(string: singUpUrl) else { return}
        AF.request(url, method: .post, parameters: parameters).validate().responseDecodable(of: SignUpModel.self)  { (response) in
            print(response.result)
            switch response.result {
            
            case .success(let data):
                print(data)
                GFunction.shared.removeLoader()
                self.showAlert()
            case .failure(let error):
                GFunction.shared.removeLoader()
                   if let statusCode = response.response?.statusCode, statusCode == 400 {
                       if let responseData = response.data {
                           let responseString = String(data: responseData, encoding: .utf8)
                           if let jsonData = responseString?.data(using: .utf8),
                               let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String]] {
                               print(jsonDictionary)
                               var errorMessage = ""
                               if let usernameErrors = jsonDictionary["username"]{
                                   for item in usernameErrors {
                                       errorMessage = errorMessage + "\n\(item)."
                                   }

                               }
                               
//                               if let emailErrors = jsonDictionary["email"] {
//                                   for item in emailErrors {
//                                       errorMessage = errorMessage + "\n Email: \(item)."
//                                   }
//                               }
                               
                            if let passErrors = jsonDictionary["password"] {
                                for item in passErrors {
                                    errorMessage = errorMessage + "\n\(item)."
                                }
                                  
                               }
                               
                               self.sendAlert(title: "Error", message: errorMessage )
                               
                           }
                       }

                   } else {
                       // Handle other errors here
                       print(error)
                   }            }
        }
    }

}

extension SignUpViewController : TermsAndCondionStatus {
    func Status(isTrue: Bool?) {
        self.checkUncehck.image = UIImage(named: "check")
        self.isCheckMarkSelected = isTrue ?? false
    }
     func isValidEmail(testStr: String) -> Bool {
         let emailRegEx  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let emailTest   = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
         let result  = emailTest.evaluate(with: testStr)
         return result
    }

    
}
