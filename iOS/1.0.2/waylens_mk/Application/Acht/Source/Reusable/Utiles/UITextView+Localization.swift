//
//  UITextView+Localization.swift
//  Acht
//
//  Created by forkon on 2019/5/29.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UITextView {

    @IBInspectable var localizeString: String {
        set {
            self.text = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.text ?? ""
        }
    }

}
