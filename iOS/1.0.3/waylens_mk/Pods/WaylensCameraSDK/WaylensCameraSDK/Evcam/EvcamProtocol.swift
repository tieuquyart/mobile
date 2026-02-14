//
//  EvcamProtocol.swift
//  Hachi
//
//  Created by forkon on 2018/11/28.
//  Copyright © 2018 Transee. All rights reserved.
//

import WaylensFoundation

enum EvcamCategory: String, Codable {
    case device
    case camera
    case debug
    case unknown
}

enum EvcamCameraTFState: String, Decodable {
    case slow
    case normal
}

enum EvcamTransferFirmwareState: String, Decodable {
    case started
    case transferring
    case checking
    case done
    case error
}

enum EvcamTFState: String, Decodable {
    case none // none : no TF card
    case loading // loading : is loading
    case ready // ready : ready to use
    case error // error : failed to load TF
    case unknown // unknown : TF format is unknown
    case usbdisc // usbdisc : TF is mounted as USB disc
    case formatting // formatting : TF is being formatted
    case unmounted // unmounted : TF is unmounted
}

enum EvcamWifiMode: String, Decodable {
    case off
    case ap = "AP"
    case wlan = "WLAN"
    case multiRole = "MULTIROLE"
    case p2p = "P2P"
}

enum EvcamWifiMultiRoleMode: String, Decodable {
    case ap = "AP"
    case wlan = "WLAN"
    case apwlan = "AP+WLAN"
}


struct blueToothDevInfo: Decodable {
    let status: String
    let name: String?
    let mac: String?
    let level: Int?
}

struct blueToothDev: Decodable {
    let name: String
    let mac: String
    var dict : [String : Any] {
        return [ "name" : name, "mac" : mac ]
    }
}

enum EvcamGsensorSensitivity: String, Decodable {
    case off
    case high
    case normal
    case low
}

enum EvcamMarkState: String, Decodable {
    case none
    case gsensor
    case manual
}

enum EvcamRecordErrorReason: String, Decodable {
    case noDisk = "no_disk"
    case diskError = "disk_error"
    case diskFull = "disk_full"
    case diskTooSlow = "disk_too_slow"
}

@objc public enum WLEvcamScreenSaverTime: Int
{
    case never    = 0
    case after10s = 10
    case after30s = 30
    case after60s = 60
    case after2m  = 120
    case after5m  = 300
}

enum EvcamVideoResolution: Int
{
    case hd1080p30
    case hd720p60
    case hd720p30
    case hd1080p1
    case unknown
}

enum FileTransferState: String, Decodable {
    case started, transferring, checking, done, error
}

@objc public enum WLEvcamDeviceAttitude: Int, Decodable {
    private static let normalString: String = "normal"
    private static let upsidedownString: String = "upsidedown"

    case normal, upsidedown

    var stringValue: String {
        switch self {
        case .normal:
            return WLEvcamDeviceAttitude.normalString
        case .upsidedown:
            return WLEvcamDeviceAttitude.upsidedownString
        }
    }

    public init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        if label == WLEvcamDeviceAttitude.normalString {
            self = .normal
        } else {
            self = .upsidedown
        }
    }
}

enum EvcamAccelDetectLevel: Int, Decodable {
    case soft, normal, hard, customized

    var stringValue: String {
        switch self {
        case .soft:
            return "soft"
        case .normal:
            return "normal"
        case .hard:
            return "hard"
        case .customized:
            return "customized"
        }
    }

    init(stringValue: String) {
        switch stringValue {
        case "soft":
            self = .soft
        case "normal":
            self = .normal
        case "hard":
            self = .hard
        default:
            self = .customized
        }
    }
}

protocol EvcamMsgType: Decodable {

}

enum EvcamMsg {
    struct Device {
        struct DeviceInfo: EvcamMsgType {
            let make: String
            let model: String
            let software: String
            let api: String
            let build: String
            let date: String
            let sn: String
        }

        struct PowerOff: EvcamMsgType {
        }

        struct Reboot: EvcamMsgType {
        }

        struct FactoryReset: EvcamMsgType {
        }

        struct Time: EvcamMsgType {
            let time: UInt32
            let gmtoff: Int
        }

        struct Name: EvcamMsgType {
            let name: String
        }

        struct DateTimeFormat: EvcamMsgType {
            let dateFormat: String
            let timeFormat: String
        }

        struct TransferFirmware: EvcamMsgType {
            let state: EvcamTransferFirmwareState
            let size: Int?
            let progress: Int?
            let errorCode: Int?
        }

        struct TransferFile: EvcamMsgType {
            let state: FileTransferState
            let size: Int
            let progress: Int
            let errorCode: Int
        }

        struct PlayFile: EvcamMsgType {
            let state: String
        }

        struct DisplayFile: EvcamMsgType {
            let state: String
            let filepath: String
            let timeout: Int
        }

        struct UserFileList: EvcamMsgType {
            let fileList: [String]
            let name: String
        }

        struct TFState: EvcamMsgType {
            let state: EvcamTFState
            let system_id: String
        }

        struct MicState: EvcamMsgType {
            let muted: Bool
            let volumn: Int
            let minVolumn: Int
            let maxVolumn: Int
        }

