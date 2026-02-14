//
//  MemberProfile.swift
//  Fleet
//
//  Created by forkon on 2019/11/6.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public typealias FleetMember = MemberProfile



public struct MemberProfile: Equatable, Codable {
    public var name: String = ""
    public var roles: UserRoles = UserRoles(stringValues: ["String"])
    public var email: String? = nil
    public var phoneNumber: String? = nil
    public var isVerified: Bool = false
    public var isOwner: Bool = false
    public var isBind: Bool = false
    public var driverID: String? = nil
    
    var id: Int? = nil
    var avatar: String? = nil
    
 //   let twoStepEnabled: Bool
//    let lastLogin: String
//    let lastFaultyLogin: String
//    let createTime: String
//    let updateTime: String
//    let roleIds: [Int]
//    let roleIdString: String
    var roleNames: [String] = []
    public var realName: String = ""
    public let createTime: Date = Date()
  
    func get_role() -> String {
        if roleNames.isEmpty {
            return ""
        } else {
            let joined = roleNames.joined(separator: ", ")
            return joined
        }
    }
    
    func get_userName() -> String {
        return name
    }
    
    func get_id() -> Int {
        return id ?? 0
    }
    
    mutating func set_userName(_ value : String)  {
        self.name = value
    }
    
    mutating func set_Name(_ value : String)  {
        self.realName = value
    }
    
    func getName() -> String {
        return realName
    }

    enum CodingKeys: String, CodingKey {
        case name = "userName"
        case id = "id"
        case avatar = "avatar"
        case realName = "realName"
        case token = "token"
//        case twoStepEnabled = "twoStepEnabled"
//        case lastLogin = "lastLogin"
//        case lastFaultyLogin = "lastFaultyLogin"
//        case createTime = "createTime"
//        case updateTime = "updateTime"
//        case roleIds = "roleIds"
        case roleIdString = "roleIdString"
        case roleNames = "roleNames"
    }


    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        avatar = try values.decode(String.self, forKey: .avatar)
        name = try values.decode(String.self, forKey: .name)
        realName = try values.decode(String.self, forKey: .realName)
        
//        twoStepEnabled = try values.decode(Bool.self, forKey: .twoStepEnabled)
////        lastLogin = try values.decode(String.self, forKey: .lastLogin)
////        lastFaultyLogin = try values.decode(String.self, forKey: .lastFaultyLogin)
//        createTime = try values.decode(String.self, forKey: .createTime)
//        updateTime = try values.decode(String.self, forKey: .updateTime)
//        roleIds = try values.decode([Int].self, forKey: .roleIds)
     //  roleIdString = try values.decode(String.self, forKey: .roleIdString)
       
        roleNames = try values.decode([String].self, forKey: .roleNames)
    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(name, forKey: .name)
        try container.encode(realName, forKey: .realName)
        
 //       try container.encode(twoStepEnabled, forKey: .twoStepEnabled)
//        try container.encode(lastLogin, forKey: .lastLogin)
//        try container.encode(lastFaultyLogin, forKey: .lastFaultyLogin)
//        try container.encode(createTime, forKey: .createTime)
//        try container.encode(updateTime, forKey: .updateTime)
//        try container.encode(roleIds, forKey: .roleIds)
//        try container.encode(roleIdString, forKey: .roleIdString)
       try container.encode(roleNames, forKey: .roleNames)
       
    }
    
    init(
        name: String,
        roles: UserRoles,
        email: String? = nil,
        phoneNumber: String? = nil,
        isVerified: Bool = false,
        isOwner: Bool = false,
        driverID: String? = nil
        ) {
        self.name = name
        self.roles = roles
        self.phoneNumber = phoneNumber
        self.isVerified = isVerified
        self.isOwner = isOwner
        self.driverID = driverID
    }


}
