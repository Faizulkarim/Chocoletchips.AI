//
//  dynamicHeightTextfield.swift
//  Plumedot
//
//  Created by Md Faizul karim on 11/2/23.
//

import Foundation

import UIKit

class GrowingTextField: UITextField, UITextFieldDelegate {
    
    private let padding: CGFloat = 16
    private let minimumHeight: CGFloat = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: size.height + padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height = super.sizeThatFits(size).height
        if height < minimumHeight {
            height = minimumHeight
        }
        return CGSize(width: size.width, height: height + padding)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
}
