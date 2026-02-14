//
//  HNClip.swift
//  Acht
//
//  Created by Chester Shen on 7/10/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

public enum HNVideoType: Int {
    case buffered = 0
    case manual
    case parkingMotion
    case parkingHit
    case drivingHit
    case parkingHeavy
    case drivingHeavy
    case hardAccel
    case hardBrake
    case sharpTurn
    case harshAccel
    case harshBrake
    case harshTurn
    case severeAccel
    case severeBrake
    case severeTurn
    // dms
    case noDriver = 100
    case drowsiness
    case drinking
    case smoking
    case phoneCalling
    //
    case asleep
    case daydreaming
    case yawn
    case distracted
    case attentive
    case noSeatBelt
    // adas
    case forwardCollisionWarning
    case headwayMonitoringWarning
    case headwayMonitoringEmergency
    case laneDepartureWarning
    //
    case driving
    case parking
    case simchange
    case account_lock
    case account_unlock
    case success
    case failure
    case get_service_status_fail
    
        
    static let allVideoTypes: [HNVideoType] = [.buffered, .manual,
                                               .parkingMotion, .parkingHit, .drivingHit, .parkingHeavy, .drivingHeavy,
                                               .hardAccel, .hardBrake, .sharpTurn,
                                               .harshAccel, .harshBrake, .harshTurn,
                                               .severeAccel, .severeBrake, .severeTurn,
                                               .noDriver, .drowsiness, .drinking, .smoking, .phoneCalling,
                                               .asleep, .daydreaming, .yawn, .distracted, .attentive, .noSeatBelt,
                                               .forwardCollisionWarning, .headwayMonitoringWarning, headwayMonitoringEmergency, laneDepartureWarning, .driving, .parking, .simchange, .account_lock, .account_unlock, .success, .failure, .get_service_status_fail
    ]
    



    static func from(string: String) -> HNVideoType {
        switch string.uppercased() {
        case "DRIVING_HIT":
            return .drivingHit
        case "DRIVING_HEAVY_HIT":
            return .drivingHeavy
        case "PARKING_HIT":
            return .parkingHit
        case "PARKING_HEAVY_HIT":
            return .parkingHeavy
        case "PARKING_MOTION":
            return .parkingMotion
        case "STREAMING":
            return .buffered
        case "HIGHLIGHT":
            return .manual
        case "HARD_ACCEL":
            return .hardAccel
        case "HARD_BRAKE":
            return .hardBrake
        case "SHARP_TURN":
            return .sharpTurn
        case "HARSH_ACCEL":
            return .harshAccel
        case "HARSH_BRAKE":
            return .harshBrake
        case "HARSH_TURN":
            return .harshTurn
        case "SEVERE_ACCEL":
            return .severeAccel
        case "SEVERE_BRAKE":
            return .severeBrake
        case "SEVERE_TURN":
            return .severeTurn
        case "NO_DRIVER":
            return .noDriver
        case "ASLEEP":
            return .asleep
        case "DROWSINESS":
            return .drowsiness
        case "YAWN":
            return .yawn
        case "DAYDREAMING":
            return .daydreaming
        case "USING_PHONE":
            return .phoneCalling
        case "SMOKING":
            return .smoking
        case "NO_SEATBELT":
            return .noSeatBelt
        case "DISTRACTED":
            return .distracted
        case "ATTENTIVE":
            return .attentive
        case "DRINKING":
            return .drinking
        case "FORWARD_COLLISION_WARNING":
            return .forwardCollisionWarning
        case "HEADWAY_MONITORING_WARNING":
            return .headwayMonitoringWarning
        case "HEADWAY_MONITORING_EMERGENCY":
            return .headwayMonitoringEmergency
        case "LANE_DEPARTURE_WARNING":
            return .laneDepartureWarning
        case "DRIVING":
            return .driving
        case "PARKING":
            return .parking
        case "SIMCARDINFOCHANGED":
            return .simchange
        case "ACCOUNT_LOCK":
            return .account_lock
        case "ACCOUNT_UNLOCK":
            return .account_unlock
        case "SUCCESS":
            return .success
        case "FAILURE":
            return .failure
        case "GET_SERVICE_STATUS_FAIL":
            return .get_service_status_fail
        default:
            return .buffered
        }
    }
    
