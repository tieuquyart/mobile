//
//  UnifiedCamera.swift
//  Acht
//
//  Created by Chester Shen on 6/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import CoreLocation
import WaylensCameraSDK

protocol CameraRelated {
    var camera: UnifiedCamera? { get set }
}

struct WLLocation {
    struct Address {
        var country: String?
        var region: String?
        var city: String?
        var route: String?
        var streetNumber: String?
        var fullAddress: String?
        var street: String? {
            return route
        }
        
        init(dict:[String: Any]) {
            country = dict["country"] as? String
            region = dict["region"] as? String
            city = dict["city"] as? String
            route = dict["route"] as? String
            streetNumber = dict["streetNumber"] as? String
            fullAddress = dict["address"] as? String
        }
        
        init(placemark: CLPlacemark) {
            country = placemark.country
            region = placemark.administrativeArea
            city = placemark.locality
            route = placemark.thoroughfare
            streetNumber = placemark.subThoroughfare
            let components = [placemark.name, placemark.subLocality, placemark.locality, placemark.administrativeArea, placemark.country, placemark.postalCode].filter { (e) -> Bool in
                return e != nil && !e!.isEmpty
            } as! [String]
            fullAddress = components.joined(separator: ", ")
        }
        
        func toDict() -> [String: Any] {
            let dict = (["country": country,
                        "region": region,
                        "city": city,
                        "route": route,
                        "streetNumber": streetNumber,
                        "address": fullAddress]
                as [String: Any?]).dried()
            return dict
        }
    }
    
    var address: Address?
    var coordinate: CLLocationCoordinate2D?
    var correctedCoordinate: CLLocationCoordinate2D? { // use this coordinate for chinese map service
        return coordinate?.correctedForChina()
    }
    var speed: CLLocationSpeed = -1
    var horizontalAccuracy: CLLocationAccuracy = -1
    var verticalAccuracy: CLLocationAccuracy = -1
    var altitude: CLLocationDistance = 0
    var course: CLLocationDirection = -1
    var description: String? {
        if let street = address?.street, !street.isEmpty {
            return street
        }
        return correctedCoordinate?.description
    }
    
    init(coordinate: CLLocationCoordinate2D?, address: Address?) {
        self.coordinate = coordinate
        self.address = address
    }
    
    init(coordinate:[String: Any], address:[String: Any]?) {
        if let _address = address {
            self.address = Address(dict: _address)
        }
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate["latitude"] as! Double, longitude: coordinate["longitude"] as! Double)
    }
}

extension CLLocationCoordinate2D {
    func toDict() -> [String: Any] {
        return ["latitude": latitude,
                "longitude": longitude]
    }
}

struct DataSubscription {
    enum State: String {
        case none = "none"
        case inService = "in_service"
        case suspended = "suspended"
        case expired = "expired"
        case paid = "paid"
        static func from(string: String?) -> State {
            if let string = string {
                return State(rawValue: string) ?? .none
            } else {
                return .none
            }
        }
        var displayName: String {
            switch self {
            case .expired:
                return NSLocalizedString("Expired", comment: "Expired")
            case .inService, .paid:
                return NSLocalizedString("In service", comment: "In service")
            case .suspended:
                return NSLocalizedString("Suspended", comment: "Suspended")
            case .none:
                return NSLocalizedString("Subscribe", comment: "Subscribe")
            }
        }
    }
    var state: State
    var totalQuataInKB: Int64 = 0
    var usedInKB: Int64 = 0
    var expirationDate: Date?
    var name: String?
    
    var isRunningOut: Bool {
        return totalQuataInKB > 0 && (Double(usedInKB) / Double(totalQuataInKB) > 0.9)
    }
    var isTrial: Bool {
        return name?.lowercased().range(of: "trial") != nil
    }
    
    func usageDescription() -> String {
        let leftInKB = max(0, totalQuataInKB - usedInKB)
        let left = String.fromBytes(leftInKB * 1024, countStyle: .binary)
        return String(format: NSLocalizedString("%@ remaining", comment: "%@ remaining"), left)
    }
}

enum HNEventSensitivity: Int {
    case off = 0
    case low = 1
    case medium = 2
    case high = 3
    
    static func from(string: String?) -> HNEventSensitivity {
        guard let string = string else { return .off }
        switch string {
        case "low":
            return .low
        case "medium":
            return .medium
        case "high":
            return .high
        default:
            return .off
        }
    }
    
