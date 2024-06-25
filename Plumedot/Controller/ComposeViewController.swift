//
//  ComposeViewController.swift
//  Plamedot
//
//  Created by Md Faizul karim on 30/1/23.
//

import UIKit
import Speech
import OpenAIKit
import Lottie
import Alamofire
import SwiftyJSON
import SWXMLHash
import IQKeyboardManagerSwift
import OpenAI



protocol saveEmail: AnyObject{
    func saveEmailData(data: String)
}

class ComposeViewController: UIViewController {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
      private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
      private var recognitionTask: SFSpeechRecognitionTask?
      private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
      private var timer: Timer?
    private var selectedText = ""
    private var gptResponse = ""
    private var nextCharacterIndex = 0
    private var textTimer: Timer?
    private var isImgaeGenaratorSelect = false
    private var openai : OpenAI?
    var pickerView = UIPickerView()
    let pickerData = [13,14,15,16,17,18,19]
    let endpoint = "https://www.copyscape.com/api/"
    var isDotSelected  = false
    var isNuberPointSelect = false
    var currentListNumber = 0
    var accountInfo : AccountInfoModel?
    var iSSpeechSelected = true
    var selectedRange : NSRange?
    var isComposing = true
    var delegate : saveEmail?
    var emailContent : String?
    @IBOutlet weak var composeButton : UIButton!
    @IBOutlet weak var speechText : UITextView!
    @IBOutlet weak var micButton : UIButton!
    @IBOutlet weak var editorFirstUtility : UIView!
    @IBOutlet weak var secondEditorUtility : UIView!
    @IBOutlet weak var thirdEditorUtility: UIView!
    @IBOutlet weak var fourthEditorUtility: UIView!
    @IBOutlet weak var fifthEditorUnility: UIView!
    @IBOutlet weak var imageGenaratorSelectView: UIView!
    @IBOutlet weak var checkIconSelectView : UIView!
    @IBOutlet weak var editorTextView : UITextView!
    @IBOutlet weak var boldButtonView : UIView!
    @IBOutlet weak var italicButtonView: UIView!
    @IBOutlet weak var fontChangeButtonView : UIView!
    @IBOutlet weak var alignLeftButtonView: UIView!
    @IBOutlet weak var alignCenterButtonView: UIView!
    @IBOutlet weak var alignRightButtonView: UIView!
    @IBOutlet weak var bulletButtonView: UIView!
    @IBOutlet weak var listButtonView: UIView!
    @IBOutlet weak var indentButtonView: UIImageView!
    @IBOutlet weak var photoButtonView: UIView!
    @IBOutlet weak var linkButtonView: UIView!
    @IBOutlet weak var checkGrammer: UIView!
    @IBOutlet weak var donButtonView: UIView!
    @IBOutlet weak var fontSizePicker: UIPickerView!
    @IBOutlet var loadingAnimation: LottieAnimationView!
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var userAvater: UIImageView!
    @IBOutlet weak var menuIcon : UIImageView!
    @IBOutlet weak var logoutButton : UIButton!
    @IBOutlet weak var heightConstant : NSLayoutConstraint!
    @IBOutlet weak var editorBackView : UIView!
    @IBOutlet weak var currentScrolliew : UIScrollView!
    @IBOutlet weak var readyTosave: UIButton!
    var extratimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestAuthorization()
        setupAction()
        setupOpenAi()
        self.fontSizePicker.delegate = self
        self.fontSizePicker.dataSource = self
        self.setToolBar()
        IQKeyboardManager.shared.keyboardDistanceFromTextField                    = -80
        self.getAccountinfo()
        setupRightSwap()
        overrideUserInterfaceStyle = .light

        
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    func setupUI(){
        
//        if let htmlData = self.emailContent?.data(using: .utf8) {
//            do {
//                let attributedText = try NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
//                editorTextView.attributedText = attributedText
//            } catch let e as NSError {
//                print("Error: \(e.localizedDescription)")
//            }
//        }
       // self.editorTextView.attributedText = self.emailContent?.htmlToAttributedString
        
        //self.editorTextView.attributedText = try? NSAttributedString(data: self.emailContent!.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        self.currentScrolliew.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.composeButton.layer.cornerRadius = 20
        self.composeButton.clipsToBounds = true
        
        self.readyTosave.layer.cornerRadius = 20
        self.readyTosave.clipsToBounds = true
        self.editorBackView.layer.cornerRadius = 20
        self.editorBackView.clipsToBounds = true
        self.editorFirstUtility.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        self.secondEditorUtility.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        self.thirdEditorUtility.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        self.fourthEditorUtility.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        self.fifthEditorUnility.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
    
        
        self.imageGenaratorSelectView.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 0.4)
        self.checkIconSelectView.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 0.4)
        self.checkGrammer.applyCornerRadius(cornerRadius: 5.0, borderColor: UIColor.lightGray, borderWidth: 0.4)
        self.speechText.delegate = self
        self.editorTextView.delegate = self
        self.userAvater.roundCorners(corners: .allCorners, radius: 23.5)
        let image = GFunction.shared.getSavedImage(named: "fileName")
        if image != nil {
            self.userAvater.image = image
        }
        self.speechText.text = "Ask your question here or tap mic icon to speak"
        self.speechText.textColor = UIColor.lightGray
        self.editorTextView.textColor = UIColor.purple
        editorTextView.scrollRangeToVisible(NSRange(location: 0, length: 1))

       
    }
    
    func setupOpenAi(){
        openai = OpenAI(Configuration(organization: "Personal", apiKey: ""))
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
    func navigationToLogin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        loginViewController.modalPresentationStyle = .overFullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    func setupAction(){
        self.readyTosave.handleTapToAction {
//            let convertedString = self.editorTextView.attributedText.attributedString2Html
//
//            print(convertedString)
            
            ///let myString = self.convertToHtml(textView: self.editorTextView)
            self.convertToHtml(textView: self.editorTextView) { data in
            self.delegate?.saveEmailData(data: data)
                GFunction.shared.removeLoader()
                self.dismiss(animated: true)
            }

           
        }
        self.menuIcon.handleTapToAction {
            self.navigationToHome()
        }
        self.logoutButton.handleTapToAction {
            GFunction.shared.setBoolValueWithKey(false, key: "isLogin")
            self.navigationToLogin()
        }
        micButton.handleTapToAction {
            if self.micButton.currentImage == UIImage(named: "stop"){
                self.stopRecording()
            }else{
                if self.speechText.text == "Ask your question here or tap mic icon to speak" || self.speechText.text == "Type something about the image you want to generate" {
                    if self.iSSpeechSelected {
                        self.speechText.text =  ""
                        self.speechText.textColor = UIColor.black
                    }
                }
                do {
                    try self.startRecording()
                    self.listeningLabel.isHidden = false
                } catch let error {
                    print("Error starting recording: \(error.localizedDescription)")
                }
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
        composeButton.handleTapToAction {
            
            print(self.isComposing)
            if  self.isComposing  {
                if self.isImgaeGenaratorSelect {
                    if self.speechText.text != ""  && self.speechText.text != "Type something about the image you want to generate"{
                        self.stopRecording()
                        self.genaretImageFromGpt(prompt: self.speechText.text ?? "")
                        self.showLoadingAnimation()
                        
                    }else {
                        self.sendAlert(title: "", message: "Write something on input box")
                    }
                }else{
                    if self.speechText.text != "" && self.speechText.text != "Ask your question here or tap mic icon to speak"{
                        self.stopRecording()
                        self.genarateTextFromGpt(prompt: self.speechText.text ?? "")
                        self.showLoadingAnimation()
                    }else{
                        self.sendAlert(title: "", message: "Write something on input box")
                    }
                    
                }
            }
        }
        imageGenaratorSelectView.handleTapToAction {
            if self.imageGenaratorSelectView.tag == 101{
                self.imageGenaratorSelectView.backgroundColor = UIColor.lightGray
                self.isImgaeGenaratorSelect = true
                self.imageGenaratorSelectView.tag = -1
                self.speechText.text = "Type something about the image you want to generate"
                self.speechText.textColor = UIColor.lightGray
               
            }else {
                self.imageGenaratorSelectView.backgroundColor = UIColor.white
                self.isImgaeGenaratorSelect = false
                self.imageGenaratorSelectView.tag = 101
                self.speechText.text = "Ask your question here or tap mic icon to speak"
                self.speechText.textColor = UIColor.lightGray
               
            }
           
        }
        checkIconSelectView.handleTapToAction {
            if self.editorTextView.text != "" && self.isComposing {
                self.checkPlagiarism(text: self.editorTextView.text ?? "")
                self.showLoadingAnimation()
            }
      
        }
        checkGrammer.handleTapToAction {
            if self.editorTextView.text != "" && self.isComposing  {
                let grammerCheckString = self.editorTextView.text ?? ""
                self.showLoadingAnimation()
                self.checkGrammer(prompt: grammerCheckString.replacingOccurrences(of: "\n", with: ""))
            }
        }
        
        boldButtonView.handleTapToAction {
            if self.boldButtonView.backgroundColor != UIColor.white {
                let selectedRange = self.editorTextView.selectedRange
                if selectedRange.length != 0 {
                    let regularfont = UIFont(name: "Inter-Regular", size: 15)
                    let originalAttributedString = self.editorTextView.attributedText
                    let attributedString = NSMutableAttributedString(attributedString: originalAttributedString!)
                    attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, stop) in
                        if let attachment = value as? NSTextAttachment {
                            let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location)
                            let textAttachment = NSTextAttachment()
                            textAttachment.image = image
                            textAttachment.bounds = attachment.bounds
                            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                            attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                        }
                    }
                    attributedString.addAttribute(.font, value: regularfont!, range: selectedRange)
                    self.editorTextView.attributedText = attributedString
                    self.boldButtonView.backgroundColor = UIColor.white
                }else {
                    self.editorTextView.fontChange(fontName: "Inter-Bold")
                    self.editorTextView.textColor = UIColor.purple
                }

            }else{
                let selectedRange = self.editorTextView.selectedRange
                if selectedRange.length != 0 {
                    let boldFont = UIFont(name: "Inter-Bold", size: 15)
                    let originalAttributedString = self.editorTextView.attributedText
                    let attributedString = NSMutableAttributedString(attributedString: originalAttributedString!)
                    attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, stop) in
                        if let attachment = value as? NSTextAttachment {
                            let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location)
                            let textAttachment = NSTextAttachment()
                            textAttachment.image = image
                            textAttachment.bounds = attachment.bounds
                            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                            attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                        }
                    }
                    attributedString.addAttribute(.font, value: boldFont!, range: selectedRange)
                    self.editorTextView.attributedText = attributedString
                }else {
                    self.editorTextView.fontChange(fontName: "Inter-Bold")
                    self.editorTextView.textColor = UIColor.purple
                }
                
            }
        }
        self.italicButtonView.handleTapToAction {
            if self.italicButtonView.backgroundColor != UIColor.white {
                let selectedRange = self.editorTextView.selectedRange
                let regularfont = UIFont(name: "Inter-Regular", size: 15)
                if selectedRange.length != 0 {
                    let originalAttributedString = self.editorTextView.attributedText
                    let attributedString = NSMutableAttributedString(attributedString: originalAttributedString!)
                    attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, stop) in
                        if let attachment = value as? NSTextAttachment {
                            let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location)
                            let textAttachment = NSTextAttachment()
                            textAttachment.image = image
                            textAttachment.bounds = attachment.bounds
                            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                            attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                        }
                    }
                    attributedString.addAttribute(.font, value: regularfont!, range: selectedRange)
                    self.editorTextView.attributedText = attributedString
                }else{
                    self.editorTextView.fontChange(fontName: "Inter-Regular")
                    self.editorTextView.textColor = UIColor.purple
                    self.italicButtonView.backgroundColor = UIColor.white
                
                }
            }else{
                let selectedRange = self.editorTextView.selectedRange
                let italicFont = UIFont.italicSystemFont(ofSize: 15)
                if selectedRange.length != 0 {
                    let originalAttributedString = self.editorTextView.attributedText
                    let attributedString = NSMutableAttributedString(attributedString: originalAttributedString!)
                    attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, stop) in
                        if let attachment = value as? NSTextAttachment {
                            let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location)
                            let textAttachment = NSTextAttachment()
                            textAttachment.image = image
                            textAttachment.bounds = attachment.bounds
                            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                            attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                        }
                    }
                    attributedString.addAttribute(.font, value: italicFont, range: selectedRange)
                    self.editorTextView.attributedText = attributedString
                }else{
                    let attributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText)
                    attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                        attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 15), range: range)
                        
                    }
                    self.editorTextView.attributedText = attributedString
                }
            }
        }
        self.fontChangeButtonView.handleTapToAction {
            self.fontSizePicker.isHidden = false
            IQKeyboardManager.shared.resignFirstResponder()
        }
        self.alignLeftButtonView.handleTapToAction {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            DispatchQueue.main.async{
                let selectedRange = self.editorTextView.selectedRange
                if selectedRange.length > 0 {
                    let attributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText.attributedSubstring(from: selectedRange))
                    if !attributedString.string.hasPrefix("\n") {
                           // Add a new line to the beginning of the string
                           let newline = NSMutableAttributedString(string: "\n")
                           attributedString.insert(newline, at: 0)
                       }
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
                    self.editorTextView.textStorage.replaceCharacters(in: selectedRange, with: attributedString)
                } else {
                    let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
                    self.editorTextView.typingAttributes = attributes
                    self.editorTextView.textAlignment = .left
                }
            }
            
        }
        self.alignCenterButtonView.handleTapToAction {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            DispatchQueue.main.async{
                let selectedRange = self.editorTextView.selectedRange
                if selectedRange.length > 0 {
                    let attributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText.attributedSubstring(from: selectedRange))
                    if !attributedString.string.hasPrefix("\n") {
                           // Add a new line to the beginning of the string
                           let newline = NSMutableAttributedString(string: "\n")
                           attributedString.insert(newline, at: 0)
                       }
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
                    self.editorTextView.textStorage.replaceCharacters(in: selectedRange, with: attributedString)
                } else {
                    let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
                    self.editorTextView.typingAttributes = attributes
                    self.editorTextView.textAlignment = .center
                }
                
            }
        }
        self.alignRightButtonView.handleTapToAction {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            
            DispatchQueue.main.async{
            let selectedRange = self.editorTextView.selectedRange
            if selectedRange.length > 0 {
                    let attributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText.attributedSubstring(from: selectedRange))
                if !attributedString.string.hasPrefix("\n") {
                       // Add a new line to the beginning of the string
                       let newline = NSMutableAttributedString(string: "\n")
                       attributedString.insert(newline, at: 0)
                   }
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
                    self.editorTextView.textStorage.replaceCharacters(in: selectedRange, with: attributedString)
                
                
            } else {
                   
                    let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
                    self.editorTextView.typingAttributes = attributes
                    self.editorTextView.textAlignment = .right
                }
           
            }

        }
        self.photoButtonView.handleTapToAction {
            ImagePickerManager().pickImage(self){ image in
                
                DispatchQueue.main.async {
                    self.showImageFromChatGptResponse(image: image)
                }
            }
        }
        self.indentButtonView.handleTapToAction {
            if self.indentButtonView.image == UIImage (named: "intendLeft") {
                self.indentButtonView.image = UIImage (named: "intendRight")
                self.editorTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
            }else{
                self.indentButtonView.image = UIImage (named: "intendLeft")
                self.editorTextView.textContainerInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0);
            }
                    
        }
        self.linkButtonView.handleTapToAction {
                if let range = self.editorTextView.selectedTextRange {
                    print(self.editorTextView.text(in: range) ?? "")
                    self.selectedText = self.editorTextView.text(in: range) ?? ""
                    self.showAlertForHyperLink()
                 }
               }
        self.bulletButtonView.handleTapToAction {
            if self.bulletButtonView.backgroundColor != UIColor.white {
                self.bulletButtonView.backgroundColor = UIColor.white
                self.isDotSelected = false
            }else{
                self.bulletButtonView.backgroundColor = UIColor.lightGray
                self.listButtonView.backgroundColor = UIColor.white
                self.isDotSelected = true
                self.isNuberPointSelect = false
            }
        }
        self.listButtonView.handleTapToAction {
            if self.listButtonView.backgroundColor != UIColor.white {
                self.listButtonView.backgroundColor = UIColor.white
                self.isNuberPointSelect = false
            }else{
                self.listButtonView.backgroundColor = UIColor.lightGray
                self.bulletButtonView.backgroundColor = UIColor.white
                self.isDotSelected = false
                self.isNuberPointSelect = true
            }
        }
        
   

    }
    
    func setToolBar() {
          let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
          toolBar.barStyle = UIBarStyle.default
          toolBar.isUserInteractionEnabled = true
          fontSizePicker.addSubview(toolBar)
        }
    func showLoadingAnimation(){
        loadingAnimation.contentMode = .scaleAspectFill
        loadingAnimation!.loopMode = .loop
        // 5. Adjust animation speed
        loadingAnimation!.animationSpeed = 0.5
        // 6. Play animation
        loadingAnimation.isHidden = false
        self.isComposing = false
        loadingAnimation!.play()
        
    }
    func stopLoadingAnimation(){
        loadingAnimation.stop()
        loadingAnimation.isHidden = true
        self.isComposing = true
    }
    
    func showImageFromChatGptResponse(image: UIImage?){
        let attachment = NSTextAttachment()
                attachment.image = image
                let imageSize = image?.size
                let aspectRatio = (imageSize?.width ?? 250) / (imageSize?.height ?? 200)
                let attachmentWidth: CGFloat = 250.0 // set the desired width of the attachment
                let attachmentHeight = attachmentWidth / aspectRatio // calculate the height based on the aspect ratio
                attachment.bounds = CGRect(x: 0, y: 0, width: attachmentWidth, height: attachmentHeight)
                let attString = NSAttributedString(attachment: attachment)
                editorTextView.textStorage.insert(attString, at: editorTextView.selectedRange.location)
                self.editorTextView.scrollToBottom(animated: true)
                self.editorTextView.textColor = UIColor.purple
                self.editorTextView.font = UIFont(name: "Inter-Regular", size: 15)
        

    }
    
    
}



