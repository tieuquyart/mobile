//
//  ObdWorkModeUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias ObdWorkModeUserInterfaceView = ObdWorkModeUserInterface & UIView

protocol ObdWorkModeUserInterface {
    func render(newState: ObdWorkModeViewControllerState)
}