        struct SpeakerState: EvcamMsgType {
            let muted: Bool
            let volumn: Int
            let minVolumn: Int
            let maxVolumn: Int
        }

        struct GPSState: EvcamMsgType {
            let state: String
            let num_svs: Int
        }

        struct WifiInfo: EvcamMsgType {
            let mode: EvcamWifiMode
            let multiRoleMode: EvcamWifiMultiRoleMode
            let ssid: String
            let password: String
        }

        struct BlueToothInfo: EvcamMsgType {
            let supported: Bool
            let enabled: Bool
            let isScanning: Bool
            let OBD: blueToothDevInfo
            let HID: blueToothDevInfo
        }

        struct BlueToothScanResult: EvcamMsgType {
            let list: [blueToothDev]
            var dict : [String : Any] {
                var arr = [[String : Any]]()
                for dev in list {
                    arr.append(dev.dict)
                }
                return [ "Devices" : arr ]
            }
        }

        struct LCDBrightness: EvcamMsgType {
            let brightness: Int
        }

        struct ScreenSaverTimeout: EvcamMsgType {
            let timeout: Int
        }

        struct GsensorSensitivity: EvcamMsgType {
            let sensitivity: EvcamGsensorSensitivity
        }

        struct Event: EvcamMsgType {
            let source: String
            let name: String
        }

        struct CameraLog: EvcamMsgType {
            let ready: Int
        }
        
        struct CameraDebugLog: EvcamMsgType {
            let ready: Int
        }

        struct WiFiKey: EvcamMsgType {
            let key: String
        }

        struct ServerUrl: EvcamMsgType {
            let url: String
        }

        struct MountVersion: EvcamMsgType, Encodable {
            let hw_version: String
            let sw_version: String
            let vercode: String
            let support_4g: Bool
            let imei: String
        }

        struct IgnitionMode: EvcamMsgType {
            let mode: String
        }

        struct AccelDetectLevel: EvcamMsgType {
            let levels: [EvcamAccelDetectLevel]
            let level: EvcamAccelDetectLevel
            let params: String? // not nil when level == customized

            enum CodingKeys: String, CodingKey {
                case levels
                case level
                case params
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                if let levelsJsonData = (try container.decode(String.self, forKey: .levels)).data(using: .utf8),
                    let levels = (try JSONSerialization.jsonObject(with: levelsJsonData, options: [])) as? [String] {
                    self.levels = levels.map{ EvcamAccelDetectLevel(stringValue:$0) }
                } else {
                    levels = []
                }

                level = EvcamAccelDetectLevel(stringValue: try container.decode(String.self, forKey: .level))

                if container.contains(.params) {
                    params = try container.decode(String.self, forKey: .params)
                } else {
                    params = nil
                }
            }
        }

        struct MwSensitivity: EvcamMsgType {
            let level: Int
        }

        struct DriveBehaviourDetect: EvcamMsgType {
            let enabled: Bool
            let param: [Int]
        }

        struct P2pInfo: EvcamMsgType {
            let enabled: Bool
            let pairedDevices: String // JSON String
        }

        struct SupportWlanMode: EvcamMsgType {
            let supported: Bool
        }

        struct TrustACCStatus: EvcamMsgType {
            let trust: Bool
        }

        struct AudioPrompts: EvcamMsgType {
            let enabled: Bool
        }

        struct Attitude: EvcamMsgType {
            let isConfigurable: Bool
            let attitude: WLEvcamDeviceAttitude
        }

        struct ProtectionVoltage: EvcamMsgType {
            /// 11700~12200. For 24v, x2.
            let mv: Int
        }

        struct ParkSleepDelay: EvcamMsgType {
            /// seconds. default 30. 30, 60, 120, 300, 600.
            let delayInSec: Int
        }

        struct LTEInformation: EvcamMsgType {
            let version: String
            let version_internal: String
            let iccid: String
            let apn: String
        }

        struct LTEStatus: EvcamMsgType, Encodable {
            let sim: String
            let cereg: String
            let cops: String
            let network: String
            let band: String
            let signal: String
            let csq: String
            let cellinfo: String
            let ip: String
            let ping8888: String // "yes" or "no"
            let connected: String // "yes" or "no"
        }

        struct HdrMode: EvcamMsgType {
            let mode: WLCameraHDRMode
        }

        struct KeepAliveForApp: EvcamMsgType {
            let keepAlive: Bool
        }

        struct PowerState: EvcamMsgType {
            let status: String
            let online: Bool
            let level: String
            let percent: Int
            let mv: Int

            func asDictionary() -> [String : Any] {
                return [
                    WLBatteryInfoKeys.capacityLevel.rawValue : level,
                    WLBatteryInfoKeys.voltageNow.rawValue : "\(mv)",
                    WLBatteryInfoKeys.status.rawValue : status,
                    WLBatteryInfoKeys.online.rawValue : online ? 1 : 0,
                    WLBatteryInfoKeys.capacity.rawValue : percent
                ]
            }
        }

        struct DebugProp: EvcamMsgType {
            let prop: String
            let val: String
        }

        struct HotspotInfo: EvcamMsgType {
            let ssid: String
            let key: String
        }

        struct ObdMode: EvcamMsgType, Encodable {
            let mode: Int //mv
            let von: Int //mv
            let voff: Int //mv
            let vchk: Int //mv
        }
    }

