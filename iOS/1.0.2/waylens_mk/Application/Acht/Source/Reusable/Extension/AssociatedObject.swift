//
//  AssociatedObject.swift
//  Acht
//
//  Created by forkon on 2020/6/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

public func associatedObject<T: AnyObject>(_ host: AnyObject, key: UnsafeRawPointer, initial: () -> T) -> T {
    var value = objc_getAssociatedObject(host, key) as? T
    if value == nil {
        value = initial()
        objc_setAssociatedObject(host, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    return value!
}
