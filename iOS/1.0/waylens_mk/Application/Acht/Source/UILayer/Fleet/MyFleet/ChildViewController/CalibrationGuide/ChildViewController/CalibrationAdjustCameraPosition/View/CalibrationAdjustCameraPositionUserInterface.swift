//
//  CalibrationAdjustCameraPositionUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

typealias CalibrationAdjustCameraPositionUserInterfaceView = CalibrationAdjustCameraPositionUserInterface & UIView

protocol CalibrationAdjustCameraPositionUserInterface {
    func render(newState: CalibrationAdjustCameraPositionViewControllerState)
    func preview(camera: WLCameraDevice?)
    func stopPreview()
    //func screenShort()
}