    struct Camera {
        struct RecordConfigList: EvcamMsgType {
            let items: [WLEvcamRecordConfigListItem]

            enum CodingKeys: String, CodingKey {
                case items = "recordConfigList"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                items = try container.decode([WLEvcamRecordConfigListItem].self, forKey: .items)
            }
        }

        struct RecordConfig: EvcamMsgType, Encodable {
            let minBitrateFactor: Int // minimal bitrate factor that's allowed
            let maxBitrateFactor: Int // maximal bitrate factor that's allowed
            let recordConfig: String // current record-config name
            let bitrateFactor: Int // current bitrate factor
            let forceCodec: Int // force Codec encoding. 0: auto, 1: h264, 2: h265
        }

        struct RecordMode: EvcamMsgType {
            let autoRecord: Bool
            let autoDelete: Bool
        }

        struct VideoOverlay: EvcamMsgType {
            let showLogo: Bool
            let showName: Bool
            let showTime: Bool
            let showGPS: Bool
            let showSpeed: Bool
            let useMPH: Bool
        }

        struct State: EvcamMsgType {
            let state: WLRecordState
            /*let isBuffering: Bool*/
            let recordLength: Int
            let tfState: String

            enum CodingKeys: String, CodingKey {
                case state
                /*case isBuffering*/
                case recordLength
                case tfState
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                state = WLRecordState(stringValue: try container.decode(String.self, forKey: .state)) ?? .num

                /*isBuffering = try container.decode(Bool.self, forKey: .isBuffering)*/
                recordLength = try container.decode(Int.self, forKey: .recordLength)
                tfState = try container.decode(String.self, forKey: .tfState)
            }
        }

        struct MarkState: EvcamMsgType {
            let state: EvcamMarkState
            let before: Int
            let after: Int
        }

        struct StorageSpaceInfo: EvcamMsgType {
            let totalSpace: Int64
            let usedSpace: Int64
            let markedClipSpace: Int64
            let clipSpace: Int64
            let canStartRecord: Bool
        }

        struct MarkSettings: EvcamMsgType {
            let gsensorBefore: Int
            let gsensorAfter: Int
            let maxClipsForGsensor: Int
            let manualBefore: Int
            let manualAfter: Int
        }

        struct RecordError: EvcamMsgType {
            let reason: EvcamRecordErrorReason
        }

        struct VinMirror: EvcamMsgType {
            let vinMirrorList: [String]
        }

        struct MaxMarkSpace: EvcamMsgType {
            let list: [Int]
            let max: Int
        }
        
        struct AdasCfg: EvcamMsgType, Encodable {
            let enable: Bool //ADAS_Enabled
            let fcw: Double //ForwardCollisionTTC
            let fcwr: Int //ForwardCollisionTR
            let hdw: Double //HeadwayMonitorTTC
            let hdwr: Int //HeadwayMonitorTR
            let cht: Double //CameraHeight
            let vwt: Double //VehicleWidth
            let rtc: Double? //RightOffsetToCenter
        }
        
        struct VtIgtCfg: EvcamMsgType, Encodable { // virtual ignition config
            let enable : Bool
        }
        
        struct AuxCfg: EvcamMsgType, Encodable { // virtual ignition config
            let model : Int // 0=NA;1=ecm02(aux);2=ecm01(dms)
            let angle: Int // degree index: 0 = normal, 1 = 90, 2 = 180, 3 = 270
            let plug: Int // 0=NA;1=ecm02(aux);2=ecm01(dms)
        }
    }

    static func decode(_ typeName: String, category: EvcamCategory, from data: Data) -> EvcamMsgType? {
        func decode<T: Decodable>(_ type: T.Type) -> T? {
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                Log.error("Failed to decode EvcamMsgType data: \(error)")
            }

            return nil
        }

