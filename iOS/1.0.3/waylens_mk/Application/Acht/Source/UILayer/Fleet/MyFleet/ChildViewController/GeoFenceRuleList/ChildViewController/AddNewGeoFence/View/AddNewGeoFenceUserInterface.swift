//
//  AddNewGeoFenceUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias AddNewGeoFenceUserInterfaceView = AddNewGeoFenceUserInterface & UIView

protocol AddNewGeoFenceUserInterface {
    func render(newState: AddNewGeoFenceViewControllerState)
    func beginEditingName()
}
