//
//  ObserverForBillingDetailEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForBillingDetailEventResponder: class {
    func received(newState: BillingDetailViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
