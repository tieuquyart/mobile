//
//  RoleItemModel.swift
//  Acht
//
//  Created by TranHoangThanh on 1/27/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation

struct RoleItemModel: Codable {
    var isCheck : Bool = false
    let id: Int
    let roleName: String
    let description: String
  //  let createUserId: Int
    let createTime: String
    let updateTime: String

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case roleName = "roleName"
        case description = "description"
    //    case createUserId = "createUserId"
        case createTime = "createTime"
        case updateTime = "updateTime"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        roleName = try values.decode(String.self, forKey: .roleName)
        description = try values.decode(String.self, forKey: .description)
      //  createUserId = try values.decode(Int.self, forKey: .createUserId)
        createTime = try values.decode(String.self, forKey: .createTime)
        updateTime = try values.decode(String.self, forKey: .updateTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(roleName, forKey: .roleName)
        try container.encode(description, forKey: .description)
        // try container.encode(createUserId, forKey: .createUserId)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
    }

}