    func toString() -> String {
        switch self {
        case .off:
            return "off"
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        }
    }
}

enum HNBatteryStatus: Int {
    case empty = 5
    case low = 4
    case medium = 3
    case plenty = 2
    case full = 1
    case unknown = 0
    static func from(string: String) -> HNBatteryStatus? {
        switch string {
        case "Critical":
            return .empty
        case "Low":
            return .low
        case "Normal":
            return .medium
        case "High":
            return .plenty
        case "Full":
            return .full
        default:
            return .unknown
        }
    }
}

enum HNFeatureStatus: String {
    case none = "none"
    case on = "on"
    case off = "off"
    case auto = "auto"
}

enum HNGPSStatus {
    case none
    case on
    case off
    case searching
}

enum HNSignalStatus: Int {
//    case poor = 5
    case fair = 4
    case good = 3
    case very_good = 2
    case strong = 1
    case no_signal = 0
    
    init(db: Float) {
//        if db < -112 {
//            self = .poor
//        } else
        if db < -105 {
            self = .fair
        } else if db < -96 {
            self = .good
        } else if db < -88 {
            self = .very_good
        } else {
            self = .strong
        }
    }
}

enum HNPowerSource: String {
    case directWire = "direct wire"
    case obdDongle = "obd"
    case cigarLighter = "cigar lighter"
}

public enum HNCameraMode: String {
    case parking = "parking"
    case driving = "driving"
}

extension HNCameraMode: Codable {

    enum HNCameraModeCodingError: Error {
        case invalidRawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let label = try container.decode(String.self)

        guard let mode = HNCameraMode(rawValue: label.lowercased()) else {
            throw HNCameraModeCodingError.invalidRawValue
        }

        self = mode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

}

extension HNCameraMode: CustomStringConvertible {

    public var description: String {
        return rawValue.wl.capitalizingFirstLetter()
    }

}

enum HNAccLevel: String {
    case soft = "soft"
    case normal = "normal"
    case hard = "hard"
    case custom = "customized"
    
    var displayName: String {
        switch self {
        case .soft:
            return NSLocalizedString("High", comment: "High")
        case .normal:
            return NSLocalizedString("Medium", comment: "Medium")
        case .hard:
            return NSLocalizedString("Low", comment: "Low")
        case .custom:
            return NSLocalizedString("Custom", comment: "Custom")
        }
    }
    var description: String {
        switch self {
        case .soft:
            return NSLocalizedString("Records more events", comment: "Records more events")
        case .normal:
            return NSLocalizedString("Default setting", comment: "Default setting")
        case .hard:
            return NSLocalizedString("Records less events", comment: "Records less events")
        case .custom:
            return NSLocalizedString("Custom settings", comment: "Custom settings")
        }
    }
}

struct HNCellSignalInfo {
    var rsrp: Float
    var band: String
    var dlearfcn: Int
    
    var status: HNSignalStatus {
        return HNSignalStatus(db: rsrp)
    }
    
    var summary: String {
        return "\(rsrp)dB,\(band),\(dlearfcn)"
    }
    
//    init(dict: [String: Any]) {
//        rsrp = dict["RSRP"] as! Float
//        band = dict["Band"] as! String
//        dlearfcn = dict["DLEarfcn"] as! Int
//    }
    
    static func from(dict: [String: Any]) -> HNCellSignalInfo? {
        if let rsrp = dict["RSRP"] as? Float, let band = dict["Band"] as? String, let dlearfcn = dict["DLEarfcn"] as? Int {
            return HNCellSignalInfo(rsrp: rsrp, band: band, dlearfcn: dlearfcn)
        } else {
            return nil
        }
    }
}

struct CameraModeConfig {
    var monitoring: Bool
    var detection: HNEventSensitivity
    var alert: HNEventSensitivity
    var upload: HNEventSensitivity
    var nightVision: HNFeatureStatus?
    var nightVisionStartTime: Int?
    var nightVisionEndTime: Int?
    
    init(dict: [String: Any]) {
        monitoring = dict["monitoring"] as? String == "on"
        detection = HNEventSensitivity.from(string: dict["detectionSensitivity"] as? String)
        alert = HNEventSensitivity.from(string: dict["alertSensitivity"] as? String)
        upload = HNEventSensitivity.from(string: dict["uploadSensitivity"] as? String)
        nightVision = HNFeatureStatus(rawValue: dict["nightVision"] as? String ?? "")
        if let time = dict["nightVisionTime"] as? [String: Int] {
            nightVisionStartTime = time["from"]
            nightVisionEndTime = time["to"]
        }
    }
    
