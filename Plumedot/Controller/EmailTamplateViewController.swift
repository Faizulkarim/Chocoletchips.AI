//
//  EmailTamplateViewController.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
import Alamofire
import Speech

class EmailTamplateViewController: UIViewController {

    @IBOutlet weak var templateText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText : UITextView!
    @IBOutlet weak var toneOfVoice : UITextField!
    @IBOutlet weak var keyword : UITextField!
    @IBOutlet weak var short: UILabel!
    @IBOutlet weak var medium: UILabel!
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveTemplate: UIButton!
    
    @IBOutlet weak var titleToggolView : UIImageView!
    @IBOutlet weak var descriptionToggolView: UIImageView!
    @IBOutlet weak var tonOfVoiceToggolView: UIImageView!
    @IBOutlet weak var keywordToggoleView: UIImageView!
    @IBOutlet weak var templeteListTableView: UITableView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var userAvater : UIImageView!
    @IBOutlet weak var menuIcon : UIImageView!
    @IBOutlet weak var logoutButton : UIButton!
    @IBOutlet weak var templeteInfo : UIImageView!
    @IBOutlet weak var titleInfo : UIImageView!
    @IBOutlet weak var brifInfo : UIImageView!
    @IBOutlet weak var tonOfVoiceInfo : UIImageView!
    @IBOutlet weak var keywordInfo : UIImageView!
    @IBOutlet weak var viewBackgroundImage : UIImageView!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
      private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
      private var recognitionTask: SFSpeechRecognitionTask?
      private let audioEngine = AVAudioEngine()
      private var timer: Timer?
    private var inputNode: AVAudioInputNode?
    var templeteSaveModel: TempleteSaveModel?
    var templetlist: GetTempleteSaveModel?
    var size = 0
    var isTitleToggoleActive = true
    var isDescriptionToggleActive = true
    var isTonOfVoiceToggleActive = true
    var isKeywordToggleActive = true
    var selectedTitle = ""
    var selectedId = 0
    var speechToTextSting = ""
    var convertHtmlString = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAction()
        getAllTemplete()
        speechRecognizer?.delegate = self
        requestAuthorization()
        setupRightSwap()
        overrideUserInterfaceStyle = .light
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = .purple // Set the desired background color
        view.addSubview(statusBarView)
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    func setupUI(){
        self.templateText.delegate = self
        self.templateText.layer.cornerRadius = 20
        self.templateText.clipsToBounds = true
        self.titleText.layer.cornerRadius = 20
        self.titleText.clipsToBounds = true
        self.descriptionText.layer.cornerRadius = 20
        self.descriptionText.clipsToBounds = true
        self.toneOfVoice.layer.cornerRadius = 20
        self.toneOfVoice.clipsToBounds = true
        self.keyword.layer.cornerRadius = 20
        self.keyword.clipsToBounds = true
        self.short.layer.cornerRadius = 20
        self.short.clipsToBounds = true
        self.medium.layer.cornerRadius = 20
        self.medium.clipsToBounds = true
        self.long.layer.cornerRadius = 20
        self.long.clipsToBounds = true
        self.nextButton.layer.cornerRadius = 20
        self.nextButton.clipsToBounds = true
        self.saveTemplate.layer.cornerRadius = 20
        self.saveTemplate.clipsToBounds = true
        self.templateText.setLeftPaddingPoints(8)
        self.titleText.setLeftPaddingPoints(8)
        self.toneOfVoice.setLeftPaddingPoints(8)
        self.keyword.setLeftPaddingPoints(8)
        self.descriptionText.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0)
        self.userAvater.roundCorners(corners: .allCorners, radius: 23.5)
        self.templeteListTableView.isHidden = true
        let image = GFunction.shared.getSavedImage(named: "fileName")
        if image != nil {
            self.userAvater.image = image
        }
        self.keyword.delegate = self

    }
    func navigationToLogin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        loginViewController.modalPresentationStyle = .overFullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    func setupRightSwap(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
          self.view.addGestureRecognizer(swipeRight)
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            self.dismiss(animated: true)
       }

    }
    func navigationToHome(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomeViewController
        homeViewController.modalPresentationStyle = .overFullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    func navigationToCompose(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ComposeViewController = storyBoard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeViewController
        ComposeViewController.delegate = self
        ComposeViewController.emailContent = self.convertHtmlString
        ComposeViewController.modalPresentationStyle = .overFullScreen
        self.present(ComposeViewController, animated: true, completion: nil)
    }

    func setupAction(){
        
        self.viewBackgroundImage.handleTapToAction {
            self.templeteListTableView.isHidden = true
        }
        self.nextButton.handleTapToAction {
            self.navigationToCompose()
        }
        
        self.menuIcon.handleTapToAction {
            self.navigationToHome()
        }
        self.logoutButton.handleTapToAction {
            GFunction.shared.setBoolValueWithKey(false, key: "isLogin")
            
            self.navigationToLogin()
        }
        micButton.handleTapToAction {
            do {
                try self.startRecording()
            } catch let error {
                print("Error starting recording: \(error.localizedDescription)")
            }
 
        }
        
        self.userAvater.handleTapToAction {
            ImagePickerManager().pickImage(self){ image in
                DispatchQueue.main.async {
                    GFunction.shared.saveImage(image: image)
                    self.userAvater.image = image
                }
            }
        }
        self.titleToggolView.handleTapToAction {
            if self.titleToggolView.image == UIImage(named: "icon_toggle_off"){
                self.titleToggolView.image =  UIImage(named: "icon _toggle_on")
                self.isTitleToggoleActive = false
            }else{
                self.titleToggolView.image =  UIImage(named: "icon_toggle_off")
                self.isTitleToggoleActive = true
            }
        }
        self.descriptionToggolView.handleTapToAction {
            if self.descriptionToggolView.image == UIImage(named: "icon_toggle_off"){
                self.descriptionToggolView.image =  UIImage(named: "icon _toggle_on")
                self.isDescriptionToggleActive = false
            }else{
                self.descriptionToggolView.image =  UIImage(named: "icon_toggle_off")
                self.isDescriptionToggleActive = true
            }
        }
        self.tonOfVoiceToggolView.handleTapToAction {
            if self.tonOfVoiceToggolView.image == UIImage(named: "icon_toggle_off"){
                self.tonOfVoiceToggolView.image =  UIImage(named: "icon _toggle_on")
                self.isTonOfVoiceToggleActive = false
            }else{
                self.tonOfVoiceToggolView.image =  UIImage(named: "icon_toggle_off")
                self.isTonOfVoiceToggleActive = true
            }
        }
        self.keywordToggoleView.handleTapToAction {
            if self.keywordToggoleView.image == UIImage(named: "icon_toggle_off"){
                self.keywordToggoleView.image =  UIImage(named: "icon _toggle_on")
                self.isKeywordToggleActive = false
            }else{
                self.keywordToggoleView.image =  UIImage(named: "icon_toggle_off")
                self.isKeywordToggleActive = true
            }
        }
        
        
        self.short.handleTapToAction {
            self.size = 15
            self.short.backgroundColor = UIColor.lightGray
            self.medium.backgroundColor = UIColor.white
            self.long.backgroundColor = UIColor.white
        }
        self.medium.handleTapToAction {
            self.size = 30
            self.short.backgroundColor = UIColor.white
            self.medium.backgroundColor = UIColor.lightGray
            self.long.backgroundColor = UIColor.white
        }
        self.long.handleTapToAction {
            self.size = 60
            self.short.backgroundColor = UIColor.white
            self.medium.backgroundColor = UIColor.white
            self.long.backgroundColor = UIColor.lightGray
        }
        self.saveTemplate.handleTapToAction {
            if self.isValidView() {
                if self.selectedId != 0{
                    self.Save(title: self.titleText.text ?? "", brief: self.descriptionText.text ?? "", toneOfVoice: self.toneOfVoice.text ?? "", keywords: self.keyword.text ?? "", outLength: self.size.description, emailContent: self.convertHtmlString, method: .put, urlEnd: "\(self.selectedId)/")
                }else{
                    self.Save(title: self.titleText.text ?? "", brief: self.descriptionText.text ?? "", toneOfVoice: self.toneOfVoice.text ?? "", keywords: self.keyword.text ?? "", outLength: self.size.description, emailContent: self.convertHtmlString, method: .post, urlEnd: "")
                }
              
                self.stopRecording()
            }
        }
        
        templeteInfo.handleTapToAction {
            self.sendAlert(title: "Info", message: "Select from previously sessions saved")
        }
        titleInfo.handleTapToAction {
            self.sendAlert(title: "Info", message: "Enter a title to save as template and you can continue where you left off")
        }
        brifInfo.handleTapToAction {
            self.sendAlert(title: "Info", message: "Tell chocolatechips.ai what you are writing about")
        }
        tonOfVoiceInfo.handleTapToAction {
            self.sendAlert(title: "Info", message: "Try using different combinations of words like witty, friendly, disappointed, polite, creative, professional or add a well-known personality such as Adelle.")
        }
        keywordInfo.handleTapToAction {
            self.sendAlert(title: "Info", message: "Write with a particular word/s. Supports up to three (3) keywords")
        }
        
    }
    
    func isValidView() -> Bool {
        self.view.endEditing(true)
//        if self.templateText.text!.empty(){
//            GFunction.shared.showSnackBar(ValidationMessage.invalidTempleteText.rawValue)
//            return false
//        }
        
        if self.convertHtmlString.empty() {
            GFunction.shared.showSnackBar(ValidationMessage.emptyEmailcompose.rawValue)
            return false
        }
        if isTitleToggoleActive {
            if self.titleText.text!.empty(){
                GFunction.shared.showSnackBar(ValidationMessage.invalidTempletetitle.rawValue)
                return false
            }
        }

        if isDescriptionToggleActive {
            if self.descriptionText.text!.empty() {
                GFunction.shared.showSnackBar(ValidationMessage.invalidTempleteDescription.rawValue)
                return false
            }
        }
  
       if isTonOfVoiceToggleActive {
            if self.toneOfVoice.text!.empty(){
                GFunction.shared.showSnackBar(ValidationMessage.invalidTonOfVoice.rawValue)
                return false
            }
        }
 
       if isKeywordToggleActive {
            if self.keyword.text!.empty(){
                GFunction.shared.showSnackBar(ValidationMessage.invalidKeyword.rawValue)
                return false
            }
        }

        
        if self.size == 0{
            GFunction.shared.showSnackBar(ValidationMessage.invalidOutputlangth.rawValue)
            return false
        }
        
        return true
    }
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.navigationToHome()
        }))
        self.present(alert, animated: true, completion: nil)
    }


}