extension ComposeViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.speechText {
            self.iSSpeechSelected = true
            self.currentScrolliew.isScrollEnabled = false
            extratimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: false)
            if self.speechText.text == "Ask your question here or tap mic icon to speak" || self.speechText.text == "Type something about the image you want to generate" {
                self.speechText.text =  ""
                self.speechText.textColor = UIColor.black
            }
        }else{
            self.iSSpeechSelected = false
            self.currentScrolliew.isScrollEnabled = true
        }
    }
    @objc func timerTick() {
        
        self.currentScrolliew.isScrollEnabled = true
        extratimer?.invalidate()
        extratimer = nil
        // Code to be executed every second
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView == self.speechText {
            if self.speechText.text == "" {
                if self.imageGenaratorSelectView.tag == 101{
                    self.speechText.text = "Ask your question here or tap mic icon to speak"
                    self.speechText.textColor = UIColor.lightGray
                }else {
                    self.speechText.text = "Type something about the image you want to generate"
                    self.speechText.textColor = UIColor.lightGray
                }
            }
            extratimer?.invalidate()
            extratimer = nil
            self.currentScrolliew.isScrollEnabled = true
            print("Scrolling enabled")
            
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 {
            let selectedText = textView.attributedText.attributedSubstring(from: selectedRange)
            let selectedFont = selectedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            // Use selectedFont here
            print(selectedFont?.fontName)
            if selectedFont?.fontName == "Inter-Bold" {
                self.boldButtonView.backgroundColor = UIColor.lightGray
            }else {
                self.boldButtonView.backgroundColor = UIColor.white
            }
            
            if selectedFont?.fontName == ".SFUI-RegularItalic"{
                self.italicButtonView.backgroundColor = UIColor.lightGray
            }else{
                self.italicButtonView.backgroundColor = UIColor.white
            }
        }

    
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.currentScrolliew.isScrollEnabled = true
        if textView == self.editorTextView {
            if text == "\n" {
                if isDotSelected {
                    let currentLine = textView.text[textView.text.startIndex..<textView.text.index(textView.text.startIndex, offsetBy: textView.selectedRange.location)].trimmingCharacters(in: .whitespaces)
                    if !currentLine.isEmpty {
                        let insertionIndex = textView.selectedRange.location + textView.selectedRange.length
                        textView.insertText("\n• ")
                        textView.selectedRange = NSRange(location: insertionIndex + 2, length: 0)
                        return false
                    }
                } else if isNuberPointSelect {
                    currentListNumber = currentListNumber + 1
                    let currentLine = textView.text[textView.text.startIndex..<textView.text.index(textView.text.startIndex, offsetBy: textView.selectedRange.location)].trimmingCharacters(in: .whitespaces)
                    if !currentLine.isEmpty {
                        let insertionIndex = textView.selectedRange.location + textView.selectedRange.length
                        textView.insertText("\n\(currentListNumber) ")
                        textView.selectedRange = NSRange(location: insertionIndex + 2, length: 0)
                        return false
                    }

                }else {
                    return true
                }
                return false
            }else
            {
                return true
            }
        }else if textView == self.speechText {
          
            print(textView.text.count)
            if textView.text.count > 270 {
                self.heightConstant.constant = 175
            }else if textView.text.count > 225 {
                self.heightConstant.constant = 150
            }else if textView.text.count > 180 {
                self.heightConstant.constant = 125
            }else if textView.text.count > 135 {
                self.heightConstant.constant = 100
            }else if textView.text.count > 90 {
                self.heightConstant.constant = 75
            }else if textView.text.count > 45{
                self.heightConstant.constant = 50
            }
        }

        
            return true
        
        
    }
    

    


    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if !URL.absoluteString.isEmpty {
            openURL(URL.absoluteString)
        }
        return false
        }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
           sendAlert(title: "", message: "Wrong url")
            return
        }
        UIApplication.shared.open(url, completionHandler: { success in
            if success {
                print("opened")
            } else {
                print("failed")
                self.sendAlert(title: "Wrong URL", message: "Please include https://,  For example: https://www.sample.com")
                // showInvalidUrlAlert()
            }
        })
    }
    
}

