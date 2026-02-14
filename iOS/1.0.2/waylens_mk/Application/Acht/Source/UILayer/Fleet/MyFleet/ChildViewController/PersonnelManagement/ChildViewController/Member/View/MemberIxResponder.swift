//
//  MemberIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol MemberIxResponder: class {
    func beginComposeProfileInfo(_ infoType: ProfileInfoType)
    func saveMember()
    func removeMember()
    func setAsFleetOwner()
}
