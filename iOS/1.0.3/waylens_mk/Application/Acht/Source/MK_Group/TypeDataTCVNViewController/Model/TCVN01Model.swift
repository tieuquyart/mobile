//
//  TCVN01Model.swift
//  Acht
//
//  Created by TranHoangThanh on 3/28/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation



struct TCVN01ModelDict {
    var memStt: String?
    var totalMem: String?
    var sigStt: String?
    let sup: String?
    let type: String?
    var sn: String?
    let plateNum: String?
    let spdMethod: Int?
    let pulseCfg: Int?
    let spdLimit: Int?
    let lastModified: String?
    let lastUpdated: String?
    let GPSStt: Int?
    let curDriver: String?
    let contDrvTime: Int?
    let GPSInfo: String?
    let speed: Int?
    let time: String?
    let stopTimeCfg: Int?

    init(_ dict: [String: Any]) {
        sup = dict["sup"] as? String
        type = dict["type"] as? String
        sn = dict["sn"] as? String
        plateNum = dict["plate_num"] as? String
        spdMethod = dict["spd_method"] as? Int
        pulseCfg = dict["pulse_cfg"] as? Int
        spdLimit = dict["spd_limit"] as? Int
        lastModified = dict["last_modified"] as? String
        lastUpdated = dict["last_updated"] as? String
        sigStt = dict["sig_stt"] as? String
        GPSStt = dict["GPS_stt"] as? Int
        memStt = dict["mem_stt"] as? String
        totalMem = dict["total_mem"] as? String
        curDriver = dict["cur_driver"] as? String
        contDrvTime = dict["cont_drv_time"] as? Int
        GPSInfo = dict["GPS_info"] as? String
        speed = dict["speed"] as? Int
        time = dict["time"] as? String
        stopTimeCfg = dict["stop_time_cfg"] as? Int
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["sup"] = sup
        jsonDict["type"] = type
        jsonDict["sn"] = sn
        jsonDict["plate_num"] = plateNum
        jsonDict["spd_method"] = spdMethod
        jsonDict["pulse_cfg"] = pulseCfg
        jsonDict["spd_limit"] = spdLimit
        jsonDict["last_modified"] = lastModified
        jsonDict["last_updated"] = lastUpdated
        jsonDict["sig_stt"] = sigStt
        jsonDict["GPS_stt"] = GPSStt
        jsonDict["mem_stt"] = memStt
        jsonDict["total_mem"] = totalMem
        jsonDict["cur_driver"] = curDriver
        jsonDict["cont_drv_time"] = contDrvTime
        jsonDict["GPS_info"] = GPSInfo
        jsonDict["speed"] = speed
        jsonDict["time"] = time
        jsonDict["stop_time_cfg"] = stopTimeCfg
        return jsonDict
    }

}



struct TCVN01Model: Codable {

    let sup: String
    let type: String
    let sn: String
    let plateNum: String
    let spdMethod: Int
    let pulseCfg: Int
    let spdLimit: Int
    let lastModified: String
    let lastUpdated: String
    let sigStt: Int
    let GPSStt: Int
    let memStt: Int
    let totalMem: Int
    let curDriver: String
    let contDrvTime: Int
    let GPSInfo: String
    let speed: Int
    let time: String
    let stopTimeCfg: Int

    private enum CodingKeys: String, CodingKey {
        case sup = "sup"
        case type = "type"
        case sn = "sn"
        case plateNum = "plate_num"
        case spdMethod = "spd_method"
        case pulseCfg = "pulse_cfg"
        case spdLimit = "spd_limit"
        case lastModified = "last_modified"
        case lastUpdated = "last_updated"
        case sigStt = "sig_stt"
        case GPSStt = "GPS_stt"
        case memStt = "mem_stt"
        case totalMem = "total_mem"
        case curDriver = "cur_driver"
        case contDrvTime = "cont_drv_time"
        case GPSInfo = "GPS_info"
        case speed = "speed"
        case time = "time"
        case stopTimeCfg = "stop_time_cfg"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sup = try values.decode(String.self, forKey: .sup)
        type = try values.decode(String.self, forKey: .type)
        sn = try values.decode(String.self, forKey: .sn)
        plateNum = try values.decode(String.self, forKey: .plateNum)
        spdMethod = try values.decode(Int.self, forKey: .spdMethod)
        pulseCfg = try values.decode(Int.self, forKey: .pulseCfg)
        spdLimit = try values.decode(Int.self, forKey: .spdLimit)
        lastModified = try values.decode(String.self, forKey: .lastModified)
        lastUpdated = try values.decode(String.self, forKey: .lastUpdated)
        sigStt = try values.decode(Int.self, forKey: .sigStt)
        GPSStt = try values.decode(Int.self, forKey: .GPSStt)
        memStt = try values.decode(Int.self, forKey: .memStt)
        totalMem = try values.decode(Int.self, forKey: .totalMem)
        curDriver = try values.decode(String.self, forKey: .curDriver)
        contDrvTime = try values.decode(Int.self, forKey: .contDrvTime)
        GPSInfo = try values.decode(String.self, forKey: .GPSInfo)
        speed = try values.decode(Int.self, forKey: .speed)
        time = try values.decode(String.self, forKey: .time)
        stopTimeCfg = try values.decode(Int.self, forKey: .stopTimeCfg)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sup, forKey: .sup)
        try container.encode(type, forKey: .type)
        try container.encode(sn, forKey: .sn)
        try container.encode(plateNum, forKey: .plateNum)
        try container.encode(spdMethod, forKey: .spdMethod)
        try container.encode(pulseCfg, forKey: .pulseCfg)
        try container.encode(spdLimit, forKey: .spdLimit)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(sigStt, forKey: .sigStt)
        try container.encode(GPSStt, forKey: .GPSStt)
        try container.encode(memStt, forKey: .memStt)
        try container.encode(totalMem, forKey: .totalMem)
        try container.encode(curDriver, forKey: .curDriver)
        try container.encode(contDrvTime, forKey: .contDrvTime)
        try container.encode(GPSInfo, forKey: .GPSInfo)
        try container.encode(speed, forKey: .speed)
        try container.encode(time, forKey: .time)
        try container.encode(stopTimeCfg, forKey: .stopTimeCfg)
    }

}