extension EmailTamplateViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.templateText {
            if templetlist?.data?.count ?? 0 > 0 {
                self.templeteListTableView.isHidden = false
            }else{
                self.templeteListTableView.isHidden = true
            }
        }else if textField == self.keyword {
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.keyword {
            let currentText = self.keyword.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            let words = updatedText.split(separator: " ")
            if words.count > 3 {
                
                sendAlert(title: "3 word limit", message: "")
                return false
            }

        }
        return true
    }
}
extension EmailTamplateViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.templetlist?.data?.count ?? 0 > 0 {
            return self.templetlist?.data?[0].count ?? 0
        }else{
            return 0
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TemplateTableViewCell {
            cell.templeteTitle.text = self.templetlist?.data?[0][indexPath.row].title
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let titleValue = self.templetlist?.data?[0][indexPath.row].title {
            self.titleText.text = titleValue
            self.selectedId = self.templetlist?.data?[0][indexPath.row].id ?? 0
        }
        if let composemeail = self.templetlist?.data?[0][indexPath.row].emailContent {
            self.convertHtmlString = composemeail
        }
        if let descriptionValue = self.templetlist?.data?[0][indexPath.row].brief {
            self.descriptionText.text = descriptionValue
        }
        if let tonOfVoiceValue = self.templetlist?.data?[0][indexPath.row].toneOfVoice {
            self.toneOfVoice.text = tonOfVoiceValue
        }
        if let keywordValue = self.templetlist?.data?[0][indexPath.row].keywords{
            self.keyword.text = keywordValue
        }
        if let lengthValue = self.templetlist?.data?[0][indexPath.row].outLength {
            if lengthValue == "15"{
                self.long.backgroundColor = UIColor.white
                self.short.backgroundColor = UIColor.lightGray
                self.medium.backgroundColor = UIColor.white
                self.size = Int(lengthValue) ?? 0
            }else if lengthValue == "30"{
                self.long.backgroundColor = UIColor.white
                self.short.backgroundColor = UIColor.white
                self.medium.backgroundColor = UIColor.lightGray
                self.size = Int(lengthValue) ?? 0
                
            }else{
                self.long.backgroundColor = UIColor.lightGray
                self.short.backgroundColor = UIColor.white
                self.medium.backgroundColor = UIColor.white
                self.size = Int(lengthValue) ?? 0
            }
        }
        self.templeteListTableView.isHidden = true
    }
    
}