        switch typeName {
        /* Device */
        case String(describing: EvcamMsg.Device.DeviceInfo.self):
            return decode(EvcamMsg.Device.DeviceInfo.self)
        case String(describing: EvcamMsg.Device.PowerOff.self):
            return decode(EvcamMsg.Device.PowerOff.self)
        case String(describing: EvcamMsg.Device.Reboot.self):
            return decode(EvcamMsg.Device.Reboot.self)
        case String(describing: EvcamMsg.Device.FactoryReset.self):
            return decode(EvcamMsg.Device.FactoryReset.self)
        case String(describing: EvcamMsg.Device.Time.self):
            return decode(EvcamMsg.Device.Time.self)
        case String(describing: EvcamMsg.Device.Name.self):
            return decode(EvcamMsg.Device.Name.self)
        case String(describing: EvcamMsg.Device.DateTimeFormat.self):
            return decode(EvcamMsg.Device.DateTimeFormat.self)
        case String(describing: EvcamMsg.Device.TransferFirmware.self):
            return decode(EvcamMsg.Device.TransferFirmware.self)
        case String(describing: EvcamMsg.Device.TransferFile.self):
            return decode(EvcamMsg.Device.TransferFile.self)
        case String(describing: EvcamMsg.Device.PlayFile.self):
            return decode(EvcamMsg.Device.PlayFile.self)
        case String(describing: EvcamMsg.Device.DisplayFile.self):
            return decode(EvcamMsg.Device.DisplayFile.self)
        case String(describing: EvcamMsg.Device.UserFileList.self):
            return decode(EvcamMsg.Device.UserFileList.self)
        case String(describing: EvcamMsg.Device.TFState.self):
            return decode(EvcamMsg.Device.TFState.self)
        case String(describing: EvcamMsg.Device.MicState.self):
            return decode(EvcamMsg.Device.MicState.self)
        case String(describing: EvcamMsg.Device.SpeakerState.self):
            return decode(EvcamMsg.Device.SpeakerState.self)
        case String(describing: EvcamMsg.Device.GPSState.self):
            return decode(EvcamMsg.Device.GPSState.self)
        case String(describing: EvcamMsg.Device.WifiInfo.self):
            return decode(EvcamMsg.Device.WifiInfo.self)
        case String(describing: EvcamMsg.Device.BlueToothInfo.self):
            return decode(EvcamMsg.Device.BlueToothInfo.self)
        case String(describing: EvcamMsg.Device.BlueToothScanResult.self):
            return decode(EvcamMsg.Device.BlueToothScanResult.self)
        case String(describing: EvcamMsg.Device.LCDBrightness.self):
            return decode(EvcamMsg.Device.LCDBrightness.self)
        case String(describing: EvcamMsg.Device.ScreenSaverTimeout.self):
            return decode(EvcamMsg.Device.ScreenSaverTimeout.self)
        case String(describing: EvcamMsg.Device.GsensorSensitivity.self):
            return decode(EvcamMsg.Device.GsensorSensitivity.self)
        case String(describing: EvcamMsg.Device.Event.self):
            return decode(EvcamMsg.Device.Event.self)
        case String(describing: EvcamMsg.Device.CameraLog.self):
            return decode(EvcamMsg.Device.CameraLog.self)
        case String(describing: EvcamMsg.Device.CameraDebugLog.self):
            return decode(EvcamMsg.Device.CameraDebugLog.self)
        case String(describing: EvcamMsg.Device.WiFiKey.self):
            return decode(EvcamMsg.Device.WiFiKey.self)
        case String(describing: EvcamMsg.Device.ServerUrl.self):
            return decode(EvcamMsg.Device.ServerUrl.self)
        case String(describing: EvcamMsg.Device.MountVersion.self):
            return decode(EvcamMsg.Device.MountVersion.self)
        case String(describing: EvcamMsg.Device.IgnitionMode.self):
            return decode(EvcamMsg.Device.IgnitionMode.self)
        case String(describing: EvcamMsg.Device.AccelDetectLevel.self):
            return decode(EvcamMsg.Device.AccelDetectLevel.self)
        case String(describing: EvcamMsg.Device.MwSensitivity.self):
            return decode(EvcamMsg.Device.MwSensitivity.self)
        case String(describing: EvcamMsg.Device.DriveBehaviourDetect.self):
            return decode(EvcamMsg.Device.DriveBehaviourDetect.self)
        case String(describing: EvcamMsg.Device.P2pInfo.self):
            return decode(EvcamMsg.Device.P2pInfo.self)
        case String(describing: EvcamMsg.Device.SupportWlanMode.self):
            return decode(EvcamMsg.Device.SupportWlanMode.self)
        case String(describing: EvcamMsg.Device.TrustACCStatus.self):
            return decode(EvcamMsg.Device.TrustACCStatus.self)
        case String(describing: EvcamMsg.Device.AudioPrompts.self):
            return decode(EvcamMsg.Device.AudioPrompts.self)
        case String(describing: EvcamMsg.Device.Attitude.self):
            return decode(EvcamMsg.Device.Attitude.self)
        case String(describing: EvcamMsg.Device.ProtectionVoltage.self):
            return decode(EvcamMsg.Device.ProtectionVoltage.self)
        case String(describing: EvcamMsg.Device.ParkSleepDelay.self):
            return decode(EvcamMsg.Device.ParkSleepDelay.self)
        case String(describing: EvcamMsg.Device.LTEInformation.self):
            return decode(EvcamMsg.Device.LTEInformation.self)
        case String(describing: EvcamMsg.Device.LTEStatus.self):
            return decode(EvcamMsg.Device.LTEStatus.self)
        case String(describing: EvcamMsg.Device.HdrMode.self):
            return decode(EvcamMsg.Device.HdrMode.self)
        case String(describing: EvcamMsg.Device.PowerState.self):
            return decode(EvcamMsg.Device.PowerState.self)
        case String(describing: EvcamMsg.Device.KeepAliveForApp.self):
            return decode(EvcamMsg.Device.KeepAliveForApp.self)
        case String(describing: EvcamMsg.Device.DebugProp.self):
            return decode(EvcamMsg.Device.DebugProp.self)
        case String(describing: EvcamMsg.Device.HotspotInfo.self):
            return decode(EvcamMsg.Device.HotspotInfo.self)
        case String(describing: EvcamMsg.Device.ObdMode.self):
            return decode(EvcamMsg.Device.ObdMode.self)
        /* Camera */
        case String(describing: EvcamMsg.Camera.RecordConfigList.self):
            return decode(EvcamMsg.Camera.RecordConfigList.self)
        case String(describing: EvcamMsg.Camera.RecordConfig.self):
            return decode(EvcamMsg.Camera.RecordConfig.self)
        case String(describing: EvcamMsg.Camera.RecordMode.self):
            return decode(EvcamMsg.Camera.RecordMode.self)
        case String(describing: EvcamMsg.Camera.VideoOverlay.self):
            return decode(EvcamMsg.Camera.VideoOverlay.self)
        case String(describing: EvcamMsg.Camera.State.self):
            return decode(EvcamMsg.Camera.State.self)
        case String(describing: EvcamMsg.Camera.MarkState.self):
            return decode(EvcamMsg.Camera.MarkState.self)
        case String(describing: EvcamMsg.Camera.StorageSpaceInfo.self):
            return decode(EvcamMsg.Camera.StorageSpaceInfo.self)
        case String(describing: EvcamMsg.Camera.MarkSettings.self):
            return decode(EvcamMsg.Camera.MarkSettings.self)
        case String(describing: EvcamMsg.Camera.RecordError.self):
            return decode(EvcamMsg.Camera.RecordError.self)
        case String(describing: EvcamMsg.Camera.VinMirror.self):
            return decode(EvcamMsg.Camera.VinMirror.self)
        case String(describing: EvcamMsg.Camera.MaxMarkSpace.self):
            return decode(EvcamMsg.Camera.MaxMarkSpace.self)
        case String(describing: EvcamMsg.Camera.AdasCfg.self):
            return decode(EvcamMsg.Camera.AdasCfg.self)
        case String(describing: EvcamMsg.Camera.VtIgtCfg.self):
            return decode(EvcamMsg.Camera.VtIgtCfg.self)
        case String(describing: EvcamMsg.Camera.AuxCfg.self):
            return decode(EvcamMsg.Camera.AuxCfg.self)
        default:
            break
        }

