//
//  Validation.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import Foundation
import UIKit

class Validation: NSObject {
    
    //--------------------------------------------------------------------------------------
    
    static func isAlphabaticString(txt: String)         -> Bool {
        
        let RegEx   = "[A-Za-z]+"
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        return result;
    }
    
    //--------------------------------------------------------------------------------------
    
    static func isAlphabaticStringWithSpace(txt: String)         -> Bool {
        
        let RegEx   = "[A-Za-z ]+"
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        return result;
    }
    
    //------------------------------------------------------
    
    static func isAlphaNummericString(txt: String)      -> Bool {
        
        let RegEx   = "^[A-Za-z0-9 _]+$"
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        return result;
    }
    
    //--------------------------------------------------------------------------------------
    
    static func isValidMiddleName(txt: String)          -> Bool {
        let RegEx   = "[A-Za-z]{1}+\\.?"
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        debugPrint("str : \(txt) validation : \(result)")
        return result
    }
    
    //--------------------------------------------------------------------------------------
    static  func isValidEmail(testStr:String) -> Bool {
        let emailRegEx  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest   = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result  = emailTest.evaluate(with: testStr)
        return result
    }
    static func isValidFirstName(txt: String)           -> Bool {
        let RegEx   = "^[A-Z][a-z]*$"
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        debugPrint("str : \(txt) validation : \(result)")
        return result
    }
    
    //--------------------------------------------------------------------------------------
    

    
    static func isValidMobileTextChange(testStr:String) -> Bool
    {
        let nameRegEx = "[0-9]*"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: testStr)
    }
    
    static func isValidPasssword(txt: String) -> Bool {
        
        let RegEx   = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{6,}$"
        debugPrint(txt)
        let eTest   = NSPredicate(format:"SELF MATCHES %@", RegEx)
        let result  = eTest.evaluate(with: txt)
        return result;
        
        // https://stackoverflow.com/questions/39284607/how-to-implement-a-regex-for-password-validation-in-swift
    }
    
    static func isValidTextView(textView: UITextView) -> Bool {
        guard let text = textView.text, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            // this will be reached if the text is nil (unlikely)
            // or if the text only contains white spaces
            // or no text at all
            return false
        }
        
        return true
    }
}

enum ValidationMessage : String {
    
    case invalidUser = "please enter a user name"
    case invalidPasswrod = "Password should be more than 8 charecter"
    case errorLogin = "Your email or password didn't match"
    case InvalidMatchPass = "Your password didn't match"
    case invalidFirstName = "Please enter full name"
    case invalidLastName = "Please enter last name"
    case invalidEmail = "Please enter a valid email"
    case invalidTempleteText = "Please enter template text"
    case invalidTempletetitle = "Please enter a title to save the template"
    case emptyEmailcompose = "There in no composed email yet. Please click compose button for compose"
    case invalidTempleteDescription = "Please enter a description"
    case invalidTonOfVoice = "Please enter a ton of voice"
    case invalidKeyword = "Please enter a keyword"
    case invalidOutputlangth = "Please Select Output langth"
    
}
