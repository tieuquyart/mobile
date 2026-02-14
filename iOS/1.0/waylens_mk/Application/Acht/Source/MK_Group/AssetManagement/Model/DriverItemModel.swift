//
//  DriverItemModel.swift
//  Acht
//
//  Created by TranHoangThanh on 2/9/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation

struct DriverItemModel: Codable {

    let id: Int?
    let employeeId: String?
    let licenseType: String?
    let license: String?
    let drivingYears: String?
    let name: String?
    let gender: Int?
    let idNumber: String?
    let birthDate : String?
    let phoneNo: String?
    let fleetId : Int?
    let fleetName: String?
    let createTime: String?
    let updateTime: String?
//    let status : Int?
    
    var isAdd = false
    
    init() {
        self.id = nil
        self.employeeId = nil
        self.licenseType = nil
        self.license = nil
        self.drivingYears = nil
        self.name = nil
        self.gender = nil
        self.idNumber = nil
        self.birthDate = nil
        self.phoneNo = nil
        self.fleetId = nil
        self.fleetName = nil
        self.createTime = nil
        self.updateTime = nil
//        self.status = nil
        self.isAdd = true
    }
    
    func getTimeDrivingYear() -> String {
        let drivingYearsArr : [String] = drivingYears!.components(separatedBy: "T")
        return drivingYearsArr[0]
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case employeeId = "employeeId"
        case licenseType = "licenseType"
        case license = "license"
        case drivingYears = "drivingYears"
        case name = "name"
        case gender = "gender"
        case idNumber = "idNumber"
        case birthDate = "birthDate"
        case phoneNo = "phoneNo"
        case fleetId = "fleetId"
        case fleetName = "fleetName"
        case createTime = "createTime"
        case updateTime = "updateTime"
//        case status = "status"
    }
    
    func getGender() -> String {
        if gender == 0 {
            return "Nữ"
        } else {
            return "Nam"
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int?.self, forKey: .id)
        employeeId = try values.decode(String?.self, forKey: .employeeId)
        licenseType = try values.decode(String.self, forKey: .licenseType)
        license = try values.decode(String?.self, forKey: .license)
        drivingYears = try values.decode(String?.self, forKey: .drivingYears)
        name = try values.decode(String?.self, forKey: .name)
        gender = try values.decode(Int?.self, forKey: .gender)
        idNumber = try values.decode(String?.self, forKey: .idNumber)
        birthDate = try values.decode(String?.self, forKey: .birthDate)
        phoneNo = try values.decode(String?.self, forKey: .phoneNo)
        fleetId = try values.decode(Int?.self, forKey: .fleetId)
        fleetName = try values.decode(String?.self, forKey: .fleetName)
        createTime = try values.decode(String?.self, forKey: .createTime)
        updateTime = try values.decode(String?.self, forKey: .updateTime)
//        status = try values.decode(Int?.self, forKey: .status)
        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(employeeId, forKey: .employeeId)
        try container.encode(licenseType, forKey: .licenseType)
        try container.encode(license, forKey: .license)
        try container.encode(drivingYears, forKey: .drivingYears)
        try container.encode(name, forKey: .name)
        try container.encode(gender, forKey: .gender)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(phoneNo, forKey: .phoneNo)
        try container.encode(fleetId, forKey: .fleetId)
        try container.encode(fleetName, forKey: .fleetName)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(updateTime, forKey: .updateTime)
//        try container.encode(status, forKey: .status)
    }

}