        return nil
    }
}

struct EvcamProtocolHeader: CustomStringConvertible {
    enum Configs {
        static let protocolKey = "Protocol: "
        static let textLengthKey = "TextLength: "
        static let binaryLengthKey = "BinaryLength: "
        static let endOfLine = "\r\n"
    }
    
    var stringRange: NSRange? = nil
    
    var protocolName = "EVCAM 1.0"
    var textLength: Int = 0
    var binaryLength: Int = 0
    
    var description: String {
        return "\(Configs.protocolKey)\(protocolName)\(Configs.endOfLine)\(Configs.textLengthKey)\(textLength)\(Configs.endOfLine)\(Configs.binaryLengthKey)\(binaryLength)\(Configs.endOfLine)\(Configs.endOfLine)"
    }
    
    init(textLength: Int = 0, binaryLength: Int = 0) {
        self.textLength = textLength
        self.binaryLength = binaryLength
    }
    
    func dataRepresentation() -> Data {
        return description.evcamData!
    }
}

typealias EvcamJSONObject = Any

public class WLEvcamCmd: NSObject {
    private(set) var category: EvcamCategory
    private(set) var cmd: String
    private(set) var param: EvcamJSONObject

    override public var description: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted]

        do {
            var dict: [String : Any] = [:]
            Mirror(reflecting: self).children.forEach { (child) in
                if let label = child.label {
                    if let value = child.value as? EvcamCategory {
                        dict[label] = value.rawValue
                    } else {
                        dict[label] = child.value
                    }
                }
            }

            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = jsonData.evcamString
            return jsonString ?? ""
        } catch {
            Log.info(error.localizedDescription)
        }
        
        return ""
    }

    init(category: EvcamCategory, cmd: String, param: EvcamJSONObject = [:]) {
        self.category = category
        self.cmd = cmd
        self.param = param
    }
    
    public func dataRepresentation() -> Data {
        return description.evcamData!
    }
    
    public func lengthOfBytes() -> Int {
        return description.evcamLength
    }
}

@objc public class WLEvcamCmdGenerator: NSObject {
    
