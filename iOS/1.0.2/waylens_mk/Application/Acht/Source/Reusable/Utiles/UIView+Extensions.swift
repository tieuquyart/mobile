//
//  UIView+Extensions.swift
//  Acht
//
//  Created by forkon on 2018/9/21.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UIView {

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}

extension UIView {
    
    var widthConstraint: NSLayoutConstraint? {
        return constraints.filter{$0.firstAttribute == .width && $0.secondItem == nil}.first
    }
    
    var heightConstraint: NSLayoutConstraint? {
        return constraints.filter{$0.firstAttribute == .height && $0.secondItem == nil}.first
    }

    var topConstraint: NSLayoutConstraint? {
        return findConstraint(layoutAttribute: NSLayoutConstraint.Attribute.top)
    }
    
    var bottomConstraint: NSLayoutConstraint? {
        guard let superview = superview else {
            return nil
        }
        
        return superview.constraints.filter{$0.firstAttribute == .bottom && ($0.firstItem as? UIView) == self}.first
    }

    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        if let constraints = superview?.constraints {
            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
                return constraint
            }
        }
        return nil
    }

    private func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView {
            let firstItemMatch = firstItem == self && constraint.firstAttribute == layoutAttribute
            let secondItemMatch = secondItem == self && constraint.secondAttribute == layoutAttribute
            return firstItemMatch || secondItemMatch
        }
        return false
    }

}

extension UIView {
    
    func fadedLeftRightEdges(leftEdgeInset: CGFloat, rightEdgeInset: CGFloat) {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = CGRect(x: 0, y: 0.0, width: bounds.width, height: bounds.height)
        maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        maskLayer.locations = [0.0, leftEdgeInset / bounds.width, 1 - rightEdgeInset / bounds.width, 1.0] as [NSNumber]
        maskLayer.startPoint = CGPoint(x: 0.0, y: 0)
        maskLayer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.mask = maskLayer
    }
    
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
    
}

extension UIView: Cutoutable {}

struct ViewShadowConfig {
    let color: UIColor
    let offset: CGSize
    let opacity: Float
    let radius: CGFloat

    static let `default` = ViewShadowConfig(color: UIColor.black, offset: CGSize(width: 0.0, height: 2.0), opacity: 0.17, radius: 4.0)
}

private class ShadowView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()

        updateShadowPath()
    }

    private func updateShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
    }

}

extension UIView {
    private struct AssociatedKeys {
        static var shadowView: UInt8 = 0
    }

    private var shadowView: UIView? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shadowView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shadowView) as? UIView
        }
    }

    func dropShadow(_ shadowConfig: ViewShadowConfig) {
        guard let superView = superview else {
            return
        }

        if shadowView == nil {
            shadowView = ShadowView()
            shadowView?.translatesAutoresizingMaskIntoConstraints = false
            shadowView?.layer.masksToBounds = false
            shadowView?.layer.shadowColor = shadowConfig.color.cgColor
            shadowView?.layer.shadowOffset = shadowConfig.offset
            shadowView?.layer.shadowOpacity = shadowConfig.opacity
            shadowView?.layer.shadowRadius = shadowConfig.radius
        }

        if let shadowView = shadowView, shadowView.superview != superview {
            shadowView.removeFromSuperview()
            superView.insertSubview(shadowView, belowSubview: self)

            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

            layer.cornerRadius = shadowConfig.radius
            layer.masksToBounds = true
        }
    }

}
