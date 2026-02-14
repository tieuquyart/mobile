//
//  DateRange.swift
//  Fleet
//
//  Created by forkon on 2019/10/23.
//  Copyright © 2019 waylens. All rights reserved.
//

public class DateRange {
    private static let dayInSeconds: TimeInterval = 60 * 60 * 24

    public var from: Date
    public var to: Date

    required public init(from: Date, to: Date) {
        if from > to {
            fatalError("Params error when init DataChange.")
        }

        self.from = from
        self.to = to
    }

}

extension DateRange {

    static var rangeUsingInOverview: DateRange {
//        #if DEBUG
//        let from = Date().adjust(.day, offset: -15)
//        #else
//        let from = ZoneDate(targetTimeZone: UserSetting.current.fleetTimeZone).utcDateAtStartOfYesterday
//        #endif
        let from = Date().adjust(.day, offset: -15)
        let to = ZoneDate(targetTimeZone: UserSetting.current.fleetTimeZone).utcDateAtEndOfDay
//
        return DateRange(from: from, to: to)
     //  return DateRange(from: Date().adjust(.day, offset: -15), to: Date())
    }

    static var rangeUsingInNotificationList: DateRange {
        let to = Date().dateManager.fleetDate
        let from = to.dateByAdding(-2, .day)
        return DateRange(from: from.date, to: to.date)
    }

    static func pastDays(_ number: Int) -> DateRange {
        assert(number > 1, "Number of days must bigger than 1.")
        return DateRange(from: Date().adjust(.day, offset: -(number - 1)), to: Date())
    }

}

extension DateRange: CustomStringConvertible {

    public var description: String {
        return String(format: NSLocalizedString("xx to xx", comment: "%@ to %@"), from.dateManager.fleetDate.toString(.custom("yyyy-MM-dd")), to.dateManager.fleetDate.toString(.custom("yyyy-MM-dd")))
    }

}

extension DateRange: Equatable {

    public static func == (lhs: DateRange, rhs: DateRange) -> Bool {
        return (lhs.from == rhs.from) && (lhs.to == rhs.to)
    }

}