// Animation Text show
extension ComposeViewController  {
    func startRevealingText() {
        self.editorTextView.becomeFirstResponder()
        self.textTimer = nil
        textTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.editorTextView.scrollToBottom(animated: true)
            self?.revealNextCharacter()
            
        }
    }
    func revealNextCharacter() {
        guard nextCharacterIndex < gptResponse.count else {
            textTimer?.invalidate()
            self.textTimer = nil
            nextCharacterIndex = 0
            stopLoadingAnimation()
            self.gptResponse = ""
            self.editorTextView.scrollToBottom(animated: true)
            return
        }
        let nextCharacter = gptResponse[gptResponse.index(gptResponse.startIndex, offsetBy: nextCharacterIndex)]
//        editorTextView.text?.append(nextCharacter)
        
        guard let currentAttributedText = editorTextView.attributedText else { return }
        let newAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)

        
        let cursorPosition = self.editorTextView.selectedRange.location
        let currentText = NSMutableString(string: self.editorTextView.text)
        currentText.insert("\(nextCharacter)", at: cursorPosition)
        newAttributedText.append(NSAttributedString(string: "\(nextCharacter)", attributes: [NSAttributedString.Key.font : UIFont(name: "Inter-Regular", size: 15)!, NSAttributedString.Key.foregroundColor : UIColor.purple]))
        editorTextView.attributedText = newAttributedText
        nextCharacterIndex += 1
       
    }
}

