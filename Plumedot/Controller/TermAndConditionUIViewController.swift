//
//  TermAndConditionUIViewController.swift
//  Plumedot
//
//  Created by Md Faizul karim on 3/3/23.
//

import UIKit
import Alamofire

protocol TermsAndCondionStatus : AnyObject{
    func Status(isTrue: Bool?)
}

class TermAndConditionUIViewController: UIViewController {

    @IBOutlet weak var acceptButton : UIButton!
    var delegate : TermsAndCondionStatus?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.acceptButton.layer.cornerRadius = 20
        self.acceptButton.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        self.acceptButton.handleTapToAction {
            self.delegate?.Status(isTrue: true)
            self.dismiss(animated: true)
        }
    }
    
    
    func navigationToHome(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomeViewController
        homeViewController.modalPresentationStyle = .overFullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    func navigationToLogin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        loginViewController.modalPresentationStyle = .overFullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }



}

