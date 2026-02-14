//
//  Weak.swift
//  WaylensFoundation
//
//  Created by forkon on 2020/9/14.
//  Copyright © 2020 Waylens. All rights reserved.
//

import Foundation

public class Weak<T: AnyObject> {
    public weak var value: T?

    public init(value: T?) {
        self.value = value
    }
}