//  GPT Request and REPONSE
extension ComposeViewController { 
    func showtextAfterGrammercehc(){
//
//        // Get the current text and attributed text of the UITextView
//        let originalText = self.editorTextView.text
//        guard let originalAttributedText = self.editorTextView.attributedText else {
//            return
//        }
//
//        // Extract attachment images and their positions from the original attributed text
//        var attachmentPositions: [Int: CGRect] = [:]
//        originalAttributedText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.editorTextView.text.count), options: []) { value, range, stop in
//            guard let attachment = value as? NSTextAttachment else { return }
//            attachmentPositions[range.location] = attachment.bounds
//        }
//
//        // Send the text to the Chat GPT API to change grammar
//        // Replace the original text with the response from the API
//        // ...
//
//        let modifiedAttributedText = NSMutableAttributedString(string: self.gptResponse)
//
//        // Add the attachment images back into the new attributed string
//        for (location, bounds) in attachmentPositions {
//            if let attachment = originalAttributedText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment {
//                let attachmentString = NSAttributedString(attachment: attachment)
//                var newLocation = location
//                if newLocation > self.gptResponse.count {
//                    newLocation = self.gptResponse.count
//                }
//                modifiedAttributedText.replaceCharacters(in: NSRange(location: newLocation, length: 0), with: attachmentString)
//                attachment.bounds = bounds
//                attachmentPositions[location] = bounds
//            }
//        }
//
//        // Update the range of the attributes to account for the location and length of the attachment images
//        let textLengthDifference = modifiedAttributedText.length - originalAttributedText.length
//        let updatedAttributePositions = attachmentPositions.mapValues { $0.offsetBy(dx: 0, dy: CGFloat(textLengthDifference)) }
//
//        // Add the original attributes to the modified attributed string, adjusting the range for the attachment images
//        originalAttributedText.enumerateAttributes(in: NSRange(location: 0, length: originalAttributedText.length), options: []) { attributes, range, stop in
//            let updatedRange = NSRange(location: range.location + updatedAttributePositions.filter { $0.key < range.location }.values.reduce(0, +), length: range.length)
//            for (key, value) in attributes {
//                modifiedAttributedText.addAttribute(key, value: value, range: updatedRange)
//            }
//        }
//
//
//        // Set the new attributed string as the text of the UITextView
//        self.editorTextView.attributedText = modifiedAttributedText
        
        
        
        // Get the current text and attributed text of the UITextView
        let originalText = self.editorTextView.text
        let originalAttributedText = self.editorTextView.attributedText

        // Extract attachment images and their positions from the original attributed text
        var attachmentPositions: [Int: CGRect] = [:]
        originalAttributedText?.enumerateAttribute(.attachment, in: NSRange(location: 0, length: originalText?.count ?? 0), options: []) { value, range, stop in
            guard let attachment = value as? NSTextAttachment else { return }
            attachmentPositions[range.location] = attachment.bounds
        }

        // Send the text to the Chat GPT API to change grammar
        // Replace the original text with the response from the API
        // ...

        // Create a new attributed string from the modified text
        let modifiedAttributedText = NSMutableAttributedString(string: self.gptResponse)

        // Add the attachment images back into the new attributed string
        for (location, bounds) in attachmentPositions {
            if let attachment = originalAttributedText?.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment {
                let attachmentString = NSAttributedString(attachment: attachment)
                var newLocation = location
                if newLocation > self.gptResponse.count {
                    newLocation = self.gptResponse.count
                }
                modifiedAttributedText.replaceCharacters(in: NSRange(location: newLocation, length: 0), with: attachmentString)
                attachment.bounds = bounds
                attachmentPositions[location] = bounds
            }
        }
        
        let color = UIColor.purple
        let font = UIFont(name: "Inter-Regular", size: 15)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font!
        ]
        modifiedAttributedText.addAttributes(attributes, range: NSRange(location: 0, length: modifiedAttributedText.length))
        // Set the new attributed string as the text of the UITextView
        self.editorTextView.attributedText = modifiedAttributedText


        }
        
    
    func checkGrammer(prompt: String){
        self.gptResponse = ""
        guard let openai = openai else {
            return
        }
        Task {
            do {
                let completionParameter = CompletionParameters(
                    model: "text-davinci-002",
                    prompt: ["Correct the grammar in the following sentence:\n\n " + prompt + "\n\nSuggested correction:"],
                    maxTokens: 1024,
                    temperature: 0.98,
                    topP: 1,
                    stop: nil, presencePenalty: 0, frequencyPenalty: 0
                
                )
                print(completionParameter)
                let completionResponse = try await openai.generateCompletion(
                    parameters: completionParameter
                )
                print(completionResponse)
                self.gptResponse = completionResponse.choices[0].text.replacingOccurrences(of: "\n", with: "")
                showtextAfterGrammercehc()
                stopLoadingAnimation()
               
                
            } catch {
                print("ERROR DETAILS - \(error)")
                stopLoadingAnimation()
               
            }
        }
        
    }
    func genarateTextFromGpt(prompt: String){
        self.gptResponse = ""
        guard let openai = openai else {
            return
        }
        Task {
            do {
                let completionParameter = CompletionParameters(
                    model: "text-davinci-001",
                    prompt: [prompt],
                    maxTokens: 500,
                    temperature: 0.98
                )
                print(completionParameter)
                let completionResponse = try await openai.generateCompletion(
                    parameters: completionParameter
                )
                self.gptResponse = completionResponse.choices[0].text.replacingOccurrences(of: "\n", with: "")
                self.startRevealingText()
                print(gptResponse)
            } catch {
                print("ERROR DETAILS - \(error)")
                stopLoadingAnimation()
               
            }
        }
    }
    
    func genaretImageFromGpt(prompt: String){
        guard let openai = openai else {
            return
        }
        Task {
            do {
                let imageParam = ImageParameters(
                    prompt: prompt,
                    numberofImages : 2,
                    resolution: .small,
                    responseFormat: .base64Json
                )
                print(imageParam)
                
                let result = try await openai.createImage(parameters: imageParam)
                print(result)
                let firstImage = try openai.decodeBase64Image(result.data[0].image)
               
                self.showImageFromChatGptResponse(image: firstImage)
                stopLoadingAnimation()
               
               
            } catch {
                print("ERROR DETAILS - \(error)")
                stopLoadingAnimation()
            }
        }
    }
}
//Text to speech


