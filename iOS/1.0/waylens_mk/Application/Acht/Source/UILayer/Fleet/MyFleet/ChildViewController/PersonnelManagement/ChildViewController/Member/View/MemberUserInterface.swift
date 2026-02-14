//
//  MemberUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias MemberUserInterfaceView = MemberUserInterface & UIView

protocol MemberUserInterface {
    func render(memberProfile: MemberProfile)
    func render(newState: MemberViewControllerState)
}
