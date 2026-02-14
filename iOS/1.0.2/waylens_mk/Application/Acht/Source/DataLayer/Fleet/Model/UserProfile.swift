//
//  UserProfile.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
//
//public struct UserProfile: Equatable, Codable {
//    public let userID: Int
//    public let name: String
//    public let roles: UserRoles
//    public let email: String
//    public let fleetName: String
//    public let avatarURL: URL?
//    public let createTime: Date
//    public let timeZone: TimeZone
//    public let isVerified: Bool
//    public var isOwner: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case userID = "id"
//        case name = "userName"
//        case roles
//        case email
//        case fleetName
//        case avatarURL = "logoUrl"
//        case createTime
//        case timeZone = "tzDatabase"
//        case isVerified
//        case isOwner
//    }
//
//    enum UserProfileCodingError: Error {
//        case decoding(String)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//    //    self.userID = (try? values.decode(String.self, forKey: .userID)) ?? "\(UUID())"
//        userID = try values.decode(Int.self, forKey: .userID)
//
//        guard let name = try? values.decode(String.self, forKey: .name) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.name = name
//
//        if let roleArray = try? values.decode([String].self, forKey: .roles) {
//            self.roles = UserRoles(stringValues: roleArray)
//        } else {
//            guard let roles = try? values.decode(UserRoles.self, forKey: .roles) else {
//                throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//            }
//
//            self.roles = roles
//        }
//
//        guard let email = try? values.decode(String.self, forKey: .email) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.email = email
//
//        guard let fleetName = try? values.decode(String.self, forKey: .fleetName) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.fleetName = fleetName
//
//        guard let avatarURL = try? values.decode(String.self, forKey: .avatarURL) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.avatarURL = URL(string: avatarURL)
//
//        guard let createTime = try? values.decode(Int64.self, forKey: .createTime) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.createTime = Date(millisecondsSince1970: TimeInterval(createTime))
//
//        guard let timeZoneIdentifier = try? values.decode(String.self, forKey: .timeZone) else {
//            throw UserProfileCodingError.decoding("Whoops! \(dump(values))")
//        }
//
//        self.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
//
//        self.isOwner = (try? values.decode(Bool.self, forKey: .isOwner)) ?? false
//        self.isVerified = (try? values.decode(Bool.self, forKey: .isVerified)) ?? false
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(roles, forKey: .roles)
//        try container.encode(email, forKey: .email)
//        try container.encode(fleetName, forKey: .fleetName)
//        try container.encode(avatarURL?.absoluteString ?? "", forKey: .avatarURL)
//        try container.encode(createTime.millisecondsSince1970, forKey: .createTime)
//        try container.encode(timeZone.identifier, forKey: .timeZone)
//        try container.encode(isVerified, forKey: .isVerified)
//        try container.encode(isOwner, forKey: .isOwner)
//    }
//
//}


//public struct UserProfile: Codable , Equatable {
//
//    let id: Int
//    let avatar: String
//    let userName: String
//    let realName: String
//    let token: String
//    let fleetName : String
// //   let twoStepEnabled: Bool
////    let lastLogin: String
////    let lastFaultyLogin: String
////    let createTime: String
////    let updateTime: String
////    let roleIds: [Int]
////    let roleIdString: String
//    let roleNames: [String]
//   // let roles: UserRoles = UserRoles(stringValues: ["String"])
//    let isVerified: Bool = true
//    public let createTime: Date = Date()
//    public var isOwner: Bool = true
//
//    func get_role() -> String {
//        if roleNames.isEmpty {
//            return ""
//        } else {
//            let joined = roleNames.joined(separator: ", ")
//            return joined
//        }
//    }
//
//    enum UserProfileCodingError: Error {
//            case decoding(String)
//        }
//    //
//    private enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case avatar = "avatar"
//        case userName = "userName"
//        case realName = "realName"
//        case token = "token"
////        case twoStepEnabled = "twoStepEnabled"
////        case lastLogin = "lastLogin"
////        case lastFaultyLogin = "lastFaultyLogin"
////        case createTime = "createTime"
////        case updateTime = "updateTime"
////        case roleIds = "roleIds"
//        case roleIdString = "roleIdString"
//        case roleNames = "roleNames"
//
//    }
//
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decode(Int.self, forKey: .id)
//        avatar = try values.decode(String.self, forKey: .avatar)
//        userName = try values.decode(String.self, forKey: .userName)
//        realName = try values.decode(String.self, forKey: .realName)
//        token = try values.decode(String.self, forKey: .token)
////        twoStepEnabled = try values.decode(Bool.self, forKey: .twoStepEnabled)
//////        lastLogin = try values.decode(String.self, forKey: .lastLogin)
//////        lastFaultyLogin = try values.decode(String.self, forKey: .lastFaultyLogin)
////        createTime = try values.decode(String.self, forKey: .createTime)
////        updateTime = try values.decode(String.self, forKey: .updateTime)
////        roleIds = try values.decode([Int].self, forKey: .roleIds)
//     //  roleIdString = try values.decode(String.self, forKey: .roleIdString)
//        roleNames = try values.decode([String].self, forKey: .roleNames)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(avatar, forKey: .avatar)
//        try container.encode(userName, forKey: .userName)
//        try container.encode(realName, forKey: .realName)
//        try container.encode(token, forKey: .token)
// //       try container.encode(twoStepEnabled, forKey: .twoStepEnabled)
////        try container.encode(lastLogin, forKey: .lastLogin)
////        try container.encode(lastFaultyLogin, forKey: .lastFaultyLogin)
////        try container.encode(createTime, forKey: .createTime)
////        try container.encode(updateTime, forKey: .updateTime)
////        try container.encode(roleIds, forKey: .roleIds)
////        try container.encode(roleIdString, forKey: .roleIdString)
//       try container.encode(roleNames, forKey: .roleNames)
//
//    }
//
//}

