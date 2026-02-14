//
//  RecordConfigActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

enum RecordConfigActions: Action {
    case updateRecordConfigList([WLEvcamRecordConfigListItem])
    case willSelectRecordConfig(String)
    case updateRecordConfig(WLCameraRecordConfig?)
}

struct RecordConfigFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
