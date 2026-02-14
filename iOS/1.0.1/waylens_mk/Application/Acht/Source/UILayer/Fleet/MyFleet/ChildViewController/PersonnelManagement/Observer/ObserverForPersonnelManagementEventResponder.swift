//
//  ObserverForPersonnelManagementEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForPersonnelManagementEventResponder: class {
    func received(newState: PersonnelManagementViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