extension EmailTamplateViewController {

    func getAllTemplete(){
        let token = GFunction.shared.getStringValueForKey("token")
        GFunction.shared.addLoader()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        guard let url = URL(string: getEmailTemplete) else { return}
        AF.request(url, headers: headers).responseDecodable(of: GetTempleteSaveModel.self) { response in
            switch response.result {
            case .success(let data):
                print(data)
                self.templetlist = data
                self.templeteListTableView.reloadData()
                GFunction.shared.removeLoader()
            case .failure(let error):
                GFunction.shared.removeLoader()
                print("Error: \(error)")
            }
        }
    }

    func Save(title: String,brief: String, toneOfVoice: String, keywords: String, outLength: String, emailContent: String, method: HTTPMethod?, urlEnd: String) {
        let parameters: [String: Any] = [
            "title":title,
            "brief": brief,
            "toneOfVoice":toneOfVoice,
            "keywords":keywords,
            "outLength":outLength,
            "emailContent": emailContent,
        ]
        let token = GFunction.shared.getStringValueForKey("token")
        GFunction.shared.addLoader()
        print(parameters)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]

        guard let url = URL(string: emailTamplateSave + urlEnd) else { return}
        AF.request(url,method: method ?? .post, parameters: parameters, headers : headers).validate().responseDecodable(of: TempleteSaveModel.self)  { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                self.templeteSaveModel = data
                GFunction.shared.removeLoader()
                self.sendAlert(title: "Save data", message: "Your templete saved successfully")
            case .failure(let error):
                GFunction.shared.removeLoader()
                print("Error: \(error)")
            }
        }
    }

}

