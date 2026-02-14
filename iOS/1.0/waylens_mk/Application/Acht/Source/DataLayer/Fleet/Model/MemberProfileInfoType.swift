//
//  MemberProfileInfoType.swift
//  Fleet
//
//  Created by forkon on 2019/11/7.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

enum ProfileInfoType {
    case name(String)
    case user_name(String)
    case role(UserRoles)
    case email(String)
    case phoneNumber(String)
    case model(String)
    case plateNumber(String)
    case range(String)
}

extension ProfileInfoType: CustomStringConvertible {

    var description: String {
        switch self {
        case .name:
            return NSLocalizedString("Name", comment: "Name")
        case .user_name:
            return NSLocalizedString("User Name", comment: "User Name")
        case .role:
            return NSLocalizedString("Role", comment: "Role")
        case .email:
            return NSLocalizedString("Email", comment: "Email")
        case .phoneNumber:
            return NSLocalizedString("Phone Number", comment: "Phone Number")
        case .model:
            return NSLocalizedString("Model", comment: "Model")
        case .plateNumber:
            return NSLocalizedString("Plate Number", comment: "Plate Number")
        case .range:
            return NSLocalizedString("Range", comment: "Range")
        }
    }

}