    func toString() -> String {
        switch self {
        case .buffered:
            return "STREAMING"
        case .manual:
            return "HIGHLIGHT"
        case .parkingMotion:
            return "PARKING_MOTION"
        case .parkingHit:
            return "PARKING_HIT"
        case .drivingHit:
            return "DRIVING_HIT"
        case .parkingHeavy:
            return "PARKING_HEAVY_HIT"
        case .drivingHeavy:
            return "DRIVING_HEAVY_HIT"
        case .hardAccel:
            return "HARD_ACCEL"
        case .hardBrake:
            return "HARD_BRAKE"
        case .sharpTurn:
            return "SHARP_TURN"
        case .harshAccel:
            return "HARSH_ACCEL"
        case .harshBrake:
            return "HARSH_BRAKE"
        case .harshTurn:
            return "HARSH_TURN"
        case .severeAccel:
            return "SEVERE_ACCEL"
        case .severeBrake:
            return "SEVERE_BRAKE"
        case .severeTurn:
            return "SEVERE_TURN"
        case .noDriver:
            return "NO_DRIVER"
        case .drowsiness:
            return "DROWSINESS"
        case .drinking:
            return "DRINKING"
        case .smoking:
            return "SMOKING"
        case .phoneCalling:
            return "USING_PHONE"
        case .asleep:
            return "ASLEEP"
        case .daydreaming:
            return "DAYDREAMING"
        case .yawn:
            return "YAWN"
        case .distracted:
            return "DISTRACTED"
        case .attentive:
            return "ATTENTIVE"
        case .noSeatBelt:
            return "NO_SEATBELT"
        case .forwardCollisionWarning:
            return "FORWARD_COLLISION_WARNING"
        case .headwayMonitoringWarning:
            return "HEADWAY_MONITORING_WARNING"
        case .headwayMonitoringEmergency:
            return "HEADWAY_MONITORING_EMERGENCY"
        case .laneDepartureWarning:
            return "LANE_DEPARTURE_WARNING"
        case .driving:
            return "DRIVING"
        case .parking:
            return "PARKING"
        case .simchange:
            return "SIMCARDINFOCHANGED"
        case .account_lock:
            return "ACCOUNT_LOCK"
        case .account_unlock:
            return "ACCOUNT_UNLOCK"
        case .get_service_status_fail:
            return "GET_SERVICE_STATUS_FAIL"
        case .success:
            return "SUCCESS"
        case .failure:
            return "FAILURE"
        }
    }
    
    var isParking:Bool {
        switch self {
        case .parkingMotion, .parkingHit, .parkingHeavy, .parking:
            return true
        default:
            return false
        }
    }
    
    var isDMS:Bool {
        switch self {
        case .noDriver, .drowsiness, .drinking, .smoking, .phoneCalling,
             .asleep, .daydreaming, .yawn, .distracted, .attentive, .noSeatBelt:
            return true
        default:
            return false
        }
    }
    