extension ComposeViewController {
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func speechToTextDidReturn(transcribedText: String) {
        let currentText = self.editorTextView.text ?? "" // Get the current text, or an empty string if nil
        let updatedText = currentText + " " + transcribedText // Append the new text to the current text
        self.editorTextView.text = updatedText // Update the text view with the new text
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
                DispatchQueue.main.async {
                    if let result = result {
                        let finalTranscription = result.bestTranscription.formattedString
                        print("Final transcription: \(finalTranscription)")
               
                        print(result.isFinal)
                        if result.isFinal {
                            if self.iSSpeechSelected {
                                let newText = self.speechText.text + finalTranscription
                                if newText.count > 270 {
                                    self.heightConstant.constant = 175
                                }else if newText.count > 225 {
                                    self.heightConstant.constant = 150
                                }else if newText.count > 180 {
                                    self.heightConstant.constant = 125
                                }else if newText.count > 135 {
                                    self.heightConstant.constant = 100
                                }else if newText.count > 90 {
                                    self.heightConstant.constant = 75
                                }else if newText.count > 45{
                                    self.heightConstant.constant = 50
                                }
                                self.speechText.text = newText
                                
                            }else{
                                let currentAttributedString = self.editorTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                                
                                // Get the range of the selected text
                                let selectedRange = self.editorTextView.selectedRange
                                
                                // Create a dictionary of attributes to apply to the new text
                                var attributes = [NSAttributedString.Key: Any]()
                                
                                // Get the font of the existing attributed text and add it to the attributes dictionary
                                if selectedRange.location != NSNotFound && selectedRange.location < currentAttributedString.length {
                                    if let existingFont = currentAttributedString.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
                                        attributes[.font] = existingFont
                                    }
                                }
                                if let existingFont = attributes[.font] as? UIFont {
                                    attributes[.font] = existingFont.withSize(existingFont.pointSize)
                                }else {
                                    attributes[.font] = UIFont(name: "Inter-Regular", size: 15)
                                }

                                
                                // Add the desired color to the attributes dictionary
                                attributes[.foregroundColor] = UIColor.purple
                                
                                // Create a new attributed string with the new text and attributes
                                let newAttributedString = NSAttributedString(string: finalTranscription, attributes: attributes)
                                
                                // Insert the new attributed string at the selected range
                                currentAttributedString.insert(newAttributedString, at: selectedRange.location)
                                
                                // Set the updated attributed text back to the text view
                                self.editorTextView.attributedText = currentAttributedString
                                
                            }
                        }else{
                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                self.stopRecording()
                            }
                        }

                        
                        
                    } else if let error = error {
                        print("Speech recognition error: \(error.localizedDescription)")
                    }
                }
            }
        }

        
    private func stopRecording() {
        self.micButton.setImage(UIImage(named: "🦆 icon _mic_"), for: .normal)
        self.listeningLabel.isHidden = true
        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        timer?.invalidate()
        timer = nil
    }

}

