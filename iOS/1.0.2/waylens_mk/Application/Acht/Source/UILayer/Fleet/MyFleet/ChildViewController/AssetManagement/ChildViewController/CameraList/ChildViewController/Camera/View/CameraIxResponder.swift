//
//  CameraIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol CameraIxResponder: class {
    func gotoSetup()
    func activateCamera()
    func removeCamera()
    func didTapFirmwareVersionRow()
//    func removeAndDeactivateCamera()
}
