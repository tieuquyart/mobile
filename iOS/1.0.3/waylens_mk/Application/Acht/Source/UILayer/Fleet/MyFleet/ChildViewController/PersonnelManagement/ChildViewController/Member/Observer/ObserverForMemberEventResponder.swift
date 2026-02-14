//
//  ObserverForMemberEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForMemberEventResponder: class {
    func received(newState: MemberViewControllerState)
    func received(newErrorMessage: ErrorMessage)
//    func received(newMemberProfile: MemberProfile)
//    func received(newViewState viewState: MemberViewState)
}
