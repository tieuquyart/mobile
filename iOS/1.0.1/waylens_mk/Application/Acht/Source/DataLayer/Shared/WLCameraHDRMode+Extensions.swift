//
//  CameraHDRMode+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/2/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

extension WLCameraHDRMode {
    
    public func toString() -> String {
        switch self {
        case .on:
            return "On"
        case .off:
            return "Off"
        case .auto:
            return "Auto"
        default:
            return ""
        }
    }
    
    public static func allModes() -> [WLCameraHDRMode] {
        return [.on, .auto, .off]
    }
    
}