    @objc public static func setConfigSettingMK(_ settings: [String : Any] , cmd : String) -> WLEvcamCmd {
        
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: cmd, param: settings)
    }
    
    @objc public static func getConfigSettingMK(cmd : String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: cmd)
    }
    
    //////////////////// Device ////////////////////
    
    @objc public static func factoryReset() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "factoryReset")
    }
    
    @objc public static func formatTF() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "formatTF")
    }
    
    @objc public static func getDateTimeFormat() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getDateTimeFormat")
    }
    
    @objc public static func getDeviceInfo() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getDeviceInfo")
    }
    
    @objc public static func getName() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getName")
    }
    
    @objc public static func getTime() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getTime")
    }

    @objc public static func setTime(_ time: Int64, gmtOffset: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setTime", param: ["time" : time, "gmtoff": gmtOffset])
    }
    
    @objc public static func getGPSState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getGPSState")
    }
    
    @objc public static func getGsensorSensitivity() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getGsensorSensitivity")
    }
    
    @objc public static func getLCDBrightness() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getLCDBrightness")
    }

    @objc public static func getMicState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getMicState")
    }

    /// volume: 1 to 9
    @objc public static func setMicState(muted: Bool, volume: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setMicState", param: ["muted" : muted, "volumn" : volume])
    }
    
    @objc public static func getSpeakerState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getSpeakerState")
    }
    
    @objc public static func getTFState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getTFState")
    }
    
    @objc public static func getWifiInfo() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getWifiInfo")
    }

    @objc public static func getWiFiKey() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getWiFiKey")
    }

    @objc public static func powerOff() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "powerOff")
    }
    
    @objc public static func reboot() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "reboot")
    }
    
    @objc public static func setDateTimeFormat(dateFormat: String, timeFormat: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setDateTimeFormat", param: ["dateFormat" : dateFormat, "timeFormat" : timeFormat])
    }
    
    @objc public static func setName(_ name: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setName", param: ["name" : name])
    }
    
    @objc public static func transferFirmware(size: Int, md5: String, reboot: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "transferFirmware", param: ["size" : size, "md5" : md5, "reboot" : reboot])
    }
    
    static func setGsensorSensitivity(sensitivity: EvcamGsensorSensitivity) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setGsensorSensitivity", param: ["sensitivity" : sensitivity.stringValue])
    }

    @objc public static func setSpeakerState(muted: Bool, volum: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setSpeakerState", param: ["muted" : muted, "volumn" : volum])
    }
    
    @objc public static func setWifiMode(mode: String, multiRoleMode: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setWifiMode", param: ["mode" : mode, "multiRoleMode" : multiRoleMode])
    }

    @objc public static func getBlueToothInfo() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getBlueToothInfo")
    }

    @objc public static func scanBlueToothDevices() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "scanBlueToothDevices")
    }

    @objc public static func setBlueToothEnable(enable: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setBlueToothEnable", param: ["enable" : enable])
    }

    @objc public static func bindBlueToothDevice(type: String, mac: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "bindBlueToothDevice", param: ["type" : type, "mac" : mac])
    }

    @objc public static func unbindBlueToothDevice(type: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "unbindBlueToothDevice", param: ["type" : type])
    }

    @objc public static func unmountTF() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "unmountTF")
    }

    @objc public static func getUserFileList() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getUserFileList")
    }

    @objc public static func transferFile(parentDir: String, fileName: String, size: Int, md5: String) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.device,
            cmd: "transferFile",
            param: [
                "parentDir" : parentDir,
                "filename" : fileName,
                "size" : size,
                "md5" : md5
            ]
        )
    }

    @objc public static func getAttitude() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getAttitude")
    }

    @objc public static func setAttitude(_ attitude: WLEvcamDeviceAttitude) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setAttitude", param: ["attitude" : attitude.stringValue])
    }

    @objc public static func getLTEInformation() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getLTEInformation")
    }

    @objc public static func getMountVersion() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getMountVersion")
    }

    @objc public static func getMountSettings() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getMountSettings")
    }

    @objc public static func setMountSettings(_ settings: [String : Any]) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setMountSettings", param: settings)
    }

    @objc public static func getIgnitionMode() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getIgnitionMode")
    }

    @objc public static func getServerUrl() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getServerUrl")
    }

    @objc public static func setServerUrl(_ url: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setServerUrl", param: ["url" : url])
    }

    @objc public static func getLTEStatus() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getLTEStatus")
    }

    @objc public static func getKeepAliveForApp() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getKeepAliveForApp")
    }

    @objc public static func setKeepAliveForApp(_ keepAlive: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setKeepAliveForApp", param: ["keepAlive" : keepAlive])
    }

    @objc public static func keepAliveForApp() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "keepAliveForApp")
    }

    @objc public static func getSupportWlanMode() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getSupportWlanMode")
    }

    @objc public static func getDriveBehaviourDetect() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getDriveBehaviourDetect")
    }

    @objc public static func getAccelDetectLevel() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getAccelDetectLevel")
    }

    @objc public static func setAccelDetectLevel(_ level: String, params: String? = nil) -> WLEvcamCmd {
        var param: [String : Any] = ["level" : level]

        if let params = params {
            param["params"] = params
        }

        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setAccelDetectLevel", param: param)
    }

    @objc public static func getProtectionVoltage() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getProtectionVoltage")
    }

    /// - Parameter mv: 11700~12200
    @objc public static func setProtectionVoltage(_ mv: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setProtectionVoltage", param: ["mv" : mv])
    }

    @objc public static func getParkSleepDelay() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getParkSleepDelay")
    }

    @objc public static func setParkSleepDelay(_ delayInSec: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setParkSleepDelay", param: ["delayInSec" : delayInSec])
    }

    @objc public static func getTrustACCStatus() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getTrustACCStatus")
    }

    @objc public static func setTrustACCStatus(_ trust: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setTrustACCStatus", param: ["trust" : trust])
    }

    @objc public static func setDriveBehaviourDetectParams(_ param: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setDriveBehaviourDetectParams", param: ["param" : param])
    }

    @objc public static func getAudioPrompts() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getAudioPrompts")
    }

    @objc public static func setAudioPrompts(enabled: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setAudioPrompts", param: ["enabled" : enabled])
    }

    @objc public static func getMWSensitivity() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getMWSensitivity")
    }

    /// - Parameter level: [1, 10]
    @objc public static func setMWSensitivity(level: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setMWSensitivity", param: ["level" : level])
    }

    @objc public static func setDriveBehaviourDetectEnabled(_ enabled: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setDriveBehaviourDetectEnabled", param: ["enabled" : enabled])
    }

    @objc public static func setAPN(_ apn: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setAPN", param: ["apn" : apn])
    }

    @objc public static func getCameraLog(value : String) -> WLEvcamCmd {
        if value.isEmpty {
            return WLEvcamCmd(category: EvcamCategory.device, cmd: "getCameraLog")
        } else {
            return WLEvcamCmd(category: EvcamCategory.device, cmd: "getCameraLog", param: ["param":value])
        }
       
    }
    
    @objc public static func getCameraDebugLog() -> WLEvcamCmd{
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getDebugReportLog")
    }

    @objc public static func getP2PInfo() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getP2PInfo")
    }

    @objc public static func setP2PEnable(_ enabled: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setP2PEnable", param: ["enabled" : enabled])
    }

    @objc public static func removeP2PDevice(_ deviceMac: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "removeP2PDevice", param: ["device" : deviceMac])
    }

    @objc public static func getPowerState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getPowerState")
    }

    @objc public static func setDebugProp(_ prop: String, val: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setDebugProp", param: ["prop" : prop, "val" : val])
    }

    @objc public static func getDebugProp(_ prop: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getDebugProp", param: ["prop" : prop])
    }

    @objc public static func setHotspotInfo(_ ssid: String, password: String) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setHotspotInfo", param: ["ssid" : ssid, "key" : password])
    }

    @objc public static func getObdMode() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "getObdMode")
    }

    @objc public static func setObdMode(_ mode: Int, voltageOn: Int, voltageOff: Int, voltageCheck: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.device, cmd: "setObdMode", param: ["mode" : mode, "von" : voltageOn, "voff": voltageOff, "vchk" : voltageCheck])
    }
    
    //////////////////// Camera ////////////////////
    
    @objc public static func getMarkSettings() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getMarkSettings")
    }
    
    @objc public static func getMarkState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getMarkState")
    }
    
    @objc public static func getState() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getState")
    }
    
    @objc public static func getRecordConfig() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getRecordConfig")
    }
    
    @objc public static func getRecordConfigList() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getRecordConfigList")
    }
    
    @objc public static func getRecordMode() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getRecordMode")
    }
    
    @objc public static func getStorageSpaceInfo() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getStorageSpaceInfo")
    }
    
    @objc public static func getVideoOverlay() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getVideoOverlay")
    }
    
    @objc public static func manualMarkClip() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "manualMarkClip")
    }
    
    @objc public static func setGsensorMarkSettings(gsensorBefore: Int, gsensorAfter: Int, maxClipsForGsensor: Int) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.camera,
            cmd: "setGsensorMarkSettings",
            param: [
                "gsensorBefore" : gsensorBefore,
                "gsensorAfter" : gsensorAfter,
                "maxClipsForGsensor" : maxClipsForGsensor
            ]
        )
    }
    
    @objc public static func setManualMarkSettings(manualBefore: Int, manualAfter: Int) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.camera,
            cmd: "setManualMarkSettings",
            param: [
                "manualBefore" : manualBefore,
                "manualAfter" : manualAfter
            ]
        )
    }
    
    /// - Parameters:
    ///   - recordConfig: record-config name
    ///   - bitrateFactor: bitrate factor multiplied by 100. For example, 120 is 1.2 times of the normal bitrate.
    ///   - forceCode: force Codec encoding. 0: auto, 1: h264, 2: h265
    @objc public static func setRecordConfig(_ recordConfig: String, bitrateFactor: Int, forceCodec: Int) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.camera,
            cmd: "setRecordConfig",
            param: [
                "recordConfig" : recordConfig,
                /*"bitrateFactor" : bitrateFactor,*/
                "forceCodec" : forceCodec
            ]
        )
    }
    
    /// - Parameters:
    ///   - autoRecord: auto record on power on and tf ready
    ///   - autoDelete: auto delete clips when space is low
    @objc public static func setRecordMode(autoRecord: Bool, autoDelete: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setRecordMode", param: ["autoRecord" : autoRecord, "autoDelete" : autoDelete])
    }
    
    /// - Parameters:
    ///   - useMPH: use mph for speed
    @objc public static func setVideoOverlay(showLogo: Bool, showName: Bool, showTime: Bool, showGPS: Bool, showSpeed: Bool, useMPH: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.camera,
            cmd: "setVideoOverlay",
            param: [
                "showLogo" : showLogo,
                "showName" : showName,
                "showTime" : showTime,
                "showGPS" : showGPS,
                "showSpeed" : showSpeed,
                "useMPH" : useMPH
            ]
        )
    }
    
    @objc public static func startRecord() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "startRecord")
    }
    
    @objc public static func stopRecord() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "stopRecord")
    }

    @objc public static func getVinMirror() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getVinMirror")
    }

    @objc public static func setVinMirror(_ vinMirrorList: [String]) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setVinMirror", param: ["vinMirrorList" : vinMirrorList])
    }

    @objc public static func getMaxMarkSpace() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getMaxMarkSpace")
    }

    /// - Parameter max: in GB
    @objc public static func setMaxMarkSpace(max: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setMaxMarkSpace", param: ["max" : max])
    }

    @objc public static func getHDRMode() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getHDRMode")
    }

    @objc public static func setHDRMode(_ mode: WLCameraHDRMode) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setHDRMode", param: ["mode" : mode.stringValue])
    }
    
    @objc public static func getAdasConfig() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getAdasCfg")
    }

    @objc public static func setAdasConfig(_ config: [String : Any]) -> WLEvcamCmd {
        return WLEvcamCmd(
            category: EvcamCategory.camera,
            cmd: "setAdasCfg",
            param: config
        )
    }
    
    @objc public static func getVirtualIgnitionConfig() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getVtIgtCfg")
    }

    @objc public static func setVirtualIgnitionConfig(enable: Bool) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setVtIgtCfg", param: ["enable" : enable])
    }
    
    @objc public static func getAuxConfig() -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "getAuxCfg")
    }
    
    @objc public static func setAuxConfig(angle: Int) -> WLEvcamCmd {
        return WLEvcamCmd(category: EvcamCategory.camera, cmd: "setAuxCfg", param: ["angle" : angle])
    }
}

