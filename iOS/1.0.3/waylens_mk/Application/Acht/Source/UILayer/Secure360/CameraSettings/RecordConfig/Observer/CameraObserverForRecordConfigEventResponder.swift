//
//  CameraObserverForRecordConfigEventResponder.swift
//  Acht
//
//  Created by forkon on 2020/4/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation
import WaylensCameraSDK

protocol CameraObserverForRecordConfigEventResponder: class {
    func received(newRecordConfigList: [WLEvcamRecordConfigListItem])
    func received(newRecordConfig: WLCameraRecordConfig)
}