    var isADAS:Bool {
        switch self {
        case .forwardCollisionWarning, .headwayMonitoringWarning, .headwayMonitoringEmergency, .laneDepartureWarning:
            return true
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .buffered:
            return NSLocalizedString("Buffered", comment: "Buffered")
        case .manual:
            return NSLocalizedString("Highlight", comment: "Highlight")
            #if FLEET
        case .parkingMotion:
            return NSLocalizedString("Motion", comment: "Motion")
        case .parkingHit:
            return NSLocalizedString("Bump", comment: "Bump")
        case .drivingHit:
            return NSLocalizedString("Bump", comment: "Bump")
        case .parkingHeavy:
            return NSLocalizedString("Impact", comment: "Impact")
        case .drivingHeavy:
            return NSLocalizedString("Impact", comment: "Impact")
            #else
        case .parkingMotion:
            return NSLocalizedString("Motion while parked", comment: "Motion while parked")
        case .parkingHit:
            return NSLocalizedString("Bump while parked", comment: "Bump while parked")
        case .drivingHit:
            return NSLocalizedString("Bump while driving", comment: "Bump while driving")
        case .parkingHeavy:
            return NSLocalizedString("Impact while parked", comment: "Impact while parked")
        case .drivingHeavy:
            return NSLocalizedString("Impact while driving", comment: "Impact while driving")
            #endif
        case .hardAccel:
            return NSLocalizedString("Hard Accel", comment: "Hard Accel")
        case .hardBrake:
            return NSLocalizedString("Hard Brake", comment: "Hard Brake")
        case .sharpTurn:
            return NSLocalizedString("Sharp Turn", comment: "Sharp Turn")
        case .harshAccel:
            return NSLocalizedString("Harsh Accel", comment: "Harsh Accel")
        case .harshBrake:
            return NSLocalizedString("Harsh Brake", comment: "Harsh Brake")
        case .harshTurn:
            return NSLocalizedString("Harsh Turn", comment: "Harsh Turn")
        case .severeAccel:
            return NSLocalizedString("Severe Accel", comment: "Severe Accel")
        case .severeBrake:
            return NSLocalizedString("Severe Brake", comment: "Severe Brake")
        case .severeTurn:
            return NSLocalizedString("Severe Turn", comment: "Severe Turn")
        case .noDriver:
            return NSLocalizedString("No Driver", comment: "No Driver")
        case .drowsiness:
            return NSLocalizedString("Drowsy", comment: "Drowsy")
        case .drinking:
            return NSLocalizedString("Drinking", comment: "Drinking")
        case .smoking:
            return NSLocalizedString("Smoking", comment: "Smoking")
        case .phoneCalling:
            return NSLocalizedString("Using Phone", comment: "Using Phone")
        case .asleep:
            return NSLocalizedString("Asleep", comment: "Asleep")
        case .daydreaming:
            return NSLocalizedString("Daydreaming", comment: "Daydreaming")
        case .yawn:
            return NSLocalizedString("Yawning", comment: "Yawning")
        case .noSeatBelt:
            return NSLocalizedString("No Seatbelt", comment: "No Seatbelt")
        case .distracted:
            return NSLocalizedString("Distracted", comment: "Distracted")
        case .attentive:
            return NSLocalizedString("Attentive", comment: "Attentive")
        case .forwardCollisionWarning:
            return NSLocalizedString("FORWARD_COLLISION_WARNING", comment: "FORWARD_COLLISION_WARNING")
        case .headwayMonitoringWarning:
            return NSLocalizedString("HEADWAY_MONITORING_WARNING", comment: "HEADWAY_MONITORING_WARNING")
        case .headwayMonitoringEmergency:
            return NSLocalizedString("HEADWAY_MONITORING_EMERGENCY", comment: "HEADWAY_MONITORING_EMERGENCY")
        case .laneDepartureWarning:
            return NSLocalizedString("Lane Departure", comment: "Lane Departure")
        case .driving:
            return NSLocalizedString("DRIVING", comment: "DRIVING")
        case .parking:
            return NSLocalizedString("PARKING", comment: "PARKING")
        case .simchange:
            return NSLocalizedString("SIMCARDINFOCHANGED", comment: "SIMCARDINFOCHANGED")
        case .account_lock:
            return NSLocalizedString("ACCOUNT_LOCK", comment: "ACCOUNT_LOCK")
        case .account_unlock:
            return NSLocalizedString("ACCOUNT_UNLOCK", comment: "ACCOUNT_UNLOCK")
        case .success:
            return NSLocalizedString("SUCCESS", comment: "SUCCESS")
        case .failure:
            return NSLocalizedString("FAILURE", comment: "FAILURE")
        case .get_service_status_fail:
            return NSLocalizedString("GET_SERVICE_STATUS_FAIL", comment: "GET_SERVICE_STATUS_FAIL")
        }
    }
    
