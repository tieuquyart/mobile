//
//  FirmwareUtils.swift
//  Acht
//
//  Created by forkon on 2019/9/4.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FirmwareUtils {

    class func updateRequired(for camera: UnifiedCamera) -> Bool {
        if camera.remote?.firmwareToUpgradeInfo != nil {
            if camera.remote?.firmwareToUpgradeInfo?.hardwareVersion == camera.model,
                let currentFirmware = camera.firmware,
                camera.remote?.firmwareToUpgradeInfo?.firmware.isNewer(than: currentFirmware) == true {
                return true
            }
        }

        return false
    }

}
