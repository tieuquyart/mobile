//
//  UIImageView+Extensions.swift
//  Acht
//
//  Created by forkon on 2018/9/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UIImageView {

    @IBInspectable var usingTemplateImage: Bool {
        set {
            if newValue {
                setTemplateImage(self.image, color: self.tintColor)
            }
        }
        get {
            return self.image?.renderingMode == .alwaysTemplate
        }
    }

    func setTemplateImage(_ image: UIImage?, color: UIColor) {
        self.image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
    
}