    mutating func dict() -> [String: Any] {
        var dict: [String: Any] = [
            "monitoring": monitoring ? "on" : "off",
            "detectionSensitivity": detection.toString(),
            "alertSensitivity": alert.toString(),
            "uploadSensitivity": upload.toString()
        ]
        if let nightVision = nightVision {
            dict["nightVision"] = nightVision.rawValue
        }
        if let from = nightVisionStartTime, let to = nightVisionEndTime {
            let timeDict = [
                "from": from,
                "to": to
            ]
            dict["nightVisionTime"] = timeDict
        }
        return dict
    }
    
//    mutating func updateDetection() {
//        detection = alert.rawValue > upload.rawValue ? alert : upload
//    }
}

struct CameraSettings {
    enum SettingStatus {
        case updated
        case pending
        case updating
        case failed
    }
    var status: SettingStatus = .updated
    var parkingConfig: CameraModeConfig? {
        didSet {
            status = .pending
            dict["parkingMode"] = parkingConfig?.dict()
        }
    }
    var drivingConfig: CameraModeConfig? {
        didSet {
            status = .pending
            dict["drivingMode"] = drivingConfig?.dict()
        }
    }
    var nightVision: HNFeatureStatus? {
        didSet {
            status = .pending
            dict["nightVision"] = nightVision?.rawValue
        }
    }
    var logoLed: HNFeatureStatus?{
        didSet {
            status = .pending
            dict["logoLED"] = logoLed?.rawValue
        }
    }
    var siren: HNFeatureStatus?{
        didSet {
            status = .pending
            dict["siren"] = siren?.rawValue
        }
    }
    var dict: [String: Any]
    
    init() {
        self.dict = [String: Any]()
    }
    
    init(dict: [String: Any]) {
        self.dict = dict
        parkingConfig = CameraModeConfig(dict: dict["parkingMode"] as! [String: Any])
        drivingConfig = CameraModeConfig(dict: dict["drivingMode"] as! [String: Any])
        logoLed = HNFeatureStatus(rawValue: dict["logoLED"] as? String ?? "")
        siren = HNFeatureStatus(rawValue: dict["siren"] as? String ?? "")
    }
}

enum CameraInstallationMode: CaseIterable {
    case lensUp
    case lensDown

    init(isUpsideDown: Bool) {
        if isUpsideDown {
            self = .lensDown
        } else {
            self = .lensUp
        }
    }

    func toParameterValue() -> String {
        switch self {
        case .lensUp:
            return "normal"
        case .lensDown:
            return "upsidedown"
        }
    }
}

// Provide unified interface to manage local and remote cameras
class UnifiedCamera: NSObject {
    var sn: String {
        return remote?.sn ?? (local?.sn)!
    }
    var remote: RemoteCamera?
    @objc dynamic var local: WLCameraDevice?
    var location: WLLocation? {
        get {
            return local?.liveDataMonitor?.location ?? remote?.location
        }
    }
    var viaWiFi: Bool {
        return local?.isConnected ?? false
    }
    var via4G: Bool {
        return !viaWiFi && remote?.isOnline ?? false
    }
    var isOffline: Bool {
        return !via4G && !viaWiFi
    }
    
    var name: String? {
        get {
            return local?.name ?? remote?.name
        }
        
        set {
            let newName = newValue ?? "Waylens Secure360"
            if local != nil {
                local?.setCameraName(newName)
            }
            remote?.setName(newName)
        }
    }
    
    var gpsStatus: HNGPSStatus? {
        if let status = local?.gpsStatus, status == .off {
            return .searching
        }
        if let status = local?.gpsStatus ?? remote?.gpsStatus {
            switch status {
            case .none:
                return HNGPSStatus.none
            case .off:
                return .off
            case .on:
                return .on
            default:
                return nil
            }
        }
        return nil
    }
    var obdStatus: HNFeatureStatus? {
        return remote?.obdStatus
    }
    var remoteControlStatus: HNFeatureStatus? {
        return remote?.remoteControlStatus
    }
    
    var cellSignalInfo: HNCellSignalInfo? {
        return remote?.cellSignalInfo
    }
    var cellSignalStatus: HNSignalStatus? {
        return local?.cellSignalStatus ?? remote?.cellSignalInfo?.status
    }
    
