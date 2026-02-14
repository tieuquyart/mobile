//
//  DateManager.swift
//  Acht
//
//  Created by forkon on 2019/11/5.
//  Copyright © 2019 waylens. All rights reserved.
//

import SwiftDate

struct DateManager {
    static var fleetTimeZone: TimeZone {
        return UserSetting.current.fleetTimeZone
    }

    private let date: Date

    var fleetDate: DateInRegion {
        let region = Region(calendar: Calendars.gregorian, zone: DateManager.fleetTimeZone)
        let theDate = DateInRegion(date, region: region)
        return theDate
    }

    init(_ date: Date) {
        self.date = date
    }

    static func allDatesWithDifferentDay(in range: DateRange) -> [Date] {
        let increment = DateComponents.create {
            $0.day = 1
        }

        let dates = Date.enumerateDates(from: range.from, to: range.to, increment: increment).map{$0.date}

        return dates
    }
}

protocol DateManagerPropertyProtocol {
    var dateManager: DateManager { get set }
}

extension DateManagerPropertyProtocol where Self == Date {

    var dateManager: DateManager {
        get {
            return DateManager(self)
        }
        set {
            // this enables using CameraFeatureAvailability to "mutate" camera object
        }
    }

}

extension Date: DateManagerPropertyProtocol {}

extension DateInRegion {

    func toStringUsingInNotificationList() -> String {
        if isToday {
            return toFormat(NSLocalizedString("h:mm a", comment: "Date Format"))
        }
        else if compare(.isThisYear) {
            return toFormat(NSLocalizedString("h:mm a", comment: "Date Format") + " " + NSLocalizedString("MMM d", comment: "Date Format"))
        }
        else {
            return toFormat(NSLocalizedString("h:mm a", comment: "Date Format") + " " + NSLocalizedString("MMM d, yyyy", comment: "Date Format"))
        }
    }

}
