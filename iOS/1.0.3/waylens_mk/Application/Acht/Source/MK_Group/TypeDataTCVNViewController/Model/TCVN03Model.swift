//
//  TCVN03Model.swift
//  Acht
//
//  Created by TranHoangThanh on 4/1/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation


struct TCVN03ModelDict {

    let time: String?
    let GPS: String?
    let timeStop: String?

    init(_ dict: [String: Any]) {
        time = dict["time"] as? String
        GPS = dict["GPS"] as? String
        timeStop = dict["time_stop"] as? String
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["time"] = time
        jsonDict["GPS"] = GPS
        jsonDict["time_stop"] = timeStop
        return jsonDict
    }

}



struct TCVN03Model: Codable {

    let time: String
    let GPS: Double
    let timeStop: Int

    private enum CodingKeys: String, CodingKey {
        case time = "time"
        case GPS = "GPS"
        case timeStop = "time_stop"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decode(String.self, forKey: .time)
        GPS = try values.decode(Double.self, forKey: .GPS)
        timeStop = try values.decode(Int.self, forKey: .timeStop)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(GPS, forKey: .GPS)
        try container.encode(timeStop, forKey: .timeStop)
    }

}


