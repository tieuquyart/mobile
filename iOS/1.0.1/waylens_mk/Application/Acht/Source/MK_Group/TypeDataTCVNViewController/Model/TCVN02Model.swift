//
//  TCVN02Model.swift
//  Acht
//
//  Created by TranHoangThanh on 4/1/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation


struct TCVN02ModelDict {

    let drvName: String?
    let licenseId: String?
    let startTime: String?
    let startGPS: String?
    let finishTime: String?
    let finishGPS: String?

    init(_ dict: [String: Any]) {
        
        drvName = dict["drv_name"] as? String
        licenseId = dict["license_id"] as? String
        startTime = dict["start_time"] as? String
        startGPS = dict["start_GPS"] as? String
        finishTime = dict["finish_time"] as? String
        finishGPS = dict["finish_GPS"] as? String
        
        
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["drv_name"] = drvName
        jsonDict["license_id"] = licenseId
        jsonDict["start_time"] = startTime
        jsonDict["start_GPS"] = startGPS
        jsonDict["finish_time"] = finishTime
        jsonDict["finish_GPS"] = finishGPS
        return jsonDict
    }

}

struct TCVN02Model: Codable {

    let drvName: String
    let licenseId: String
    let startTime: String
    let startGPS: String
    let finishTime: String
    let finishGPS: String

    private enum CodingKeys: String, CodingKey {
        case drvName = "drv_name"
        case licenseId = "license_id"
        case startTime = "start_time"
        case startGPS = "start_GPS"
        case finishTime = "finish_time"
        case finishGPS = "finish_GPS"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        drvName = try values.decode(String.self, forKey: .drvName)
        licenseId = try values.decode(String.self, forKey: .licenseId)
        startTime = try values.decode(String.self, forKey: .startTime)
        startGPS = try values.decode(String.self, forKey: .startGPS)
        finishTime = try values.decode(String.self, forKey: .finishTime)
        finishGPS = try values.decode(String.self, forKey: .finishGPS)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drvName, forKey: .drvName)
        try container.encode(licenseId, forKey: .licenseId)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(startGPS, forKey: .startGPS)
        try container.encode(finishTime, forKey: .finishTime)
        try container.encode(finishGPS, forKey: .finishGPS)
    }

}
