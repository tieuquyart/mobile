//
//  ZoneDate.swift
//  Fleet
//
//  Created by forkon on 2019/10/23.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ZoneDate {
    private static let hourInSeconds: TimeInterval = TimeInterval(60 * 60)
    private static let dayInSeconds: TimeInterval = TimeInterval(24 * ZoneDate.hourInSeconds)

    private var secondsOffset: TimeInterval {
        return TimeInterval(targetTimeZone.secondsFromGMT())
    }

    private var utcDate: Date
    private var targetTimeZone: TimeZone

    /// zero o'clock
    private var dateAtStartOfDay: Date {
        let secondsSince1970 = targetDate.timeIntervalSince1970
        return Date(timeIntervalSince1970: secondsSince1970 - secondsSince1970.truncatingRemainder(dividingBy: ZoneDate.dayInSeconds))
    }

    /// 23:59.59
    private var dateAtEndOfDay: Date {
        return Date(timeIntervalSince1970: dateAtStartOfDay.timeIntervalSince1970 + ZoneDate.dayInSeconds)
    }

    var targetDate: Date {
        let utcSeconds = utcDate.timeIntervalSince1970
        let targetTime = utcSeconds + secondsOffset
        return Date(timeIntervalSince1970: targetTime)
    }

    var utcDateAtStartOfDay: Date {
        return Date(timeIntervalSince1970: dateAtStartOfDay.timeIntervalSince1970 - secondsOffset)
    }

    var utcDateAtEndOfDay: Date {
        return Date(timeIntervalSince1970: dateAtEndOfDay.timeIntervalSince1970 - secondsOffset)
    }

    var utcDateAtStartOfYesterday: Date {
        return Date(timeIntervalSince1970: utcDateAtStartOfDay.timeIntervalSince1970 - ZoneDate.dayInSeconds)
    }

    init(utcDate: Date = Date(), targetTimeZone: TimeZone) {
        self.utcDate = utcDate
        self.targetTimeZone = targetTimeZone
    }

}

extension Date {

    var toFleetTimeZoneDate: ZoneDate {
        return ZoneDate(utcDate: self, targetTimeZone: UserSetting.current.fleetTimeZone)
    }

    var thisDateInFleetTimeZone: Date {
        return Date(timeIntervalSince1970: timeIntervalSince1970 - TimeInterval(UserSetting.current.fleetTimeZone.secondsFromGMT()))
    }

}

extension TimeZone {



}
