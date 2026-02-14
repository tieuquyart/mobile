//
//  ObserverForNotificationListEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForNotificationListEventResponder: class {
    func received(newState: NotificationListViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
