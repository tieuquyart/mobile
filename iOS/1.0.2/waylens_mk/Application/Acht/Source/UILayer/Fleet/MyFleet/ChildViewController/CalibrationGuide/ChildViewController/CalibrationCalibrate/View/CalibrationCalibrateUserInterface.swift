//
//  CalibrationCalibrateUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

typealias CalibrationCalibrateUserInterfaceView = CalibrationCalibrateUserInterface & UIView

protocol CalibrationCalibrateUserInterface {
    var canCalibrate: Bool { get }
    func render(newState: CalibrationCalibrateViewControllerState)
    func preview(camera: WLCameraDevice?)
    func stopPreview()
}
