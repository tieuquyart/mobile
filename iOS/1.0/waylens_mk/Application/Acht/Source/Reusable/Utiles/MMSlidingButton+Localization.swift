//
//  MMSlidingButton+Localization.swift
//  Acht
//
//  Created by forkon on 2018/11/27.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension MMSlidingButton {
    @IBInspectable var localizeButtonText: String {
        set {
            self.buttonText = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.buttonText
        }
    }
    
    @IBInspectable var localizeDragPointText: String {
        set {
            self.dragPointText = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.dragPointText
        }
    }
    
    @IBInspectable var localizeButtonUnlockedText: String {
        set {
            self.buttonUnlockedText = NSLocalizedString(newValue, comment:"");
        }
        get {
            return self.buttonUnlockedText
        }
    }
}
