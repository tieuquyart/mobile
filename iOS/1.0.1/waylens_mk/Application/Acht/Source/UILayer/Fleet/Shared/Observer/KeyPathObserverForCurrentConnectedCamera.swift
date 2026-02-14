//
//  KeyPathObserverForCurrentConnectedCamera.swift
//  Fleet
//
//  Created by forkon on 2020/8/18.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

class KeyPathObserverForCurrentConnectedCamera: Observer {

    weak var eventResponder: KeyPathObserverForCurrentConnectedCameraEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    private var keyPathsToObserve: [PartialKeyPath<WLCameraDevice>] = []

    init(keyPathsToObserve: PartialKeyPath<WLCameraDevice>...) {
        self.keyPathsToObserve = keyPathsToObserve
    }

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        handleCurrentDeviceDidChangeNotification()
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

//MARK: - Private

private extension KeyPathObserverForCurrentConnectedCamera {

    @objc func handleCurrentDeviceDidChangeNotification() {
        keyPathsToObserve.forEach { (keyPath) in
            switch keyPath {
            case \WLCameraDevice.hasDmsCamera:
                observe(\WLCameraDevice.hasDmsCamera)
            case \WLCameraDevice.recState:
                observe(\WLCameraDevice.recState)
            case \WLCameraDevice.recordConfig:
                observe(\WLCameraDevice.recordConfig)
            case \WLCameraDevice.batteryInfo:
            observe(\WLCameraDevice.batteryInfo)
            case \WLCameraDevice.obdWorkModeConfig:
                observe(\WLCameraDevice.obdWorkModeConfig)
            case \WLCameraDevice.vinMirrorList:
                observe(\WLCameraDevice.vinMirrorList)
            case \WLCameraDevice.adasConfig:
                observe(\WLCameraDevice.adasConfig)
            default:
                break
            }
        }
    }

    func observe<Value>(_ keyPath: KeyPath<WLCameraDevice, Value>) {
        WLBonjourCameraListManager.shared.currentCamera?.wl.observe(keyPath, options: [.initial, .new], changeHandler: { [weak self] (camera, newValue) in
            self?.eventResponder?.camera(camera, attributeDidChange: keyPath)
        })
    }

}

protocol KeyPathObserverForCurrentConnectedCameraEventResponder: class {
    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>)
}
