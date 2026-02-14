//
//  CameraModel.swift
//  Acht
//
//  Created by TranHoangThanh on 1/21/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation


struct CameraModel: Codable {

    let id: Int
    let sn: String
    let password: String
    let ssid: String
    let fccid: String
    let outerId: Int
    let groupId: String
    let hardwareModel: String
    let hardwareVersion: String
    let status: Int
    var phone: String?
    let createTime: String
    let updateTime: String

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case sn = "sn"
        case password = "password"
        case ssid = "ssid"
        case fccid = "fccid"
        case outerId = "outerId"
        case groupId = "groupId"
        case hardwareModel = "hardwareModel"
        case hardwareVersion = "hardwareVersion"
        case status = "status"
        case phone = "phone"
        case createTime = "createTime"
        case updateTime = "updateTime"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sn = try values.decode(String.self, forKey: .sn)
        password = try values.decode(String.self, forKey: .password)
        ssid = try values.decode(String.self, forKey: .ssid)
        fccid = try values.decode(String.self, forKey: .fccid)
        outerId = try values.decode(Int.self, forKey: .outerId)
        groupId = try values.decode(String.self, forKey: .groupId)
        hardwareModel = try values.decode(String.self, forKey: .hardwareModel)
        hardwareVersion = try values.decode(String.self, forKey: .hardwareVersion)
        status = try values.decode(Int.self, forKey: .status)
        phone = try values.decode(String?.self, forKey: .phone)
        createTime = try values.decode(String.self, forKey: .createTime)
        updateTime = try values.decode(String.self, forKey: .updateTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sn, forKey: .sn)
        try container.encode(password, forKey: .password)
        try container.encode(ssid, forKey: .ssid)
        try container.encode(fccid, forKey: .fccid)
        try container.encode(outerId, forKey: .outerId)
        try container.encode(groupId, forKey: .groupId)
        try container.encode(hardwareModel, forKey: .hardwareModel)
        try container.encode(hardwareVersion, forKey: .hardwareVersion)
        try container.encode(status, forKey: .status)
        try container.encode(phone, forKey: .phone)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
    }

}
