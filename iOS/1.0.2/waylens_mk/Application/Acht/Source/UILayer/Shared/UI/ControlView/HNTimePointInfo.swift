//
//  HNTimePointInfo.swift
//  Acht
//
//  Created by forkon on 2018/9/12.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

struct HNTimePointInfo {
    var dateString: String
    var timeString: String
    var locationString: String?
    
    init(date: Date, clip: HNClip? = nil) {
        dateString = date.toHumanizedDateString()
        timeString = date.toString(format: .timeSec12)

        if let clip = clip, let location = clip.location {
            if clip.videoType.isParking {
                locationString = location.address?.street
            } else {
                if location.horizontalAccuracy < 99 {
                    locationString = location.address?.street
                } else {
                    locationString = location.address?.region
                }
            }
        } else {
            locationString = nil
        }
    }

}
