//
//  UIAlertControllerHelper.swift
//  Acht
//
//  Created by Chester Shen on 8/31/17.
//  Copyright © 2017 waylens. All rights reserved.
//

extension UIAlertController.Style {
    static var actionSheetOrAlertOnPad: UIAlertController.Style {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .alert
        } else {
            return .actionSheet
        }
    }
}
