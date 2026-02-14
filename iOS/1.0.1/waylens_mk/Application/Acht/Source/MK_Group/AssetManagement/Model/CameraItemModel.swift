//
//  CameraItemModel.swift
//  Acht
//
//  Created by TranHoangThanh on 1/24/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import Foundation

struct CameraItemModel: Codable {

    let id: Int?
    let sn: String?
    let password: String?
    let ssid: String?
    let fccid: String?
    var outerId: Int? = 0
    var groupId: String? = ""
    var hardwareModel: String? = ""
    var hardwareVersion: String? = ""
    let status: Int?
    let phone: String?
    let createTime: String?
    let updateTime: String?
    var plateNo : String?
    let installationDate : String?
    let driverName: String?
  //  let cameraType : String?
    var isAdd = false
    
    init() {
        id = nil
        sn = nil
        password = nil
        ssid = nil
        fccid = nil
        outerId = nil
        groupId = nil
        
        hardwareModel = nil
        
        hardwareVersion = nil
        
        status = nil
        phone = nil
        createTime = nil
        updateTime = nil
        plateNo  = nil
        installationDate  = nil
        driverName = nil
        //  let cameraType : String?
        isAdd = true
    }
    
    func getStatus() -> String {
        if status == 2 {
            return "Đã kích hoạt"
        } else if status == 0 {
            return "Đã thêm"
        }else {
            return "Đã đăng kí"
        }
    }

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
        case plateNo = "plateNo"
        case installationDate = "installationDate"
        case driverName = "driverName"
      
       /// case cameraType = "cameraType"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int?.self, forKey: .id)
        sn = try values.decode(String?.self, forKey: .sn)
        password = try values.decode(String?.self, forKey: .password)
        ssid = try values.decode(String?.self, forKey: .ssid)
        fccid = try values.decode(String?.self, forKey: .fccid)
      // outerId = try values.decode(Int.self, forKey: .outerId)
       // groupId = try values.decode(String.self, forKey: .groupId)
       // hardwareModel = try values.decode(String.self, forKey: .hardwareModel)
      //  hardwareVersion = try values.decode(String.self, forKey: .hardwareVersion) 
        status = try values.decode(Int?.self, forKey: .status)
        phone = try values.decode(String?.self, forKey: .phone)
        createTime = try values.decode(String?.self, forKey: .createTime)
        updateTime = try values.decode(String?.self, forKey: .updateTime)
        plateNo = try values.decode(String?.self, forKey: .plateNo)
        installationDate = try values.decode(String?.self, forKey: .installationDate)
        driverName = try values.decode(String?.self, forKey: .driverName)
        //cameraType  = try values.decode(String?.self, forKey: .cameraType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sn, forKey: .sn)
        try container.encode(password, forKey: .password)
        try container.encode(ssid, forKey: .ssid)
        try container.encode(fccid, forKey: .fccid)
    //   try container.encode(outerId, forKey: .outerId)
       // try container.encode(groupId, forKey: .groupId)
        //try container.encode(hardwareModel, forKey: .hardwareModel)
      //  try container.encode(hardwareVersion, forKey: .hardwareVersion)
        try container.encode(status, forKey: .status)
        try container.encode(phone, forKey: .phone)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
        try container.encode(plateNo, forKey: .plateNo)
        try container.encode(installationDate, forKey: .installationDate)
        try container.encode(driverName , forKey: .driverName)
       // try container.encode(cameraType , forKey: .cameraType)
    }

}
