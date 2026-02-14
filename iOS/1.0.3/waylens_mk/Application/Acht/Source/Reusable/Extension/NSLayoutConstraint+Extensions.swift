//
//  NSLayoutConstraint+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/6/5.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: self.firstItem!,
            attribute: self.firstAttribute,
            relatedBy: self.relation,
            toItem: self.secondItem,
            attribute: self.secondAttribute,
            multiplier: multiplier,
            constant: self.constant
        )
    }

}
