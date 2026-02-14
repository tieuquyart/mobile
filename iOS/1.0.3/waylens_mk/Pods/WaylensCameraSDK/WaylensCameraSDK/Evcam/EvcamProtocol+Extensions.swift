//
//  EvcamProtocol+Extensions.swift
//  Hachi
//
//  Created by forkon on 2018/12/5.
//  Copyright © 2018 Transee. All rights reserved.
//

struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
        return try self.decode(T.self, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension KeyedEncodingContainer where Key == JSONCodingKeys {
    mutating func encodeJSONKeyValues(withDictionary dictionary: [String : Any]) throws {
        for (key, value) in dictionary {
            let dynamicKey = JSONCodingKeys(stringValue: key)!
            switch value {
            case let v as Encodable: try v.encode(to: self.superEncoder(forKey: dynamicKey))
            default: print("Type \(type(of: value)) not supported")
            }
        }
    }
}

extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {

        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

//extension EvcamCmd: Encodable {
//
//    enum CodingKeys: String, CodingKey {
//        case category = "category"
//        case cmd = "cmd"
//        case param = "param"
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(category.rawValue, forKey: .category)
//        try container.encode(cmd, forKey: .cmd)
//
//        if let paramArray = param as? [Decodable] {
//            try container.encode(paramArray, forKey: .param)
//        } else {
//            var paramContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .param)
//            try paramContainer.encodeJSONKeyValues(withDictionary: param)
//        }
//    }
//
//}



extension WLRecordState {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "stopped":
            self = .stopped
        case "stopping":
            self = .stopping
        case "starting":
            self = .starting
        case "recording":
            self = .recording
        case "closed":
            self = .closed
        case "opening":
            self = .opening
        case "error":
            self = .error
        case "switching":
            self = .switching
        default:
            return nil
        }
    }
    
}

extension WLRecordMode {
    
    init(autoRecord: Bool, autoDelete: Bool) {
        switch (autoRecord, autoDelete) {
        case (false, false):
            self = Rec_Mode_Manual
        case (true, false):
            self = Rec_Mode_AutoStart
        case (false, true):
            self = Rec_Mode_Manual_circle
        case (true, true):
            self = Rec_Mode_AutoStart_circle
        }
    }
    
}

extension eVideoResolution {

    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "1080p30":
            self = Video_Resolution_1080p30
        case "1080p60":
            self = Video_Resolution_1080p60
        case "720p30":
            self = Video_Resolution_720p30
        case "720p60":
            self = Video_Resolution_720p60
        case "4Kp30":
            self = Video_Resolution_4Kp30
        case "4Kp60":
            self = Video_Resolution_4Kp60
        case "480p30":
            self = Video_Resolution_480p30
        case "480p60":
            self = Video_Resolution_480p60
        case "720p120":
            self = Video_Resolution_720p120
        case "Still":
            self = Video_Resolution_Still
        case "QXVGAp30":
            self = Video_Resolution_QXGAp30
//        case "360":
//            self = Video_Resolution_360_2MP30
//        case "Telenav":
//            self = Video_Resolution_Telenav
//        case "1080p1":
//            self = Video_Resolution_1080p1
        default:
            return nil
        }
    }
    
}

extension NSString {
    
    @objc var videoResolutionValue: eVideoResolution {
        return eVideoResolution(stringValue: self as String) ?? Video_Resolution_num
    }
    
    @objc class func stringWithVideoResolution(_ resolution: eVideoResolution) -> NSString? {
        switch resolution {
        case Video_Resolution_1080p30:
            return "1080p30"
        case Video_Resolution_1080p60:
            return "1080p60"
        case Video_Resolution_720p30:
            return "720p30"
        case Video_Resolution_720p60:
            return "720p60"
        case Video_Resolution_4Kp30:
            return "4Kp30"
        case Video_Resolution_4Kp60:
            return "4Kp60"
        case Video_Resolution_480p30:
            return "480p30"
        case Video_Resolution_480p60:
            return "480p60"
        case Video_Resolution_720p120:
            return "720p120"
        case Video_Resolution_Still:
            return "Still"
        case Video_Resolution_QXGAp30:
            return "QXVGAp30"
//        case Video_Resolution_360_2MP30:
//            return "360"
//        case Video_Resolution_Telenav:
//            return "Telenav"
//        case Video_Resolution_1080p1:
//            return "1080p1"
        default:
            return nil
        }
    }
    
}

extension EvcamCameraTFState {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "slow":
            self = .slow
        case "normal":
            self = .normal
        default:
            return nil
        }
    }
    
}

extension EvcamTransferFirmwareState {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "started":
            self = .started
        case "transferring":
            self = .transferring
        case "checking":
            self = .checking
        case "done":
            self = .done
        case "error":
            self = .error
        default:
            return nil
        }
    }

    var intValue: Int {
        switch self {
        case .started:
            return 0
        case .transferring:
            return 1
        case .checking:
            return 2
        case .done:
            return 3
        case .error:
            return 4
        }
    }

    init?(intValue: Int) {
        switch intValue {
        case 0:
            self = .started
        case 1:
            self = .transferring
        case 2:
            self = .checking
        case 3:
            self = .done
        case 4:
            self = .error
        default:
            return nil
        }
    }
    
}

