//
//  UITextView+Extension.swift
//  Plumedot
//
//  Created by Md Faizul karim on 1/2/23.
//

import Foundation
import UIKit
import AVFoundation


extension UITextView {
    func fontChange(fontName: String) {
        let font = UIFont(name: fontName, size: 15)
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText)
        // Remove any attributes for the text portion of the attributed string
        for i in 0..<attributedText.length {
            if attributedText.attribute(.attachment, at: i, effectiveRange: nil) == nil {
                attributedText.addAttribute(.font, value: font!, range: NSRange(location: i, length: 1))
            }
        }
        
        self.attributedText = attributedText
    }
    func addHyperLinksToText(originalText: NSAttributedString, hyperLinks: [String: String], selectedRange: NSRange?) {

            let attributedOriginalText = NSMutableAttributedString(attributedString: originalText)
                    
        if selectedRange?.length ?? 0 > 0 {
            let selectedText = attributedOriginalText.attributedSubstring(from: selectedRange!).string

             if let urlString = hyperLinks[selectedText] {
                 attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: selectedRange!)
             }
         }

//            for (hyperLink, urlString) in hyperLinks {
//                var selectedRange = NSRange(location: 0, length: attributedOriginalText.length)
//
//                while selectedRange.length > 0 {
//                    selectedRange = attributedOriginalText.mutableString.range(of: hyperLink, options: [], range: selectedRange)
//
//                    if selectedRange.location == NSNotFound {
//                        break
//                    }
//
//                    attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: selectedRange)
//                    selectedRange.location = selectedRange.upperBound
//                    selectedRange.length = attributedOriginalText.length - selectedRange.location
//                }
//            }

            attributedOriginalText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedOriginalText.length), options: []) { (value, range, stop) in
                if let attachment = value as? NSTextAttachment {
                    let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location)
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = image
                    textAttachment.bounds = attachment.bounds
                    let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                    attributedOriginalText.replaceCharacters(in: range, with: attrStringWithImage)
                }
            }

            self.linkTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.blue,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
            self.attributedText = attributedOriginalText

        }
    
    
}

extension UITextView {
    func scrollToBottom(animated: Bool) {
        let range = NSMakeRange(text.count - 1, 1)
        scrollRangeToVisible(range)
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}



class CustomTextAttachment: NSTextAttachment {
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var attachmentWidth: CGFloat = 0.0
    var attachmentHeight: CGFloat = 0.0

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        var imageRect = CGRect.zero
        if attachmentWidth > 0 && attachmentHeight > 0 {
            imageRect.size = CGSize(width: attachmentWidth, height: attachmentHeight)
        } else {
            let imageSize = self.image?.size ?? CGSize.zero
            imageRect.size = imageSize
        }
        switch contentMode {
        case .scaleAspectFit:
            imageRect = AVMakeRect(aspectRatio: imageRect.size, insideRect: lineFrag)
        case .scaleAspectFill:
            let scale = max(lineFrag.width / imageRect.width, lineFrag.height / imageRect.height)
            let scaledSize = CGSize(width: imageRect.width * scale, height: imageRect.height * scale)
            let origin = CGPoint(x: lineFrag.minX - (scaledSize.width - lineFrag.width) / 2.0, y: lineFrag.minY - (scaledSize.height - lineFrag.height) / 2.0)
            imageRect = CGRect(origin: origin, size: scaledSize)
        default:
            imageRect.size = lineFrag.size
        }
        return imageRect
    }
}





