//
//  UIBarButtonItem+Lacalization.swift
//  Acht
//
//  Created by forkon on 2018/11/19.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    @IBInspectable var localizeString: String {
        set {
            self.title = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.title ?? ""
        }
    }
    
}
