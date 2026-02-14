//
//  UIButton+Extensions.swift
//  Acht
//
//  Created by forkon on 2018/11/27.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UIButton {
    
    private struct AssociatedKeys {
        static var imageTitleSpaceKey: UInt8 = 8
    }
    
    var imageTitleSpace: CGFloat {
        set(newSpace) {
            objc_setAssociatedObject(self, &AssociatedKeys.imageTitleSpaceKey, newSpace, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -newSpace / 2.0, bottom: 0.0, right: newSpace / 2.0)
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: newSpace / 2.0, bottom: 0.0, right: -newSpace / 2.0)
            
            layoutIfNeeded()
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.imageTitleSpaceKey) as! CGFloat
        }
    }
    
}

extension UIButton {

    @IBInspectable
    var templateImage: UIImage? {
        set {
            setImage(newValue?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        get {
            return image(for: .normal)
        }
    }

}

public extension UIButton {

    enum CornerRadius {
        case custom(radius: CGFloat)
        case halfHeight
    }

    func set(
        title: String,
        titleFont: UIFont,
        titleColor: UIColor = UIColor.black,
        imageOnTitleLeft: UIImage?,
        imageOnTitleRight: UIImage?,
        margins: UIEdgeInsets,
        borderColor: UIColor = UIColor.black,
        borderWidth: CGFloat = 1.0,
        cornerRadius: CornerRadius
        ) {
        let attributedTitle = NSAttributedString.attributedString(
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            imageOnTitleLeft: imageOnTitleLeft,
            imageOnTitleRight: imageOnTitleRight
        )

        setAttributedTitle(attributedTitle, for: .normal)

        contentEdgeInsets = margins

        sizeToFit()

        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth

        switch cornerRadius {
        case .custom(let radius):
            layer.cornerRadius = radius
        case .halfHeight:
            layer.cornerRadius = 5
        }
    }

}
