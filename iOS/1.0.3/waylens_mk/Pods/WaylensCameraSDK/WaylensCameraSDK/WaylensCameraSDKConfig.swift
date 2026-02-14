//
//  WaylensCameraSDKConfig.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2020/12/4.
//  Copyright © 2020 Waylens. All rights reserved.
//

import Foundation

@objc
public enum WaylensCameraSDKTarget: Int {
    case toC
    case toB
}

@objc
public class WaylensCameraSDKConfig: NSObject {
    @objc
    public static let current = WaylensCameraSDKConfig()

    @objc
    public var target = WaylensCameraSDKTarget.toB
    @objc
    public private(set) var defaultIPV4sUsingInCamera = ["192.168.110.1", "192.168.119.1"]
}
