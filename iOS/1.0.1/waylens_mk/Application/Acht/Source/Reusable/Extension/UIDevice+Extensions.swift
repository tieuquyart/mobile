//
//  UIDevice+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/6/22.
//  Copyright © 2020 waylens. All rights reserved.
//

extension UIDevice {

    var supports4KVideo: Bool {
        return AVCaptureDevice.has4KCamera
    }

    var hasSensorNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }

}