extension EmailTamplateViewController {

    func speechToTextDidReturn(transcribedText: String) {
        let currentText = self.descriptionText.text ?? "" // Get the current text, or an empty string if nil
        let updatedText = currentText + " " + transcribedText // Append the new text to the current text
        self.descriptionText.text = updatedText // Update the text view with the new text
    }
    
    private func requestAuthorization() {
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("User denied speech recognition")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                default:
                    break
                }
            }
        }
        
    private func startRecording() throws {
            // Cancel any previous recognition task
            recognitionTask?.cancel()
            self.recognitionTask = nil

            // Configure the audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            inputNode = audioEngine.inputNode

            // Create a recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            }
            recognitionRequest.shouldReportPartialResults = true

            // Start the recording
            let recordingFormat = inputNode?.outputFormat(forBus: 0)
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            self.micButton.setImage(UIImage(named: "stop"), for: .normal)
            // Start the recognition task
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                recognitionRequest.shouldReportPartialResults = true
                if let result = result {
                    let finalTranscription = result.bestTranscription.formattedString
                    print("Final transcription: \(finalTranscription)")
          
                    print(result.isFinal)
                    DispatchQueue.main.async {
                        if result.isFinal {
                            let newText = self.descriptionText.text + finalTranscription
                            self.descriptionText.text = newText
                        }else{
                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                self.stopRecording()
                            }
                        }
                      }
                    
                } else if let error = error {
                    print("Speech recognition error: \(error.localizedDescription)")
                }
            }
        }

        
    private func stopRecording() {
        self.micButton.setImage(UIImage(named: "🦆 icon _mic_"), for: .normal)
       
        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        timer?.invalidate()
        timer = nil
    }

    
    

}

extension EmailTamplateViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Speech recognition available")
        } else {
            print("Speech recognition not available")
        }
    }
}

extension EmailTamplateViewController : saveEmail {
    func saveEmailData(data: String) {
        print(data)
        self.convertHtmlString = data
    }
    
    
}
