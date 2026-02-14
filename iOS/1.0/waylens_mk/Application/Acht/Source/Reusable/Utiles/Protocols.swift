//
//  Protocols.swift
//  Acht
//
//  Created by forkon on 2018/9/6.
//  Copyright © 2018 waylens. All rights reserved.
//

import Foundation

protocol NibCreatable {
    static func createFromNib(owner: Any?) -> Self?
}

extension NibCreatable where Self: Any {
    
    static func createFromNib(owner: Any? = nil) -> Self? {
        guard let nibName = nibName else {
            return nil
        }
        let bundleContents = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)
        guard let result = bundleContents?.last as? Self else {
            return nil
        }
        return result
    }
    
    static var nibName: String? {
        guard let theClass = Self.self as? AnyClass, let n = NSStringFromClass(theClass).components(separatedBy: ".").last else {
            return nil
        }
        return n
    }
    
}

protocol Cutoutable {
    func cut(_ rectToCut: CGRect)
}

extension Cutoutable where Self: UIView {
    
    func cut(_ rectToCut: CGRect) {
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(rect: rectToCut))

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    func uncut() {
        layer.mask = nil
    }
}

protocol BadgeDotShowable {
    func showBadgeDot()
    func hideBadgeDot()
}

extension BadgeDotShowable where Self: UIView {
    
    func showBadgeDot() {
        
    }
    
    func hideBadgeDot() {
        
    }
    
}