@objc class EvcamMsgObject: NSObject, Decodable {
    var category: EvcamCategory
    var name: String
    var body: [String : Any] = [:]
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
        case name = "msg"
        case body = "body"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = EvcamCategory(rawValue: try container.decode(String.self, forKey: .category)) ?? .unknown
        name = try container.decode(String.self, forKey: .name)

        body = try container.decode([String: Any].self, forKey: .body)
    }
}

@objc public class WLEvcamMsgParser: NSObject {
    
    private lazy var dataBuffer: Data = Data()
    
    @objc public func appendData(_ data: Data) {
        dataBuffer.append(data)
    }
    
    @objc public func parse() -> [Any] {
        var msgObjects: [Any] = []
        
        var position: Int = 0
        var tmpData: Data = Data()
        
        var protocolName: String?
        var textData: Data?
        var binary: Data?
        var headerUpperBound: Int?
        var textLength: Int = 0
        var binaryLength: Int = 0
        
        var lastIntactMsgUpperBound: Int?
        
        while position != dataBuffer.count {
            let theByte = dataBuffer[position]
            let theChar = theByte.char
            
            if theChar == "\r", position < dataBuffer.count - 1, dataBuffer[position + 1].char == "\n" {
                let line = tmpData.evcamString
                
                if let line = line, line.contains(EvcamProtocolHeader.Configs.protocolKey) {
                    protocolName = tmpData[EvcamProtocolHeader.Configs.protocolKey.count..<tmpData.count].evcamString
                }
                else if let line = line, line.contains(EvcamProtocolHeader.Configs.textLengthKey), let textLengthString = tmpData[EvcamProtocolHeader.Configs.textLengthKey.count..<tmpData.count].evcamString {
                    textLength = Int(textLengthString) ?? 0
                }
                else if let line = line, line.contains(EvcamProtocolHeader.Configs.binaryLengthKey), let binaryLengthString = tmpData[EvcamProtocolHeader.Configs.binaryLengthKey.count..<tmpData.count].evcamString {
                    binaryLength = Int(binaryLengthString) ?? 0
                }
                else {
                    if tmpData.isEmpty && protocolName != nil { //done an intact header proccess
                        headerUpperBound = position + 1
                    }
                }

                tmpData.removeAll()
                position += 1
            } else {
                if let notNilHeaderUpperBound = headerUpperBound {
                    let intactMsgUpperBound = notNilHeaderUpperBound + textLength + binaryLength
                    if intactMsgUpperBound < dataBuffer.count {
                        if textLength > 0 {
                            textData = dataBuffer[position...(position + textLength - 1)]
                        }
                        if binaryLength > 0 {
                            binary = dataBuffer[(position + textLength)...intactMsgUpperBound]
                        }

                        if let data = textData, let msgObject = parseSingleMsg(data) {
                            msgObjects.append(msgObject)
                        }
                        
                        lastIntactMsgUpperBound = notNilHeaderUpperBound + textLength + binaryLength
                        
                        protocolName = nil
                        textLength = 0
                        textData = nil
                        binaryLength = 0
                        binary = nil
                        headerUpperBound = nil
                        tmpData.removeAll()

                        position = lastIntactMsgUpperBound!
                    }
                }
                
                tmpData.append(theByte)
            }
            position += 1
        }
        
        if let lastIntactMsgUpperBound = lastIntactMsgUpperBound {
            dataBuffer.removeSubrange(Range(NSRange(location: 0, length: lastIntactMsgUpperBound + 1))!)
        }
    
        return msgObjects
    }
    
    private func parseSingleMsg(_ data: Data) -> Any? {
        let decoder = JSONDecoder()
        do {
            
          
            Log.info("CameraClient Receive Msg:\n\(String(data: data, encoding: .utf8) ?? "parse failed")")

            let msgObject = try decoder.decode(EvcamMsgObject.self, from: data)

            if let bodyJsonData = msgObject.body.jsonData,
                let msg = EvcamMsg.decode(msgObject.name.wl.capitalizingFirstLetter(), category: msgObject.category, from: bodyJsonData) {
                return msg
            }

            return msgObject
        } catch {
            Log.info("EvcamMsgParser error: \(error)")
        }
        
        return nil
    }
    
}

@objc public final class WLEvcamRecordConfigListItem: NSObject, Codable {
    @objc public var name: String
    @objc public var bitrate: Int
    
    public init(name: String, bitrate: Int) {
        self.name = name
        self.bitrate = bitrate
    }

    enum CodingKeys: String, CodingKey {
        case name
        case bitrate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(bitrate, forKey: .bitrate)
    }
    
}
