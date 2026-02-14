//
//  SecureEsNetworkSetupWayUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias SecureEsNetworkSetupWayUserInterfaceView = SecureEsNetworkSetupWayUserInterface & UIView

protocol SecureEsNetworkSetupWayUserInterface {
    func render(newState: SecureEsNetworkSetupWayViewControllerState)
}