    var color: UIColor {
        switch self {
        case .parkingMotion:
            return UIColor.semanticColor(.activity(.motion))
        case .parkingHit, .drivingHit:
            return UIColor.semanticColor(.activity(.hit))
        case .hardAccel, .hardBrake, .sharpTurn:
            return UIColor.semanticColor(.activity(.hardBehavior))
        case .harshAccel, .harshBrake, .harshTurn:
            return UIColor.semanticColor(.activity(.harshBehavior))
        case .severeAccel, .severeBrake, .severeTurn:
            return UIColor.semanticColor(.activity(.severeBehavior))
        case .parkingHeavy, .drivingHeavy:
            return UIColor.semanticColor(.activity(.heavy))
        case .buffered:
            return UIColor.semanticColor(.activity(.buffered))
        case .manual:
            return UIColor.semanticColor(.activity(.manual))
        case .noDriver, .drowsiness, .drinking, .smoking, .phoneCalling,
             .asleep, .daydreaming, .yawn, .distracted, .attentive, .noSeatBelt:
            return UIColor.semanticColor(.activity(.dms))
        case .forwardCollisionWarning, .headwayMonitoringWarning, .headwayMonitoringEmergency, .laneDepartureWarning, .get_service_status_fail:
            return UIColor.semanticColor(.activity(.adas))
        case .driving, .parking:
            return UIColor.semanticColor(.activity(.ignition))
        case .success,.failure:
            return UIColor.semanticColor(.activity(.payment))
        case .simchange,.account_lock, .account_unlock:
            return UIColor.semanticColor(.activity(.account))
        }
    }
    
    func isContained(by filter: HNVideoOptions?) -> Bool {
        return filter == nil  || filter!.contains(HNVideoOptions.fromType(self))
    }
}

extension HNVideoType: Decodable {

    public init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        self = HNVideoType.from(string: label)
    }

}

struct HNVideoOptions: OptionSet {
    let rawValue: Int
    static let buffered = HNVideoOptions(rawValue: 1 << 0)
    static let manual = HNVideoOptions(rawValue: 1 << 1)
    static let parkingMotion = HNVideoOptions(rawValue: 1 << 2)
    static let parkingHit = HNVideoOptions(rawValue: 1 << 3)
    static let drivingHit = HNVideoOptions(rawValue: 1 << 4)
    static let parkingHeavy = HNVideoOptions(rawValue: 1 << 5)
    static let drivingHeavy = HNVideoOptions(rawValue: 1 << 6)
    static let hardAccel = HNVideoOptions(rawValue: 1 << 7)
    static let hardBrake = HNVideoOptions(rawValue: 1 << 8)
    static let sharpTurn = HNVideoOptions(rawValue: 1 << 9)
    static let harshAccel = HNVideoOptions(rawValue: 1 << 10)
    static let harshBrake = HNVideoOptions(rawValue: 1 << 11)
    static let harshTurn = HNVideoOptions(rawValue: 1 << 12)
    static let severeAccel = HNVideoOptions(rawValue: 1 << 13)
    static let severeBrake = HNVideoOptions(rawValue: 1 << 14)
    static let severeTurn = HNVideoOptions(rawValue: 1 << 15)
    // dms
    static let noDriver = HNVideoOptions(rawValue: 1 << 16)
    static let drowsiness = HNVideoOptions(rawValue: 1 << 17)
    static let drinking = HNVideoOptions(rawValue: 1 << 18)
    static let smoking = HNVideoOptions(rawValue: 1 << 19)
    static let phoneCalling = HNVideoOptions(rawValue: 1 << 20)
    //
    static let asleep = HNVideoOptions(rawValue: 1 << 21)
    static let daydreaming = HNVideoOptions(rawValue: 1 << 22)
    static let yawn = HNVideoOptions(rawValue: 1 << 23)
    static let distracted = HNVideoOptions(rawValue: 1 << 24)
    static let attentive = HNVideoOptions(rawValue: 1 << 25)
    static let noSeatBelt = HNVideoOptions(rawValue: 1 << 26)
    // adas
    static let forwardCollisionWarning = HNVideoOptions(rawValue: 1 << 27)
    static let headwayMonitoringWarning = HNVideoOptions(rawValue: 1 << 28)
    static let headwayMonitoringEmergency = HNVideoOptions(rawValue: 1 << 29)
    static let laneDepartureWarning = HNVideoOptions(rawValue: 1 << 30)
    static let driving = HNVideoOptions(rawValue: 1 << 31)
    static let parking = HNVideoOptions(rawValue: 1 << 32)
    static let simchange = HNVideoOptions(rawValue: 1 << 33)
    static let account_lock = HNVideoOptions(rawValue: 1 << 34)
    static let account_lunock = HNVideoOptions(rawValue: 1 << 35)
    static let success = HNVideoOptions(rawValue: 1 << 36)
    static let failure = HNVideoOptions(rawValue: 1 << 37)
    static let get_service_status_fail = HNVideoOptions(rawValue: 1 << 38)

