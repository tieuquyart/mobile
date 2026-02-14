//
//  UIApplication+Extensions.swift
//  WaylensUIKit
//
//  Created by forkon on 2021/1/26.
//  Copyright © 2021 Waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

public extension WaylensSpace where Base == UIApplication {

    var displayName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }

}
