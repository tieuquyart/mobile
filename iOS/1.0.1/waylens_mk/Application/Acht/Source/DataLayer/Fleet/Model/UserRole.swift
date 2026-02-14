//
//  UserRole.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public struct UserRoles: OptionSet, Codable {
    public typealias RawValue = Int

    public var rawValue: Int

    public init(rawValue: UserRole.RawValue) {
        self.rawValue = rawValue
    }

    public static let owner = UserRole(rawValue: 1 << 0)
    public static let manager = UserRole(rawValue: 1 << 1)
    public static let driver = UserRole(rawValue: 1 << 2)
}
