//
//  CalibrationCameraOrientationUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

typealias CalibrationCameraOrientationUserInterfaceView = CalibrationCameraOrientationUserInterface & UIView

protocol CalibrationCameraOrientationUserInterface {
    func render(newState: CalibrationCameraOrientationViewControllerState)
    func preview(camera: WLCameraDevice?)
    func stopPreview()
}
