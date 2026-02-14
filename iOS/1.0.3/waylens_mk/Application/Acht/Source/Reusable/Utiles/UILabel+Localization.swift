//
//  UILabel+Localization.swift
//  Acht
//
//  Created by forkon on 2018/11/12.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UILabel {
    
    @IBInspectable var localizeString: String {
        set {
            self.text = NSLocalizedString(newValue, comment:newValue);
        }
        get {
            return self.text ?? ""
        }
    }
    
}
