//
//  DriverTimelineEvent.swift
//  Fleet
//
//  Created by forkon on 2019/10/24.
//  Copyright © 2019 waylens. All rights reserved.
//

public typealias DriverTimelineEventGroup = [(Date, [DriverTimelineEvent])]

public protocol DriverTimelineEventContentProtocol: Decodable {
    associatedtype ContentType
}

public enum DriverTimelineEventType: String, Decodable {
    case cameraEvent = "CameraEvent"
    case ignitionStatus = "IgnitionStatus"
    case geoFence = "GeoFence"
}

public struct DriverTimelineCameraEventContent: DriverTimelineEventContentProtocol {
    public typealias ContentType = DriverTimelineCameraEventContent

    let eventType: EventType
    let clipID: String
    let country: String
    let region: String
    let city: String
    let route: String
    let streetNumber: String
    let address: String
//    let duration: TimeInterval
}

public enum DriverTimelineIgnitionStatus: String, Decodable, CustomStringConvertible {
    case driving = "driving"
    case parking = "parking"

    public var color: UIColor {
        switch self {
        case .driving:
            return UIColor.semanticColor(.tint(.primary))
        case .parking:
            return UIColor.semanticColor(.parkingStatus)
        }
    }

    public var description: String {
        switch self {
        case .driving:
            return NSLocalizedString("Went into driving mode", comment: "Went into driving mode")
        case .parking:
            return NSLocalizedString("Went into parking mode", comment: "Went into parking mode")
        }
    }
}

public struct DriverTimelineIgnitionStatusContent: DriverTimelineEventContentProtocol {
    public typealias ContentType = DriverTimelineIgnitionStatusContent

    let tripID: String
    let ignitionStatus: DriverTimelineIgnitionStatus
}

public struct DriverTimelineGeoFenceEventContent: DriverTimelineEventContentProtocol {
    public typealias ContentType = DriverTimelineGeoFenceEventContent

    let geoFenceEventID: String
    let geoFenceRuleID: String
    let geoFenceTriggerType: GeoFenceRuleTypes
    let geoFenceRuleName: String
}

public class DriverTimelineEvent: Decodable {
    let notificationID: String?
    let time: Date
    let type: DriverTimelineEventType
    let plateNumber: String
    let driverName: String
    let driverID: String?
    let receiveTime: Date?
    let isRead: Bool
    let content: Any

    private enum CodingKeys: String, CodingKey {
        case time = "timelineTime"
        case type = "timelineType"
        //// using in notification list ////
        case notificationID
        case notificationTime
        case notificationType
        case driverID
        case receiveTime
        case isRead
        //// using in notification list ////
        case event
        case ignition
        case geoFenceEvent
        case plateNumber
        case driverName
    }

    enum DriverTimelineEventCodingError: Error {
        case decoding(String)
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        var timeKey: CodingKeys

        if values.contains(.time) {
            timeKey = .time
        } else {
            timeKey = .notificationTime
        }

        guard let rawTime = try? values.decode(Int64.self, forKey: timeKey) else {
            throw DriverTimelineEventCodingError.decoding("Whoops! \(dump(values))")
        }

        self.time = Date(timeIntervalSince1970: TimeInterval(rawTime) / 1000)

        var typeKey: CodingKeys

        if values.contains(.type) {
            typeKey = .type
        } else {
            typeKey = .notificationType
        }

        guard let type = try? values.decode(DriverTimelineEventType.self, forKey: typeKey) else {
            throw DriverTimelineEventCodingError.decoding("Whoops! \(dump(values))")
        }

        self.type = type

        switch self.type {
        case .cameraEvent:
            if let content = try? values.decode(DriverTimelineCameraEventContent.self, forKey: .event) {
                self.content = content
            } else {
                throw DriverTimelineEventCodingError.decoding("Whoops! \(dump(values))")
            }
        case .ignitionStatus:
            if let content = try? values.decode(DriverTimelineIgnitionStatusContent.self, forKey: .ignition) {
                self.content = content
            } else {
                throw DriverTimelineEventCodingError.decoding("Whoops! \(dump(values))")
            }
        case .geoFence:
            if let content = try? values.decode(DriverTimelineGeoFenceEventContent.self, forKey: .geoFenceEvent) {
                self.content = content
            } else {
                throw DriverTimelineEventCodingError.decoding("Whoops! \(dump(values))")
            }
        }

        self.plateNumber = (try? values.decode(String.self, forKey: .plateNumber)) ?? ""
        self.driverName = (try? values.decode(String.self, forKey: .driverName)) ?? ""

        if values.contains(.driverID) {
            self.driverID = try? values.decode(String.self, forKey: .driverID)
        } else {
            self.driverID = nil
        }

        if values.contains(.receiveTime), let receiveTimeInterval = try? values.decode(TimeInterval.self, forKey: .receiveTime) {
            self.receiveTime = Date(timeIntervalSince1970: TimeInterval(receiveTimeInterval) / 1000)
        } else {
            self.receiveTime = nil
        }

        if values.contains(.notificationID), let notificationID = try? values.decode(String.self, forKey: .notificationID) {
            self.notificationID = notificationID
        } else {
            self.notificationID = nil
        }

        if values.contains(.isRead), let isRead = try? values.decode(Bool.self, forKey: .isRead) {
            self.isRead = isRead
        } else {
            self.isRead = false
        }

    }

}
