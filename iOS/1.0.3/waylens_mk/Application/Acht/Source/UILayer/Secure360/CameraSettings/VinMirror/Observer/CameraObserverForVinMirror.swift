//
//  CameraDeviceObserver.swift
//  Acht
//
//  Created by forkon on 2020/4/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

class CameraObserverForVinMirror: Observer {
    weak var eventResponder: CameraObserverForVinMirrorEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    private let camera: UnifiedCamera
    private var observation: NSKeyValueObservation?

    init(camera: UnifiedCamera) {
        self.camera = camera
    }

    func startObserving() {
        observation = camera.local?.observe(\.vinMirrorList) { [weak self] (camera, change) in
            guard let self = self else {
                return
            }

            self.eventResponder?.received(newVinMirrors: (self.camera.local?.vinMirrorList  as? [VinMirror]) ?? [])
        }
    }

    func stopObserving() {
        observation = nil
    }
}