extension ComposeViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Speech recognition available")
        } else {
            print("Speech recognition not available")
        }
    }
}

/// Api Call
///
extension ComposeViewController {


    func checkPlagiarism(text: String) {
        let parameters: [String: Any] = [
            "u":"anyaai",
            "k":"w4qarr4eylxvdymb",
            "o":"csearch",
            "e":"UTF-8",
            "t":text
        ]
        print(parameters)

        AF.request(endpoint, method: .post, parameters: parameters).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    print(data)
                    let xml = XMLHash.config {
                        config in
                        config.shouldProcessLazily = true
                    }.parse(data)
                    
                    print(xml["response"]["querywords"].element?.text)
                    self.stopLoadingAnimation()
                    let wordcount = text.components(separatedBy: " ").count
                    let matchWord =  xml["response"]["result"][0]["minwordsmatched"].element?.text
                    print("\(matchWord) wordc: \(wordcount)")
                    let plagiarismPercent = (100 * (Int(matchWord ?? "") ?? 0)) / wordcount
                    
                    

                    self.sendAlert(title: "Plagiarism Result", message: "Plagiarism: \(plagiarismPercent)% \n Unique: \(100 - plagiarismPercent)%")
                } catch {
                    print("Error: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

}


/// parse xml delegate
extension ComposeViewController: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        // start parsing
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // handle start of an element
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // handle found characters
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // handle end of an element
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // end parsing
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // handle parse error
    }
}
extension ComposeViewController : UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedRangee = editorTextView.selectedRange
        if selectedRangee.length != 0 {
            if let selectedRange = self.editorTextView.selectedTextRange {
                let start = self.editorTextView.offset(from: self.editorTextView.beginningOfDocument, to: selectedRange.start)
                let end = self.editorTextView.offset(from: self.editorTextView.beginningOfDocument, to: selectedRange.end)
                let nsRange = NSRange(location: start, length: end - start)
                let selectedAttributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText.attributedSubstring(from: nsRange))
                selectedAttributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: selectedAttributedString.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                    let currentFont = value as? UIFont ?? UIFont.systemFont(ofSize: 15)
                    let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: CGFloat(pickerData[row]))
                    selectedAttributedString.addAttribute(.font, value: newFont, range: range)
                }
                let fullAttributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText)
                fullAttributedString.replaceCharacters(in: nsRange, with: selectedAttributedString)
                self.editorTextView.attributedText = fullAttributedString
            }
            
        }else{

            let attributedString = NSMutableAttributedString(attributedString: self.editorTextView.attributedText)
            attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                let currentFont = value as? UIFont ?? UIFont.systemFont(ofSize: 15)
                let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: CGFloat(pickerData[row]))
                attributedString.addAttribute(.font, value: newFont, range: range)
            }
            self.editorTextView.attributedText = attributedString

        }
        self.fontSizePicker.isHidden = true
    }
}
extension ComposeViewController {
    func showAlertForHyperLink(){
        self.selectedRange = self.editorTextView.selectedRange
        let alertController = UIAlertController(title: "", message: "Type URL to add", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter url(https://www.google.com)"
            }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField

            self.editorTextView.addHyperLinksToText(originalText: self.editorTextView.attributedText, hyperLinks: ["\(self.selectedText)": "\(firstTextField.text ?? "")"], selectedRange: self.selectedRange)
            
            
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
        self.present(alertController, animated: true, completion: nil)
        }
    }
    

extension ComposeViewController {
    