    var batteryStatus: HNBatteryStatus? {
        return local?.batteryStatus ?? remote?.batteryStatus
    }
    
    var powerSource: HNPowerSource? {
        return local?.powerSource ?? remote?.powerSource
    }
    
    var isCharging: Bool {
        return local?.isCharging ?? remote?.batteryCharging ?? false
    }
    
    var mode: HNCameraMode? {
        return local?.mode ?? remote?.mode
    }
    
    // settings
    var parkingConfig: CameraModeConfig? {
        get {
            return local?.parkingConfig ?? remote?.pendingSettings.parkingConfig ?? remote?.parkingConfig
        }
        set {
            if let local = local {
                local.parkingConfig = newValue
            } else if let remote = remote {
                remote.pendingSettings.parkingConfig = newValue
            }
        }
    }
    var drivingConfig: CameraModeConfig? {
        get {
            return local?.drivingConfig ?? remote?.pendingSettings.drivingConfig ?? remote?.drivingConfig
        }
        set {
            if let local = local {
                local.drivingConfig = newValue
            } else if let remote = remote {
                remote.pendingSettings.drivingConfig = newValue
            }
        }
    }
    var monitoring: Bool {
        get {
            return local?.monitoring ?? remote?.monitoring ?? false
        }
        set {
            if let local = local {
                local.monitoring = newValue
            } else if let _ = remote {
                // todo
            }
        }
    }
    var monitoringOffOnce: Bool {
        return local?.monitoringOffOnce ?? remote?.monitoringOffOnce ?? false
    }
    
    var logoLed: HNFeatureStatus? {
        get {
            return local?.logoLed ?? remote?.pendingSettings.logoLed ?? remote?.logoLed
        }
        set {
            if let local = local {
                local.logoLed = newValue
            } else if let remote = remote {
                remote.pendingSettings.logoLed = newValue
            }
        }
    }
    var siren: HNFeatureStatus? {
        get {
            return local?.siren ?? remote?.pendingSettings.siren ?? remote?.siren
        }
        set {
            if let local = local {
                local.siren = newValue
            } else if let remote = remote {
                remote.pendingSettings.siren = newValue
            }
        }
    }
    var mountCode: Int? {
        if let code = local?.mountVersionCode {
            return Int(code)
        }
        return remote?.mountCode
    }
    var mountHwModel: String? {
        return local?.mountHardwareModel ?? remote?.mountHwModel
    }
    var mountFwVersion: String? {
        return local?.mountFirmwareVersion ?? remote?.mountFwVersion
    }
    
    var nameDriver: String? {
        return local?.name
    }
    
    var supports4g: Bool {
        return (local?.isSupport4g ?? remote?.supports4g ?? false) || (remote?.isOnline ?? false)
    }
    
    var firmware: String? {
        return local?.firmwareVersion ?? remote?.firmware
    }
    
    var firmwareShort: String? {
        return local?.apiVersion ?? remote?.firmwareShort
    }
    
    var model: String? {
        return local?.hardwareModel ?? remote?.model
    }
    var needDewarp: Bool {
        if (local != nil) {
            return local?.productSerie == .horn
        }
        if (remote != nil) {
            return remote?.productionSerie == .horn
        }
        return false
    }
    
    var sdcardUsageTotal: Int64? {
        if let mb = local?.totalMB {
            return Int64(mb) * 1000 * 1000
        }
        return nil
    }
    
    var sdcardUsageFree: Int64? {
        if let mb = local?.freeMB {
            return Int64(mb) * 1000 * 1000
        }
        return nil
    }
    
    var sdcardUsageMarked: Int64? {
        if let mb = local?.markedMB {
            return Int64(mb) * 1000 * 1000
        }
        return nil
    }
    
    var sdcardUsageBuffered: Int64? {
        if let mb = local?.clipMB, let mb2 = local?.markedMB {
            return Int64(mb - mb2) * 1000 * 1000
        }
        return nil
    }
    
    var ownerUserId: String? {
        get {
            return remote?.ownerUserId
        }
        set {
            remote?.ownerUserId = newValue
        }
    }
    
    var iccid: String? {
        get {
            return local?.iccid ?? remote?.iccid
        }
    }
    
//    var imei: String? {
//        get {
//            return remote?.imei
//        }
//    }
    
    var modem: String? {
        get {
            return local?.lteFirmwareVersionPublic ?? remote?.modem
        }
    }