    static let motion = HNVideoOptions.parkingMotion
    static let hit: HNVideoOptions = [.parkingHit, .drivingHit]
    static let behavior: HNVideoOptions = [.hardAccel, .hardBrake, .sharpTurn, .harshAccel, .harshBrake, .harshTurn, .severeAccel, .severeBrake, .severeTurn]
    static let dms: HNVideoOptions = [.noDriver, .drowsiness, .drinking, .smoking, .phoneCalling,
                                      .asleep, .daydreaming, .yawn, .distracted, .attentive, .noSeatBelt]
    static let adas: HNVideoOptions = [.forwardCollisionWarning, .headwayMonitoringWarning, .headwayMonitoringEmergency, .laneDepartureWarning, .get_service_status_fail]
    static let heavy: HNVideoOptions = [.parkingHeavy, .drivingHeavy]
    static let ignition: HNVideoOptions = [.driving, .parking]
    static let account: HNVideoOptions = [.account_lock, .account_lunock, .simchange]
    static let payment: HNVideoOptions = [.success, .failure]
    static let all: HNVideoOptions = [.buffered, .motion, .hit, .heavy, .manual, .behavior, .dms, .adas, .ignition, .account, .payment]
    
    static func fromType(_ type:HNVideoType) -> HNVideoOptions {
        switch type {
        case .buffered:
            return .buffered
        case .parkingMotion:
            return .motion
        case .parkingHit, .drivingHit:
            return .hit
        case .hardAccel, .hardBrake, .sharpTurn, .harshAccel, .harshBrake, .harshTurn, .severeAccel, .severeBrake, .severeTurn:
            return .behavior
        case .noDriver, .drowsiness, .drinking, .smoking, .phoneCalling,
             .asleep, .daydreaming, .yawn, .distracted, .attentive, .noSeatBelt:
            return .dms
        case .forwardCollisionWarning, .headwayMonitoringWarning, .headwayMonitoringEmergency, .laneDepartureWarning, .get_service_status_fail:
            return .adas
        case .parkingHeavy, .drivingHeavy:
            return .heavy
        case .manual:
            return .manual
        case .driving, .parking:
            return .ignition
        case .account_lock, .account_unlock, .simchange:
            return .account
        case .success, .failure:
            return .payment
        }
    }
    
    func toString() -> String {
        var types = [String]()
        for videoType in HNVideoType.allVideoTypes {
            if self.contains(HNVideoOptions.fromType(videoType)) {
                types.append(videoType.toString())
            }
        }
        return types.joined(separator: ",")
    }
}

extension HNVideoOptions {
    
    public init(_ type: HNVideoType) {
        self = HNVideoOptions(rawValue: type.rawValue)
    }
    
