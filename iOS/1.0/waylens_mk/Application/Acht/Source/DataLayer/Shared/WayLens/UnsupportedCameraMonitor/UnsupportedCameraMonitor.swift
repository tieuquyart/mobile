//
//  UnsupportedCameraMonitor.swift
//  Acht
//
//  Created by forkon on 2020/5/7.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

protocol UnsupportedCameraMonitor: class {
    var unsupportedCameraClassifier: UnsupportedCameraClassifier { get }
    var unsupportedCameraPrompter: UnsupportedCameraPrompter? { get }
    func checkIfHasConnectedUnsupportedCamera(_ camerasToCheck: [Any])
}

protocol UnsupportedCameraPrompter: class {
    var isPrompting: Bool { get }
    func promptUnsupportedCamera()
    func dismissPrompt()
}

protocol ClassifiableCamera: NSObjectProtocol {
    var model: String? { get }
}

protocol UnsupportedCameraClassifier: class {
    func classifyUnsupportedCameras<CameraType: ClassifiableCamera>(from cameras: [CameraType]) -> [CameraType]
}

extension WLCameraDevice: ClassifiableCamera {

    var model: String? {
        return hardwareModel
    }

}
