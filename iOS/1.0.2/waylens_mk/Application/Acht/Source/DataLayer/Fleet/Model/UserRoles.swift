//
//  UserRole.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public struct UserRoles: OptionSet, Codable, Equatable {
    public typealias RawValue = Int
//
    public var rawValue: Int

    public static let admin = UserRoles(rawValue: 1 << 0)
    public static let fleetManager = UserRoles(rawValue: 1 << 1)
    public static let driver = UserRoles(rawValue: 1 << 2)
    public static let installer = UserRoles(rawValue: 1 << 3)
    public static let developer = UserRoles(rawValue: 1 << 4)
    
    
   

    private enum UserRoleString: String {
        case Admin
        case FleetManager
        case Driver
        case Developer
        case Installer
    }

    public var stringArrayValue: [String] {
        var retval: [String] = []

        if self.contains(.admin) {
            retval.append(UserRoleString.Admin.rawValue)
        }

        if self.contains(.fleetManager) {
            retval.append(UserRoleString.FleetManager.rawValue)
        }

        if self.contains(.driver) {
            retval.append(UserRoleString.Driver.rawValue)
        }

        if self.contains(.installer) {
            retval.append(UserRoleString.Installer.rawValue)
        }

        if self.contains(.developer) {
            retval.append(UserRoleString.Developer.rawValue)
        }

        return retval
    }

    public init(rawValue: UserRoles.RawValue) {
        self.rawValue = rawValue
    }

    public init(stringValues: [String]) {
        var roles: UserRoles = UserRoles()
        for stringValue in stringValues {
            switch stringValue {
            case UserRoleString.Admin.rawValue:
                roles = roles.union(.admin)
            case UserRoleString.FleetManager.rawValue:
                roles = roles.union(.fleetManager)
            case UserRoleString.Driver.rawValue:
                roles = roles.union(.driver)
            case UserRoleString.Developer.rawValue:
                roles = roles.union(.developer)
            case UserRoleString.Installer.rawValue:
                roles = roles.union(.installer)
            default:
                continue
            }
        }

        self = roles
    }

}

extension UserRoles: CustomStringConvertible {

    public var description: String {
        var description: [String] = []

        if contains(.admin) {
            description.append(NSLocalizedString("Admin", comment: "User Roles"))
        }

        if contains(.fleetManager) {
            description.append(NSLocalizedString("Manager", comment: "User Roles"))
        }

        if contains(.driver) {
            description.append(NSLocalizedString("Driver", comment: "User Roles"))
        }

        if contains(.developer) {
            description.append(NSLocalizedString("Developer", comment: "User Roles"))
        }

        if contains(.installer) {
            description.append(NSLocalizedString("Installer", comment: "User Roles"))
        }

        return description.joined(separator: ",")
    }

}
