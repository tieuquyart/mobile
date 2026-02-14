//
//  ApplicationIconBadge.swift
//  Acht
//
//  Created by forkon on 2019/3/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

final class AppIconBadge {

    static var number: Int {
        return sharedApplication.applicationIconBadgeNumber
    }
    
    static func setNumber(_ number: Int) {
        sharedApplication.applicationIconBadgeNumber = number
        notifyChange()
    }
    
    static func increase() {
        sharedApplication.applicationIconBadgeNumber += 1
        notifyChange()
    }
    
    static func decrease() {
        sharedApplication.applicationIconBadgeNumber -= 1
        notifyChange()
    }
    
    static func reset() {
        sharedApplication.applicationIconBadgeNumber = 0
        notifyChange()
    }
    
    private static func notifyChange() {
        NotificationCenter.default.post(name: Notification.Name.AppIconBadge.numberDidChange, object: nil)
    }
    
}

extension Notification.Name {
    
    public struct AppIconBadge {
        static let numberDidChange = Notification.Name(rawValue: "waylens.acht.notification.name.appIconBadge.numberDidChange")
    }
    
}