extension EvcamTFState {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "none":
            self = .none
        case "loading":
            self = .loading
        case "ready":
            self = .ready
        case "error":
            self = .error
        case "unknown":
            self = .unknown
        case "usbdisc":
            self = .usbdisc
        case "formatting":
            self = .formatting
        case "unmounted":
            self = .unmounted
        default:
            return nil
        }
    }
    
}

extension WLStorageState {
    
    init(tfState: EvcamTFState) {
        switch tfState {
        case .none: // none : no TF card
            self = .noStorage
        case .loading: // loading : is loading
            self = .loading
        case .ready: // ready : ready to use
            self = .ready
        case .error: // error : failed to load TF
            self = .error
        case .unknown: // unknown : TF format is unknown
            self = .num
        case .usbdisc: // usbdisc : TF is mounted as USB disc
            self = .usbDisc
        default:
            self = .num
//        case .formatting: // formatting : TF is being formatted
//            self = State_storage_formatting
//        case .unmounted: // unmounted : TF is unmounted
//            self = State_storage_unmounted
        }
    }
    
}

extension EvcamWifiMode {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "off":
            self = .off
        case "AP":
            self = .ap
        case "WLAN":
            self = .wlan
        case "MULTIROLE":
            self = .multiRole
        case "P2P":
            self = .p2p
        default:
            return nil
        }
    }
    
}

extension Wifi_Mode {
    
    init(evcamWifiMode: EvcamWifiMode) {
        switch evcamWifiMode {
        case .off:
            self = Wifi_Mode_Off
        case .ap:
            self = Wifi_Mode_AP
        case .wlan:
            self = Wifi_Mode_Client
        case .multiRole:
            self = Wifi_Mode_MultiRole
        default:
            fatalError()
//        case .p2p:
//            self = Wifi_Mode_P2P
        }
    }
    
}

extension EvcamWifiMultiRoleMode {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "AP":
            self = .ap
        case "WLAN":
            self = .wlan
        case "AP+WLAN":
            self = .apwlan
        default:
            return nil
        }
    }
    
}

extension EvcamGsensorSensitivity {
    
    var stringValue: String {
        switch self {
        case .off:
            return "off"
        case .high:
            return "high"
        case .normal:
            return "normal"
        case .low:
            return "low"
        }
    }
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "off":
            self = .off
        case "high":
            self = .high
        case "normal":
            self = .normal
        case "low":
            self = .low
        default:
            return nil
        }
    }
    
}

extension EvcamMarkState {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "none":
            self = .none
        case "gsensor":
            self = .gsensor
        case "manual":
            self = .manual
        default:
            return nil
        }
    }
    
}

extension EvcamRecordErrorReason {
    
    init?(stringValue: String?) {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue {
        case "no_disk":
            self = .noDisk
        case "disk_error":
            self = .diskError
        case "disk_full":
            self = .diskFull
        case "disk_too_slow":
            self = .diskTooSlow
        default:
            return nil
        }
    }
    
}

extension ErrRecode {
    
    init(reason: EvcamRecordErrorReason) {
        switch reason {
        case .noDisk:
            self = Error_code_notfcard
        case .diskError:
            self = Error_code_tfError
        case .diskFull:
            self = Error_code_tfFull
        default:
            fatalError()
//        case .diskTooSlow:
//            self = Error_code_tfTooSlow
        }
    }
    
}

extension WLEvcamScreenSaverTime {
    
    var stringValue: String {
        switch self {
        case .after10s:
            return "10s"
        case .after30s:
            return "30s"
        case .after60s:
            return "60s"
        case .after2m:
            return "2min"
        case .after5m:
            return "5min"
        default:
            return "Never"
        }
    }
    
}

extension WLCameraHDRMode: Decodable {

    var stringValue: String {
        switch self {
        case .on:
            return "on"
        case .off:
            return "off"
        case .auto:
            return "auto"
        default:
            fatalError()
        }
    }

    public init(from decoder: Decoder) throws {
        let stringValue = try decoder.singleValueContainer().decode(String.self)

        switch stringValue {
        case "on":
            self = .on
        case "off":
            self = .off
        case "auto":
            self = .auto
        default:
            throw NSError()
        }
    }

}

extension NSString {
    
    @objc var asEvcamScreenSaverTime: WLEvcamScreenSaverTime {
        switch self {
        case "10s":
            return WLEvcamScreenSaverTime.after10s
        case "30s":
            return WLEvcamScreenSaverTime.after30s
        case "60s":
            return WLEvcamScreenSaverTime.after60s
        case "2min":
            return WLEvcamScreenSaverTime.after2m
        case "5min":
            return WLEvcamScreenSaverTime.after5m
        default:
            return WLEvcamScreenSaverTime.never
        }
    }
    
}

extension UInt8 {
    
    var char: Character {
        return Character(UnicodeScalar(self))
    }
    
}

extension String {
    
    var evcamData: Data? {
        return data(using: .utf8)
    }
    
    var evcamLength: Int {
        return lengthOfBytes(using: .utf8)
    }
    
}

extension Data {
    
    var evcamString: String? {
        return String(data: self, encoding: .utf8)
    }
    
}
