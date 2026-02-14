//
//  CalibrationAdjustCameraPositionUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

typealias LoginFaceUserInterfaceView = LoginFaceUserInterface & UIView

protocol LoginFaceUserInterface {
    func render(newState: LoginFaceViewControllerState)
    func preview(camera: WLCameraDevice?)
    func stopPreview()
    func screenShort()
}