    ///returns the log level, or the lowest equivalant.
    public func toType() -> HNVideoType? {
        if let ourValid = HNVideoType(rawValue: rawValue) {
            return ourValid
        } else {
            if contains(.buffered) {
                return .buffered
            } else if contains(.manual) {
                return .manual
            } else if contains(.parkingMotion) {
                return .parkingMotion
            } else if contains(.parkingHit) {
                return .parkingHit
            } else if contains(.drivingHit) {
                return .drivingHit
            } else if contains(.parkingHeavy) {
                return .parkingHeavy
            } else if contains(.drivingHeavy) {
                return .drivingHeavy
            } else if contains(.hardAccel) {
                return .hardAccel
            } else if contains(.hardBrake) {
                return .hardBrake
            } else if contains(.sharpTurn) {
                return .sharpTurn
            } else {
                return nil
            }
        }
    }
}

extension WLVDBClip {
    var videoType: HNVideoType {
        if clipType == CLIP_TYPE_BUFFER {
            return .buffered
        }
        else if clipType == CLIP_TYPE_MARKED {
            if eventType != .NULL {
                switch eventType {
                case .motion:
                    return .parkingMotion
                case .park_light:
                    return .parkingHit
                case .park_heavy:
                    return .parkingHeavy
                case .drive_light:
                    return .drivingHit
                case .hard_Accel:
                    return .hardAccel
                case .hard_Brake:
                    return .hardBrake
                case .sharp_Turn:
                    return .sharpTurn
                case .harsh_Accel:
                    return .harshAccel
                case .harsh_Brake:
                    return .harshBrake
                case .harsh_Turn:
                    return .harshTurn
                case .severe_Accel:
                    return .severeAccel
                case .severe_Brake:
                    return .severeBrake
                case .severe_Turn:
                    return .severeTurn
                case .drive_heavy:
                    return .drivingHeavy
                default:
                    return .manual
                }
            }
            else if dmsType != .unknown {
                switch dmsType {
                case .noDriver:
                    return .noDriver
                case .drowsiness:
                    return .drowsiness
                case .drinking:
                    return .drinking
                case .smoking:
                    return .smoking
                case .phoneCall:
                    return .phoneCalling
                case .asleep:
                    return .asleep
                case .daydreaming:
                    return .daydreaming
                case .yawn:
                    return .yawn
                case .distracted:
                    return .distracted
                case .attentive:
                    return .attentive
                case .noSeatBelt:
                    return .noSeatBelt
                default:
                    return .manual
                }
            }
            else if adasType != .unknown {
                switch adasType {
                case .fcw:
                    return .forwardCollisionWarning
                case .hmw:
                    return .headwayMonitoringWarning
                case .hme:
                    return .headwayMonitoringEmergency
                case .ldw:
                    return .laneDepartureWarning
                default:
                    return .manual
                }
            }
        }
        return .manual
    }
}

protocol BasicClip {
    var clipID: Int64 { get }
    var startDate: Date { get }
    var duration: TimeInterval { get }
    var videoType: HNVideoType { get }
    var facedown: Bool { get }
    var needDewarp: Bool { get }
    var location: WLLocation? { get }
    func toDict() -> [String: Any]
}

extension BasicClip {
    var identifier: String {
        return "\(clipID)_\(Int64(startDate.timeIntervalSince1970 * 1000))_\(Int(duration*1000)))_\(videoType.rawValue)"
    }
    
    func isIdenticalTo(_ other: BasicClip) -> Bool {
        return clipID == other.clipID && videoType == other.videoType && abs(duration - other.duration) < 0.1 && startDate == other.startDate
    }
    
