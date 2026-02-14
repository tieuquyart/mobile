//
//  InstallationUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias InstallationUserInterfaceView = InstallationUserInterface & UIView

protocol InstallationUserInterface {
    func render(newState: InstallationViewControllerState)
}
