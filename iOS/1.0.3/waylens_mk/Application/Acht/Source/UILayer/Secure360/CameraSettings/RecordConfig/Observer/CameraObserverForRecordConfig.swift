//
//  CameraDeviceObserver.swift
//  Acht
//
//  Created by forkon on 2020/4/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation
import WaylensCameraSDK

class CameraObserverForRecordConfig: Observer {
    weak var eventResponder: CameraObserverForRecordConfigEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    private let camera: UnifiedCamera
    private var recordConfigListObservation: NSKeyValueObservation? = nil
    private var recordConfigObservation: NSKeyValueObservation? = nil

    init(camera: UnifiedCamera) {
        self.camera = camera
    }

    func startObserving() {
        recordConfigListObservation = camera.local?.observe(\.recordConfigList) { [weak self] (camera, change) in
            guard let self = self else {
                return
            }

            self.eventResponder?.received(newRecordConfigList: (self.camera.local?.recordConfigList as? [WLEvcamRecordConfigListItem]) ?? [])
        }

        recordConfigObservation = camera.local?.observe(\.recordConfig) { [weak self] (camera, change) in
            guard let self = self, let recordConfig = self.camera.local?.recordConfig else {
                return
            }

            self.eventResponder?.received(newRecordConfig: recordConfig)
        }
    }

    func stopObserving() {
        recordConfigListObservation = nil
    }
}
