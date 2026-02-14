//
//  UITextField+Localization.swift
//  Acht
//
//  Created by forkon on 2018/11/14.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UITextField {
    
    @IBInspectable var localizePlaceholder: String {
        set {
            self.placeholder = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.placeholder ?? ""
        }
    }
    
}