    func getAccountinfo(){
        let token = GFunction.shared.getStringValueForKey("token")
        GFunction.shared.addLoader()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        guard let url = URL(string: getaccountInfo) else { return}
        AF.request(url, headers: headers).responseDecodable(of: AccountInfoModel.self) { response in
            switch response.result {
            case .success(let data):
                print(data)
                self.accountInfo = data
                GFunction.shared.removeLoader()
            case .failure(let error):
                GFunction.shared.removeLoader()
                print("Error: \(error)")
            }
        }
    }
    
    
    func saveAccount(nImage: String,nWord: String) {
        let parameters: [String: Any] = [
            "nImg":nImage,
            "nWord": nWord,
        ]
        let token = GFunction.shared.getStringValueForKey("token")
        GFunction.shared.addLoader()
        print(parameters)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]

        guard let url = URL(string: getaccountInfo) else { return}
        AF.request(url,method: .post, parameters: parameters, headers : headers).validate().responseDecodable(of: TempleteSaveModel.self)  { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                GFunction.shared.removeLoader()
            case .failure(let error):
                GFunction.shared.removeLoader()
                print("Error: \(error)")
            }
        }
    }
}

extension ComposeViewController {
    func convertToHtml(textView: UITextView, completion: @escaping (String) -> Void) {
        GFunction.shared.addLoader()
        guard let attributedString = textView.attributedText else {
                     completion("")
                     return
                 }
                 let htmlStringBuilder = NSMutableString()

                 // Start the HTML document
                 htmlStringBuilder.append("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"></head><body>")

                 // Traverse the attributed string and extract any attachments
//                 attributedString.enumerateAttribute(.attachment, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, _) in
//                     if let attachment = value as? NSTextAttachment, let image = attachment.image {
//                         // Generate an <img> tag that references the attachment
//                         let imageData = image.pngData() ?? image.jpegData(compressionQuality: 1.0)
//                         let base64String = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
//                         let imageTag = "<img src=\"data:image/png;base64,\(base64String)\"/>"
//                         htmlStringBuilder.append(imageTag)
//                     }
//                 }

                 // Add the text to the HTML document
                 let textRange = NSMakeRange(0, attributedString.length)
                 let text = attributedString.attributedSubstring(from: textRange).string
                 htmlStringBuilder.append(text)

                 // End the HTML document
                 htmlStringBuilder.append("</body></html>")

                 // The resulting HTML string
                 let htmlString = String(htmlStringBuilder)
                completion(htmlString)
        }

}

extension NSAttributedString {
    var attributedString2Html: String? {
        do {
            let options: [NSAttributedString.DocumentAttributeKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let htmlData = try self.data(from: NSRange(location: 0, length: self.length), documentAttributes: options)
            let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
            
            // Replace any image tags with attachment placeholders
            let modifiedHtmlString = htmlString.replacingOccurrences(of: "<img", with: "<attachment")
            
            // Create a mutable attributed string to hold the text and attachments
            let attributedString = NSMutableAttributedString()
            
            // Parse the modified HTML string into attributed text
            let parser = try NSAttributedString(data: modifiedHtmlString.data(using: .utf8)!, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
            
            // Traverse the attributed text and extract any attachments
            parser.enumerateAttribute(.attachment, in: NSMakeRange(0, parser.length), options: []) { (value, range, _) in
                if let attachment = value as? NSTextAttachment, let image = attachment.image {
                    // Add the image as an attachment to the mutable attributed string
                    let attachmentString = NSAttributedString(attachment: attachment)
                    attributedString.append(attachmentString)
                    
                    // Add a new line to the attributed string to separate the attachment from the text
                    attributedString.append(NSAttributedString(string: "\n"))
                }
                else {
                    // Add the non-image text to the mutable attributed string
                    let textString = parser.attributedSubstring(from: range)
                    attributedString.append(textString)
                }
            }
            
            // The resulting attributed string with attachments
            return attributedString.string
        } catch {
            print("error:", error)
            return nil
        }
    }
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString
        } catch {
            print("Error converting HTML string: \(error.localizedDescription)")
            return nil
        }
    }
}
extension UIColor {
    func toHex() -> String {
        let components = self.cgColor.components!
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}


