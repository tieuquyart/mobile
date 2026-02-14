//
//  TCVN05ModelDict.swift
//  Acht
//
//  Created by TranHoangThanh on 4/6/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation


struct TCVN05ModelDict  {

    let speed_record_time: String?
    let speed: [Double]?

    init(_ dict: [String: Any]) {
        speed_record_time = dict["speed_record_time"] as? String
        speed = dict["speed"] as? [Double]
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["speed_record_time"] = speed_record_time
        jsonDict["speed"] = speed
        return jsonDict
    }

}
