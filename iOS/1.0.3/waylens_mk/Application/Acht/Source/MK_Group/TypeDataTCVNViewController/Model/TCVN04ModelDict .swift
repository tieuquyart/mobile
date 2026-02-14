//
//  TCVN04ModelDict .swift
//  Acht
//
//  Created by TranHoangThanh on 4/5/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation


struct TCVN04ModelDict  {

    let curTime: String?
    let GPS: String?
    let speed: String?

    init(_ dict: [String: Any]) {
        curTime = dict["cur_time"] as? String
        GPS = dict["GPS"] as? String
        speed = dict["speed"] as? String
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["cur_time"] = curTime
        jsonDict["GPS"] = GPS
        jsonDict["speed"] = speed
        return jsonDict
    }

}