import Foundation

public struct UserProfile: Codable , Equatable {

    let id: Int?
    let avatar: String?
    let userName: String?
    let realName: String?
    let token: String?
    let twoStepEnabled: Bool?
    let lastLogin: String?
    let lastFaultyLogin: String?
    let userType: String?
    let createTime: String?
    let updateTime: String?
    let fleetId: Int?
    let fleetName: String?
    let subscribed: Int?
    let roleIds: [Int]?
    let roleIdString: String?
    let roleNames: [String]?
    public var isVerified: Bool = true
    public var isOwner: Bool = true
    func get_role() -> String {
           if roleNames.isEmpty {
               return ""
           } else {
               let joined = roleNames!.joined(separator: ", ")
               return joined
           }
       }
        
    func isVip() -> Bool {
        if subscribed == 1 {
            return true
        } else {
            return false
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar = "avatar"
        case userName = "userName"
        case realName = "realName"
        case token = "token"
        case twoStepEnabled = "twoStepEnabled"
        case lastLogin = "lastLogin"
        case lastFaultyLogin = "lastFaultyLogin"
        case userType = "userType"
        case createTime = "createTime"
        case updateTime = "updateTime"
        case fleetId = "fleetId"
        case fleetName = "fleetName"
        case subscribed = "subscribed"
        case roleIds = "roleIds"
        case roleIdString = "roleIdString"
        case roleNames = "roleNames"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int?.self, forKey: .id)
        avatar = try values.decode(String?.self, forKey: .avatar)
        userName = try values.decode(String?.self, forKey: .userName)
        realName = try values.decode(String?.self, forKey: .realName)
        token = try values.decode(String?.self, forKey: .token)
        twoStepEnabled = try values.decode(Bool?.self, forKey: .twoStepEnabled)
        lastLogin = try values.decode(String?.self, forKey: .lastLogin)
        lastFaultyLogin = try values.decode(String?.self, forKey: .lastFaultyLogin)
        userType = try values.decode(String?.self, forKey: .userType)
        createTime = try values.decode(String?.self, forKey: .createTime)
        updateTime = try values.decode(String?.self, forKey: .updateTime)
        fleetId = try values.decode(Int?.self, forKey: .fleetId)
        fleetName = try values.decode(String?.self, forKey: .fleetName)
        subscribed = try values.decode(Int?.self, forKey: .subscribed)
        roleIds = try values.decode([Int]?.self, forKey: .roleIds)
        roleIdString = try values.decode(String?.self, forKey: .roleIdString)
        roleNames = try values.decode([String]?.self, forKey: .roleNames)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(userName, forKey: .userName)
        try container.encode(realName, forKey: .realName)
        try container.encode(token, forKey: .token)
        try container.encode(twoStepEnabled, forKey: .twoStepEnabled)
        try container.encode(lastLogin, forKey: .lastLogin)
        try container.encode(lastFaultyLogin, forKey: .lastFaultyLogin)
        try container.encode(userType, forKey: .userType)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
        try container.encode(fleetId, forKey: .fleetId)
        try container.encode(fleetName, forKey: .fleetName)
        try container.encode(subscribed, forKey: .subscribed)
        try container.encode(roleIds, forKey: .roleIds)
        try container.encode(roleIdString, forKey: .roleIdString)
        try container.encode(roleNames, forKey: .roleNames)
    }

}

import Foundation

struct UserMK: Codable , Equatable {

    let id: Int
    let avatar: String
    let userName: String
    let realName: String
    let token: String
    let twoStepEnabled: Bool
    let lastLogin: String
    let lastFaultyLogin: String
    let createTime: String
    let updateTime: String
    let roleIds: [Int]
    let roleIdString: String
    let roleNames: [String]

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar = "avatar"
        case userName = "userName"
        case realName = "realName"
        case token = "token"
        case twoStepEnabled = "twoStepEnabled"
        case lastLogin = "lastLogin"
        case lastFaultyLogin = "lastFaultyLogin"
        case createTime = "createTime"
        case updateTime = "updateTime"
        case roleIds = "roleIds"
        case roleIdString = "roleIdString"
        case roleNames = "roleNames"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        avatar = try values.decode(String.self, forKey: .avatar)
        userName = try values.decode(String.self, forKey: .userName)
        realName = try values.decode(String.self, forKey: .realName)
        token = try values.decode(String.self, forKey: .token)
        twoStepEnabled = try values.decode(Bool.self, forKey: .twoStepEnabled)
        lastLogin = try values.decode(String.self, forKey: .lastLogin)
        lastFaultyLogin = try values.decode(String.self, forKey: .lastFaultyLogin)
        createTime = try values.decode(String.self, forKey: .createTime)
        updateTime = try values.decode(String.self, forKey: .updateTime)
        roleIds = try values.decode([Int].self, forKey: .roleIds)
        roleIdString = try values.decode(String.self, forKey: .roleIdString)
        roleNames = try values.decode([String].self, forKey: .roleNames)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(userName, forKey: .userName)
        try container.encode(realName, forKey: .realName)
        try container.encode(token, forKey: .token)
        try container.encode(twoStepEnabled, forKey: .twoStepEnabled)
        try container.encode(lastLogin, forKey: .lastLogin)
        try container.encode(lastFaultyLogin, forKey: .lastFaultyLogin)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
        try container.encode(roleIds, forKey: .roleIds)
        try container.encode(roleIdString, forKey: .roleIdString)
        try container.encode(roleNames, forKey: .roleNames)
    }

}

