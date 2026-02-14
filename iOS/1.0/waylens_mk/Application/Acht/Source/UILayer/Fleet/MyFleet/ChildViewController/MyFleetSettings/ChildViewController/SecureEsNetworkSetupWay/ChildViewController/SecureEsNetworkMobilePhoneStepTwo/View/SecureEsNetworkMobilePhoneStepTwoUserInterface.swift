//
//  SecureEsNetworkMobilePhoneStepTwoUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias SecureEsNetworkMobilePhoneStepTwoUserInterfaceView = SecureEsNetworkMobilePhoneStepTwoUserInterface & UIView

protocol SecureEsNetworkMobilePhoneStepTwoUserInterface {
    func render(newState: SecureEsNetworkMobilePhoneStepTwoViewControllerState)
}
