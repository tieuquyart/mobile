//
//  ObserverForRecordConfigEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForRecordConfigEventResponder: class {
    func received(newState: RecordConfigViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
