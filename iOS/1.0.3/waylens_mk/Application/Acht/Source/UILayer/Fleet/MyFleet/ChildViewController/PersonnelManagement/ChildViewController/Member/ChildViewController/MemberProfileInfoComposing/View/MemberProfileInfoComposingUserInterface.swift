//
//  MemberProfileInfoComposingUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias MemberProfileInfoComposingUserInterfaceView = MemberProfileInfoComposingUserInterface & UIView

protocol MemberProfileInfoComposingUserInterface {
    func render(memberProfileInfoType: ProfileInfoType)
    func composedMemberProfileInfo(for type: ProfileInfoType) -> ProfileInfoType
    func didAppear()
}
