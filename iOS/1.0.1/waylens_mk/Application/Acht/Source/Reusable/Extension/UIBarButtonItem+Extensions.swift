//
//  UIBarButtonItem+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/2/13.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    public typealias ActionBlock = (UIBarButtonItem) -> ()

    private struct AssociatedKeys {
        static var actionBlock: UInt8 = 8
    }

    private var actionBlock: ActionBlock? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionBlock, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionBlock) as? ActionBlock
        }
    }

    public convenience init(title: String?, style: UIBarButtonItem.Style, actionBlock: @escaping ActionBlock) {
        self.init(title: title, style: style, target: nil, action: #selector(buttonTapped(_:)))
        self.actionBlock = actionBlock
    }

    @objc private func buttonTapped(_ sender: UIBarButtonItem) {
        actionBlock?(sender)
    }

}
