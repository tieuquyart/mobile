//
//  ObserverForCurrentConnectedCamera.swift
//  Fleet
//
//  Created by forkon on 2020/8/10.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

class ObserverForCurrentConnectedCamera: Observer {

    weak var eventResponder: ObserverForCurrentConnectedCameraEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
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

private extension ObserverForCurrentConnectedCamera {

    @objc func handleCurrentDeviceDidChangeNotification() {
        eventResponder?.connectedCameraDidChange(WLBonjourCameraListManager.shared.currentCamera)
    }

}
