//
//  LocalNetworkPermission.swift
//  Acht
//
//  Created by forkon on 2020/10/9.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

class LocalNetworkPermission: NSObject {
    typealias PermissionBlock = (_ granted: Bool) -> Void

    private var timer: Timer? = nil
    private var responseBlock: PermissionBlock

    private struct Dependencies {
        let cameraManager = WLBonjourCameraListManager.shared
        var currentCamera: WLCameraDevice? {
            return WLBonjourCameraListManager.shared.currentCamera
        }
        var currentWifi: String? {
            return cameraManager.currentWiFi
        }
    }
    private var dependencies = Dependencies()

    init(responseBlock: @escaping PermissionBlock) {
        self.responseBlock = responseBlock
    }

    func check() {
        killTimer()

        if isCameraWiFi(dependencies.currentWifi) {
            fireTimer()
        }

        dependencies.cameraManager.add(delegate: self)
    }

}

private extension LocalNetworkPermission {

    func isCameraWiFi(_ ssid: String?) -> Bool {
        if ssid?.hasPrefix("Waylens") == true {
            return true
        }
        else {
            return false
        }
    }

    func fireTimer() {
        #if DEBUG
        let timeout: TimeInterval = 20.0
        #else
        let timeout: TimeInterval = 5.0
        #endif

        // A tricky way to check if user allows the app to access local network, maybe there's a better way to achieve this goal.
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { [weak self] (timer) in
            guard let self = self else {
                return
            }

            if self.dependencies.currentCamera == nil {
                self.responseBlock(false)
            }
            else {
                self.responseBlock(true)
            }

            self.killTimer()
        })
    }

    func killTimer() {
        timer?.invalidate()
        timer = nil
    }

}

extension LocalNetworkPermission: WLBonjourCameraListManagerDelegate {

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didChangeNetwork ssid: String?) {
        killTimer()

        if isCameraWiFi(ssid) {
            fireTimer()
        }
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didUpdateCameraList cameraList: [WLCameraDevice]) {

    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didDisconnectCamera camera: WLCameraDevice) {

    }

}
