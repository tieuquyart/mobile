//
//  VehicleItemModel.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation

struct VehicleItemModel: Codable {
    
    let id: Int?
    let plateNo: String?
    let vehicleNo: String?
    let type: String?
    let brand: String?
    let capacity: String?
    let cameraId: Int?
    let cameraSn: String? 
    let driverId: Int?
    let driverName: String?
    let driverLicense: String?
    let employeeId: String?
    let createTime: String?
    let updateTime: String?
    
    var isAdd = false
    
    init() {
        self.id = nil
        self.plateNo = nil
        
        self.vehicleNo = nil
        
        self.type = nil
        
        self.brand = nil
        
        self.capacity = nil
        
        self.cameraId = nil
        self.cameraSn = nil
        
        self.driverId = nil
        self.driverName = nil
        
        self.driverLicense = nil
        
        self.employeeId = nil
        
        self.createTime = nil
        
        self.updateTime = nil
        self.isAdd = true
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case plateNo = "plateNo"
        case vehicleNo = "vehicleNo"
        case type = "type"
        case brand = "brand"
        case capacity = "capacity"
        case cameraId = "cameraId"
        case cameraSn = "cameraSn"
        case driverId = "driverId"
        case driverName = "driverName"
        case driverLicense = "driverLicense"
        case employeeId = "employeeId"
        case createTime = "createTime"
        case updateTime = "updateTime"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int?.self, forKey: .id)
        plateNo = try values.decode(String?.self, forKey: .plateNo)
        vehicleNo = try values.decode(String?.self, forKey: .vehicleNo)
        type = try values.decode(String?.self, forKey: .type)
        brand = try values.decode(String?.self, forKey: .brand)
        capacity = try values.decode(String?.self , forKey: .capacity)
        cameraId = try values.decode(Int?.self, forKey: .cameraId)
        cameraSn = try values.decode(String?.self, forKey: .cameraSn)
        driverId = try values.decode(Int?.self, forKey: .driverId)
        driverName = try values.decode(String?.self, forKey: .driverName)
        driverLicense = try values.decode(String?.self, forKey: .driverLicense)
        employeeId = try values.decode(String?.self, forKey: .employeeId)
        createTime = try values.decode(String?.self, forKey: .createTime)
        updateTime = try values.decode(String?.self, forKey: .updateTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(plateNo, forKey: .plateNo)
        try container.encode(vehicleNo, forKey: .vehicleNo)
        try container.encode(type, forKey: .type)
        try container.encode(brand, forKey: .brand)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(cameraId, forKey: .cameraId)
        try container.encode(cameraSn, forKey: .cameraSn)
        try container.encode(driverId, forKey: .driverId)
        try container.encode(driverName, forKey: .driverName)
        try container.encode(driverLicense, forKey: .driverLicense)
        try container.encode(employeeId, forKey: .employeeId)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
    }
    
}
