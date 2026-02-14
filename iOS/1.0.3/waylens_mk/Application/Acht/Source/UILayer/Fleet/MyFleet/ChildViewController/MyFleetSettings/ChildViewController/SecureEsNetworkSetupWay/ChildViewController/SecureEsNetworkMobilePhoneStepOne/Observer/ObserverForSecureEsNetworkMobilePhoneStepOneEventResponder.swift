//
//  ObserverForSecureEsNetworkMobilePhoneStepOneEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForSecureEsNetworkMobilePhoneStepOneEventResponder: class {
    func received(newState: SecureEsNetworkMobilePhoneStepOneViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
