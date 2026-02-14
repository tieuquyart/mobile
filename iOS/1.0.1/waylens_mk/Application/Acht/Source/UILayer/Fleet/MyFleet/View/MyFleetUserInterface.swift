//
//  MyFleetUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

typealias MyFleetUserInterfaceView = MyFleetUserInterface & UIView

protocol MyFleetUserInterface {
//    func render(newState: MyFleetViewControllerState)
   // func render(userProfile: UserProfile)
    func render(userProfile: UserProfile)
    func render(newCameraConnected: WLCameraDevice?) 
}
