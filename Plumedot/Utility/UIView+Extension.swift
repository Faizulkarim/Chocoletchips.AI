//
//  GExtension+UIView.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
let padding : CGFloat = 15

extension UIView {

    fileprivate typealias ReturnGestureAction = (() -> Void)?
    func applyViewShadow(shadowOffset : CGSize? , shadowColor : UIColor?, shadowOpacity : Float?) {
        
        if shadowOffset != nil {
            self.layer.shadowOffset = shadowOffset!
        }
        else {
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        if shadowColor != nil {
            self.layer.shadowColor = shadowColor?.cgColor
        } else {
            self.layer.shadowColor = UIColor.clear.cgColor
        }
        
        //For button border width
        if shadowOpacity != nil {
            self.layer.shadowOpacity = shadowOpacity!
        }
        else {
            self.layer.shadowOpacity = 0
        }
        
        self.layer.masksToBounds = false
    }
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer1"
    }
    fileprivate var tapGestureRecognizerAction: ReturnGestureAction? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? ReturnGestureAction
            return tapGestureRecognizerActionInstance
        }
    }
    
    func handleTapToAction(action: (() -> Void)?) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHanldeAction))
        self.tapGestureRecognizerAction = action
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gesture)
    }

    @objc func tapGestureHanldeAction() {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
//            print("no action")
        }
    }
    
    func roundCornersWithShdow(corners: UIRectCorner, radius: CGFloat, shdowColor: UIColor) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = path.cgPath
        
        shadowLayer.path = path.cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = shdowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 3
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func applyCornerRadius(cornerRadius : CGFloat? = nil, borderColor : UIColor? = nil , borderWidth : CGFloat? = nil) {
        
        //For button corner radius
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        //For Border color
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        //For button border width
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
    }
}


