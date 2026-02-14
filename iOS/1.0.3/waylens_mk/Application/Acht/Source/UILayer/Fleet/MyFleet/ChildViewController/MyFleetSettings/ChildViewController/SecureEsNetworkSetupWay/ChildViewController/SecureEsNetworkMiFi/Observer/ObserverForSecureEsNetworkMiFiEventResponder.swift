//
//  ObserverForSecureEsNetworkMiFiEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForSecureEsNetworkMiFiEventResponder: class {
    func received(newState: SecureEsNetworkMiFiViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
