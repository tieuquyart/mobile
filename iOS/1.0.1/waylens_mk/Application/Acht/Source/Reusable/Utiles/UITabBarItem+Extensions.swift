//
//  UITabBarItem+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/3/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UITabBarItem {
    
    var badgeNumber: Int? {
        return (badgeValue as NSString?)?.integerValue
    }
    
    func setBadgeNumber(_ badgeNumber: Int) {
        switch badgeNumber {
        case 1...99:
            badgeValue = badgeNumber < 10 ? "0\(badgeNumber)" : "\(badgeNumber)"
        case 100...Int.max:
            badgeValue = "99+"
        default:
            badgeValue = nil
        }
    }
    
}
