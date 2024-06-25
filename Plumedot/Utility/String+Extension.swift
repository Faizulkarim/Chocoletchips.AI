//
//  String+Extension.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import Foundation
import UIKit

extension String {
    
    var digits: String {
          return String(filter(("0"..."9").contains))
    }
    
    func trim() -> Self {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func empty() -> Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
    
    /**
     To Get UIAlertAction from String
     
     - Parameter style: UIAlertAction Style
     - Parameter handler: To Handle events
     
     */
    func addAction(style : UIAlertAction.Style  = .default , handler : AlertActionHandlerd? = nil) -> UIAlertAction{
        return UIAlertAction(title: self, style: style, handler: handler)
    }
    
    func fromBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    //MARK: Strikethrough
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }



    
    //MARK:- Convert to Double
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
     //MARK: To check backspace
    
    func isBackspace() -> Bool {
        let  char = self.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        return false
    }
    
    func sizeOfString (font : UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude),
                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }
    
    enum ValidationType: String {
        case alphabet = "[A-Za-z]+"
        case alphabetWithSpace = "[A-Za-z ]*"
        case alphabetNum = "[A-Za-z0-9]*"
        case alphabetNumWithSpace = "[A-Za-z0-9 ]*"
        case name = "^[A-Z a-z]*$"
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        case number = "[0-9]+"
        case password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*=+-])(?=\\S+$).{6,}$"
        case mobileNumber = "^[0-9]\\d{9}$"
        case postalCode = "^[A-Za-z0-9- ]{1,10}$"
        case zipcode = "^[A-Za-z0-9]{4,}$"
        case currency = "^([0-9]+)(\\.([0-9]{0,2})?)?$"
        case amount = "^\\s*(?=.*[1-9.])\\d*(?:\\.\\d{1,2})?\\s*$"
        case bankName = "^[a-zA-Z ]*"
    }
    
    // ---------------------------------------------------------------------------
    
    // MARK: - Custom Methods
    
    func isValid(_ type: ValidationType) -> Bool {
        guard !isEmpty else { return false }
        let regTest = NSPredicate(format: "SELF MATCHES %@", type.rawValue)
        return regTest.evaluate(with: self)
    }
    

    
    var replacedEnglishDigitsWithArabic: String {
        var str = self
        let map = ["٠": "0",
                   "١": "1",
                   "٢": "2",
                   "٣": "3",
                   "٤": "4",
                   "٥": "5",
                   "٦": "6",
                   "٧": "7",
                   "٨": "8",
                   "٩": "9"]
        map.forEach { str = str.replacingOccurrences(of: $1, with: $0) }
        return str
    }
    
}
typealias AlertActionHandlerd = ((UIAlertAction) -> Void)

