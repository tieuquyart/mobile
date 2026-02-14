//
//  FirmwareUpdater.swift
//  Fleet
//
//  Created by forkon on 2019/9/4.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

struct FirmwareToUpgradeInfo {
    var hardwareVersion: String
    var firmware: String
    var firmwareShort: String

    init?(dict: [String : Any]?) {
        if let dict = dict,
            let hardwareVersion = dict["hardwareVersion"] as? String,
            let firmware = dict["firmware"] as? String,
            let firmwareShort = dict["firmwareShort"] as? String {
            self.hardwareVersion = hardwareVersion
            self.firmware = firmware
            self.firmwareShort = firmwareShort
        } else {
            return nil
        }
    }
}

class FirmwareUpdater {
    var firmwareInfo: WLFirmwareInfo? = nil

    func fetchFirmwareInfo(for camera: UnifiedCamera, completion: @escaping ((WLFirmwareInfo?) -> Void)) {
        WaylensClientS.shared.fetchCameraManualUpgradeFirmwareInfo(camera.sn) { [weak self] (result) in
            switch result {
            case .success(let value):
                if let firmwareDict = value["firmware"] as? [String : Any] {
                    let fwInfoDict: [String : Any] = [
                        "name" : firmwareDict["hardwareVersion"] ?? "",
                        "BSPVersion" : firmwareDict["firmware"] ?? "",
                        "version" : firmwareDict["firmwareShort"] ?? "",
                        "description" : firmwareDict["description"] ?? [:],
                        "md5" : firmwareDict["md5sum"] ?? "",
                        "url" : firmwareDict["file"] ?? "",
                        "size" : firmwareDict["size"] ?? 0
                    ]

                    let fwInfo = WLFirmwareInfo(dictionary: fwInfoDict)
                    self?.firmwareInfo = fwInfo
                    completion(fwInfo)
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }

}
