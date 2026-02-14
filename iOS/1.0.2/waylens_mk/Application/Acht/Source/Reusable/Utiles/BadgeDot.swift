//
//  BadgeDot.swift
//  Acht
//
//  Created by forkon on 2019/3/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UIView {
    
    fileprivate struct AssociatedKeys {
        static var badgeDot: UInt8 = 8
        static var badgeDotCenterXConstraint: UInt8 = 18
        static var badgeDotCenterYConstraint: UInt8 = 28
    }
    
    fileprivate var badgeDotCenterXConstraint: NSLayoutConstraint? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeDotCenterXConstraint, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeDotCenterXConstraint) as? NSLayoutConstraint
        }
    }
    
    fileprivate var badgeDotCenterYConstraint: NSLayoutConstraint? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeDotCenterYConstraint, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeDotCenterYConstraint) as? NSLayoutConstraint
        }
    }
    
  
    
    fileprivate var badgeDot: UIView {
        var badgeDot = objc_getAssociatedObject(self, &AssociatedKeys.badgeDot) as? UIView
        
        if badgeDot == nil {
            let sideLength: CGFloat = 16

            badgeDot = UIView()
            badgeDot?.backgroundColor = UIColor.red
            badgeDot?.translatesAutoresizingMaskIntoConstraints = false
            badgeDot?.widthAnchor.constraint(equalToConstant: sideLength).isActive = true
            badgeDot?.heightAnchor.constraint(equalToConstant: sideLength).isActive = true
            badgeDot?.layer.cornerRadius = 8
            badgeDot?.layer.masksToBounds = true
            
        
            objc_setAssociatedObject(self, &AssociatedKeys.badgeDot, badgeDot, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return badgeDot!
    }
    
    func showBadgeDot(withOffset offset: CGPoint = CGPoint.zero) {
        if !subviews.contains(badgeDot) {
            addSubview(badgeDot)
            
            badgeDotCenterXConstraint = badgeDot.centerXAnchor.constraint(equalTo: rightAnchor)
            badgeDotCenterXConstraint?.isActive = true
            badgeDotCenterYConstraint = badgeDot.centerYAnchor.constraint(equalTo: topAnchor)
            badgeDotCenterYConstraint?.isActive = true
        }
        
        badgeDotCenterXConstraint?.constant = offset.x
        badgeDotCenterYConstraint?.constant = offset.y
        
        badgeDot.isHidden = false
        bringSubviewToFront(badgeDot)
    }
    
    func hideBadgeDot() {
        badgeDot.isHidden = true
    }
    
}

extension UIBarButtonItem {
    
    var view: UIView? {
        return value(forKey: "view") as? UIView
    }
    
    func showBadgeDot(withOffset offset: CGPoint = CGPoint.zero) {
        view?.showBadgeDot(withOffset: offset)
    }
    
    func hideBadgeDot() {
        view?.hideBadgeDot()
    }
    
}
