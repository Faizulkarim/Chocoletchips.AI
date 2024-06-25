//
//  HomeViewController.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
import Speech
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var searchText : UITextField!
    @IBOutlet weak var micButton : UIImageView!
    @IBOutlet weak var userAvater: UIImageView!
    @IBOutlet weak var email: UIImageView!
    ///@IBOutlet weak var imageGenarate : UIImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var logoutButton : UIButton!
    @IBOutlet weak var deleteaccount : UILabel!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    private var isRecording = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
        setupAction()
        overrideUserInterfaceStyle = .light
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = .purple // Set the desired background color
        view.addSubview(statusBarView)
       
    }
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    func setupUI(){
        self.searchText.layer.cornerRadius = 20
        self.searchText.clipsToBounds = true
        self.userAvater.roundCorners(corners: .allCorners, radius: 23.5)
        let image = GFunction.shared.getSavedImage(named: "fileName")
        if image != nil {
            self.userAvater.image = image
        }
        
        let userName = GFunction.shared.getStringValueForKey("userName")
        self.userName.text = "Hello, \(userName)"
    }
    func navigationToLogin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        loginViewController.modalPresentationStyle = .overFullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    func setupAction(){
        self.micButton.handleTapToAction {
            self.recordAndRecognizeSpeech()
        }
        self.deleteaccount.handleTapToAction {
            self.sendDeleteAlert(title: "Alert", message: "Your account will be parmanently deleted from our system")
        }
        self.logoutButton.handleTapToAction {
            GFunction.shared.setBoolValueWithKey(false, key: "isLogin")
            self.navigationToLogin()
        }
        self.userAvater.handleTapToAction {
            ImagePickerManager().pickImage(self){ image in
                DispatchQueue.main.async {
                    GFunction.shared.saveImage(image: image)
                    self.userAvater.image = image
                }
            }
        }
        self.email.handleTapToAction {
            self.navigationToEmail()
        }
//        self.imageGenarate.handleTapToAction {
//            self.navigationToEmail()
//        }
    }
    func navigationToEmail(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "emailTemplet") as! EmailTamplateViewController
        homeViewController.modalPresentationStyle = .overFullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }

}

extension HomeViewController {
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.micButton.isHidden = false
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.micButton.isHidden = false
                case .denied:
                    self.micButton.isHidden = true
                    self.searchText.text = "User denied access to speech recognition"
                case .restricted:
                    self.micButton.isHidden = true
                    self.searchText.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.micButton.isHidden = true
                    self.searchText.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
            self.micButton.isHidden = true
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.searchText.text = bestString
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
   
    func deleteAccount(){
            let token = GFunction.shared.getStringValueForKey("token")
            GFunction.shared.addLoader()
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
            guard let url = URL(string: accountDelete) else { return}
        
        AF.request(url, method: .delete, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                GFunction.shared.removeLoader()
                GFunction.shared.setBoolValueWithKey(false, key: "isLogin")
                self.navigationToLogin()
            case .failure(let error):
                GFunction.shared.removeLoader()
                print("Error: \(error)")
            }
            
        }
    }
    
    func sendDeleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".uppercased(), style: .cancel) {
            UIAlertAction in
        }

        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Delete Account", style: UIAlertAction.Style.default, handler: { _ in
            self.deleteAccount()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
