//
//  AddSsidToCameraUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

class AddSsidToCameraUseCase: NSObject, UseCase {
    let camera: WLCameraDevice?
    let ssid: String
    let password: String
    let actionDispatcher: ActionDispatcher

    private var timeoutWorkItem: DispatchWorkItem?

    deinit {
        print("\(self) deinit")
        NotificationCenter.default.removeObserver(self)
        if WLBonjourCameraListManager.shared.currentCamera?.settingsDelegate === self {
            WLBonjourCameraListManager.shared.currentCamera?.settingsDelegate = nil
        }
    }

    public init(camera: WLCameraDevice?, ssid: String, password: String, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.ssid = ssid
        self.password = password
        self.actionDispatcher = actionDispatcher

        super.init()

        WLBonjourCameraListManager.shared.currentCamera?.settingsDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
    }

    public func start() {
        cancelTimeoutCountdown()

        if let camera = camera {
            actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))
            camera.addHost(ssid, password: password)

            timeoutWorkItem = DispatchWorkItem {
                let message = ErrorMessage(title: NSLocalizedString("Failed to save the SSID and Password. Please try again.", comment: "Failed to save the SSID and Password. Please try again."), message: "")
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
                self.timeoutWorkItem = nil
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0, execute: timeoutWorkItem!)
        }
        else {
            let message = ErrorMessage(title: NSLocalizedString("Please connect to your camera's Wi-Fi.", comment: "Please connect to your camera's Wi-Fi."), message: "")
            actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
        }
    }

    @objc
    private func handleCurrentDeviceDidChangeNotification() {
        WLBonjourCameraListManager.shared.currentCamera?.settingsDelegate = self
    }

    private func cancelTimeoutCountdown() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
    }

}

extension AddSsidToCameraUseCase: WLCameraSettingsDelegate {

    func onSetHotspotInfo(withSsid ssid: String, andPassword password: String) {
        cancelTimeoutCountdown()

        if self.ssid == ssid, self.password == password {
            actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
        }
        else {
            let message = ErrorMessage(title: NSLocalizedString("Failed to save the SSID and Password. Please try again.", comment: "Failed to save the SSID and Password. Please try again."), message: "")
            self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
        }
    }

}

protocol AddSsidToCameraUseCaseFactory {
    func makeAddSsidToCameraUseCase(ssid: String, password: String) -> UseCase
}
