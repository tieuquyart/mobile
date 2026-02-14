//
//  UIButton+Localization.swift
//  Acht
//
//  Created by forkon on 2018/11/14.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UIButton {
    
    @IBInspectable var localizeString: String {
        set {
            setTitle(NSLocalizedString(newValue, comment:""), for: .normal)
        }
        get {
            return title(for: .normal) ?? ""
        }
    }
    
}