    func defaultToDict() -> [String: Any] {
        var d = [String: Any]()

        #if FLEET
        d["momentID"] = clipID
        d["duration"] = duration * 1000
        d["startTime"] = startDate.timeIntervalSince1970 * 1000
        d["clipTypeAsInt"] = videoType.rawValue
        d["rotate"] = facedown ? CameraInstallationMode.lensDown.toParameterValue() : CameraInstallationMode.lensUp.toParameterValue()
        d["needDewarp"]  = needDewarp
        #else
        d["clipID"] = clipID
        d["durationMs"] = duration * 1000
        d["captureTime"] = startDate.timeIntervalSince1970 * 1000
        d["clipTypeAsInt"] = videoType.rawValue
        d["rotate"] = facedown ? CameraInstallationMode.lensDown.toParameterValue() : CameraInstallationMode.lensUp.toParameterValue()
        if let coordinate = location?.coordinate {
            d["gps"] = coordinate.toDict()
        }
        if let address = location?.address {
            d["location"] = address.toDict()
        }
        d["needDewarp"]  = needDewarp
        #endif

        return d
    }
    
    func toDict() -> [String: Any] {
        return defaultToDict()
    }
}

class HNClip: BasicClip {

    var clipID : Int64
    var videoType : HNVideoType
    var duration : TimeInterval
    private(set) var facedown : Bool
    private(set) var startDate : Date
    private(set) var needDewarp: Bool
    var endDate:Date {
        return Date(timeInterval: duration, since: startDate)
    }
    var location: WLLocation?
    private(set) var rawClip : WLVDBClip?
    var url: String?
    let isVideo: Bool
    var thumbnailUrl: String?
    
    init(_ clip: WLVDBClip) {
        self.rawClip = clip
        duration = clip.duration
        clipID = Int64(clip.clipID)
        startDate = Date(timeIntervalSince1970: clip.startDate + clip.startTime - NSDate.zoneInterval())
        videoType = clip.videoType
        facedown = clip.isRotated
        isVideo = true
        needDewarp = clip.needDewarp
    }
    
    init(dict: [String: Any]) {
        #if FLEET
        clipID = dict["momentID"] as! Int64
        startDate = Date(timeIntervalSince1970: (dict["startTime"] as! TimeInterval)/1000)
        url = dict["mp4Url"] as? String
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()

        if let value = dict["eventType"] as? String {
            videoType = HNVideoType.from(string: value)
        } else if let value = dict["clipTypeAsInt"] as? Int {
            videoType = HNVideoType(rawValue: value) ?? .manual
        } else {
            videoType = .manual
        }

        duration = dict["duration"] as! TimeInterval / 1000
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()
        needDewarp = dict["needDewarp"] as? Bool ?? true
        rawClip = nil
        isVideo = true
        #else
        clipID = dict["clipID"] as! Int64
        if let gps = dict["gps"] as? [String: Any] {
            let address = dict["location"] as? [String: Any]
            location = WLLocation(coordinate: gps, address: address)
        }
        startDate = Date(timeIntervalSince1970: (dict["captureTime"] as! TimeInterval)/1000)
        url = dict["url"] as? String
        if let value = dict["clipType"] as? String {
            videoType = HNVideoType.from(string: value)
        } else if let value = dict["clipTypeAsInt"] as? Int {
            videoType = HNVideoType(rawValue: value) ?? .manual
        } else {
            videoType = .manual
        }
        isVideo = (dict["mediaType"] as? String ?? "video") == "video"
        thumbnailUrl = dict["thumbnail"] as? String
        duration = dict["durationMs"] as! TimeInterval / 1000

        needDewarp = dict["needDewarp"] as? Bool ?? true

        // ####### init rotate parameters
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()
        rawClip = nil
        #endif
    }
    
    func updateRawClip(_ clip: WLVDBClip) {
        self.rawClip = clip
        duration = clip.duration
        clipID = Int64(clip.clipID)
        startDate = Date(timeIntervalSince1970: clip.startDate + clip.startTime - NSDate.zoneInterval())
        videoType = clip.videoType
        facedown = clip.isRotated
    }
    
    func toDict() -> [String : Any] {
        var dict = defaultToDict()
        dict["url"] = url
        return dict
    }
}

extension HNClip: Equatable {
    static func == (left: HNClip, right: HNClip) -> Bool {
        return left.clipID == right.clipID && left.videoType == right.videoType
    }
}