    var isSupportedUpsideDown: Bool {
        return local?.isSupportUpsideDown?.boolValue ?? false
    }

    var facedown: Bool {
        get {
            return local?.isUpsideDown ?? remote?.facedown ?? false
        }
    }

    var installationMode: CameraInstallationMode {
        return facedown ? .lensDown : .lensUp
    }
    
    lazy var messageManager = HNMessageManager(with: self)
    
    init(local: WLCameraDevice?, remote: RemoteCamera?) {
        self.local = local
        self.remote = remote
    }
    
    init(dict: [String: Any]) {
        self.remote = RemoteCamera(dict: dict)
    }
    
    private var dict: [String:Any] {
        let converted = toDict()
        if let origninalDict = remote?.dict {
            return origninalDict.merged(another: converted)
        } else {
            return converted
        }
    }
    
    func dictForCache() -> [String:Any] {
        var d = self.dict
        d.removeValue(forKey: "isOnline")
        d.removeValue(forKey: "_4gSignal")
        d.removeValue(forKey: "location")
        return d
    }
    
    func toDict() -> [String:Any] {
        #if FLEET
        let d = [
            "_timestamp": (local != nil ? Date() : remote?.lastActiveTime)?.timeIntervalSince1970, // added in v1
            "_version": 1, // added in v1
            "serialNumber": sn,
            "name": name,
            "ownerUserId": ownerUserId,
            "hardwareVersion": model,
            "rotate": facedown ? CameraInstallationMode.lensDown.toParameterValue() : CameraInstallationMode.lensUp.toParameterValue(), // Maybe "normal" or "upsidedown"
            "firmware": firmware,
            "fimwareShort": firmwareShort
            ] as [String: Any?]
        #else
        let d = [
            "_timestamp": (local != nil ? Date() : remote?.lastActiveTime)?.timeIntervalSince1970, // added in v1
            "_version": 1, // added in v1
            "sn": sn,
            "name": name,
            "ownerUserId": ownerUserId,
            "hardwareVersion": model,
            "rotate": facedown ? CameraInstallationMode.lensDown.toParameterValue() : CameraInstallationMode.lensUp.toParameterValue(), // Maybe "normal" or "upsidedown"
            "state": [
                "firmware": firmware,
                "fimwareShort": firmwareShort,
                "mountInfo": [
                    "mountHWVersion": mountHwModel,
                    "mountFWVersion": mountFwVersion,
                    "mount4G": supports4g
                    ] as [String: Any?]
                ] as [String: Any?]
            ] as [String: Any?]
        #endif
        return d.dried()
    }
    
    func bind(password: String, completion: @escaping completionBlock ) {
        guard let local = local else { return }
        WaylensClientS.shared.bindCamera(local.sn!, password: password, nickName: local.name ?? "Waylens Camera") { (result) in
            if result.isSuccess {
                UnifiedCameraManager.shared.updateRemote()
            }
            completion(result)
        }
    }
    
    func unbind(completion: @escaping completionBlock) {
        WaylensClientS.shared.unbindCamera(sn) { [weak self] (result) in
            guard let remote = self?.remote else {
                return
            }
            if result.isSuccess {
                UnifiedCameraManager.shared.remove(remote: remote)
            }
            completion(result)
        }
    }
    
    func syncName() {
        if let localName = local?.name, let remoteName = remote?.name, localName != remoteName {
            local?.setCameraName(remoteName)
        }
    }
    
    func reportICCID(completion: completionBlock?) {
        guard let local = local, let iccid = local.iccid, !iccid.isEmpty else { return }
        WaylensClientS.shared.reportICCID(local.sn!, iccid: iccid, completion: completion)
    }
    
    func updateSubscription(completion: completionBlock?) {
        WaylensClientS.shared.fetchCameraSubscription(sn) { [weak self] (result) in
            if result.isSuccess {
                self?.remote?.updateSubscription(result.value!)
                completion?(result)
            } else {
                self?.remote?.iccid = ""
                self?.remote?.subscription = DataSubscription(state: .none, totalQuataInKB: 0, usedInKB: 0, expirationDate: nil, name: nil)
                completion?(result)
            }
        }
    }
}

extension UnifiedCamera {
    override func isEqual(_ object: Any?) -> Bool {
        return sn == (object as? UnifiedCamera)?.sn
    }
    
    static func == (lhs: UnifiedCamera, rhs: UnifiedCamera) -> Bool {
        return lhs.sn == rhs.sn
    }
}
