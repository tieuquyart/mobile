//
//  WLCameraClient+Evcam.swift
//  Hachi
//
//  Created by forkon on 2018/12/17.
//  Copyright © 2018 Transee. All rights reserved.
//

import Foundation
import WaylensFoundation
//import WaylensCameraSDK_Internal

extension WLCameraClient {
    
    private struct AssociatedKeys {
        static var evcamMsgParserKey: UInt8 = 88
        static var isFormatingSDCardKey: UInt8 = 8
    }

    @objc public var evcamMsgParser: WLEvcamMsgParser {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.evcamMsgParserKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let parser = objc_getAssociatedObject(self, &AssociatedKeys.evcamMsgParserKey) as? WLEvcamMsgParser {
                return parser
            } else {
                let newParser = WLEvcamMsgParser()
                self.evcamMsgParser = newParser
                return newParser
            }
        }
    }

    private var isFormatingSDCard: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isFormatingSDCardKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isFormatingSDCardKey) as? Bool) ?? false
        }
    }
    
    @objc public func send(_ cmd: WLEvcamCmd) {
        send(cmd, attachedData: nil)
    }
    
    @objc public func send(_ cmd: WLEvcamCmd, attachedData: Data?) {
        send(cmd, attachedData: attachedData, withTimeout: 15 * 60)
    }
    
    @objc public func send(_ cmd: WLEvcamCmd, withTimeout sec: Double) {
        send(cmd, attachedData: nil, withTimeout: sec)
    }
    
    @objc public func send(_ cmd: WLEvcamCmd, attachedData: Data?, withTimeout sec: Double) {
        let header = EvcamProtocolHeader(
            textLength: cmd.lengthOfBytes(),
            binaryLength: attachedData != nil ? attachedData!.count : 0
        )
        
        print("\(header)")
        print("\(cmd)")

        send(header.dataRepresentation(), withTimeout: sec)
        send(cmd.dataRepresentation(), withTimeout: sec)
        
        if let attachedData = attachedData {
            send(attachedData, withTimeout: sec)
        }
    }
    
    @objc public func handleMsg(_ msg: Any) {
        print("msg thanh",msg)
        switch msg {
        /* Device */
          
        case let msg as EvcamMsg.Device.Name:
            cameraClientDelegate.onCameraName(UnsafeMutablePointer<Int8>(mutating: (msg.name as NSString).utf8String))

        case let msg as EvcamMsg.Device.LCDBrightness:
            let brightnessConverted = Int32(round(max(1.0, Float(msg.brightness) / 255.0 * 10.0)))
            cameraClientDelegate.onGetDisplayBrightness(brightnessConverted)

        case let msg as EvcamMsg.Device.MicState:
            cameraClientDelegate.onMicEnabled(!msg.muted, volume: Int32(msg.volumn))

        case let msg as EvcamMsg.Device.DeviceInfo:
            cameraClientDelegate.onGetApiVersion(UnsafeMutablePointer<Int8>(mutating: (msg.api as NSString).utf8String))
            cameraClientDelegate.onCurrentDevice(msg.sn, fw: msg.build, hardware: msg.model)

        case let msg as EvcamMsg.Device.ScreenSaverTimeout:
            cameraClientDelegate.onGetDisplayAutoOffTime(WLEvcamScreenSaverTime(rawValue: msg.timeout)?.stringValue ?? WLEvcamScreenSaverTime.never.stringValue)

        case let msg as EvcamMsg.Device.SpeakerState:
            cameraClientDelegate.onGetSpeakerStatus(!msg.muted, volume: Int32(msg.volumn))

        case let msg as EvcamMsg.Device.TransferFirmware:
            cameraClientDelegate.onTransferFirmware(Int32(msg.state.intValue), size: 0, progress: Int32(msg.progress ?? 0), errorCode: Int32(0))

        case let msg as EvcamMsg.Device.WifiInfo:
            cameraClientDelegate.onGetWiFiMode(Int32(Wifi_Mode(evcamWifiMode: msg.mode).rawValue), ssid: msg.ssid)

        case let msg as EvcamMsg.Device.WiFiKey:
            cameraClientDelegate.onGetKey(msg.key)

        case let msg as EvcamMsg.Device.BlueToothInfo:
            cameraClientDelegate.ongetBTInfo(withSupported: msg.supported,
                                              enabled: msg.enabled,
                                              scanning: msg.isScanning,
                                              obdStatus: msg.OBD.status,
                                              obdName: msg.OBD.name ?? "NA",
                                              obdMac: msg.OBD.mac ?? "NA",
                                              hidStatus: msg.HID.status,
                                              hidName: msg.HID.name ?? "NA",
                                              hidMac: msg.HID.mac ?? "NA",
                                              hidBatLev: Int32(msg.HID.level ?? 0))
        case let msg as EvcamMsg.Device.BlueToothScanResult:
            cameraClientDelegate.onBTDevScanDone(0, withList: msg.dict)

        case let msg as EvcamMsg.Device.Attitude:
            cameraClientDelegate.onGetSupportUpsideDown(msg.isConfigurable)
            cameraClientDelegate.onGetAttitude(msg.attitude == .upsidedown)

        case let msg as EvcamMsg.Device.Time:
            cameraClientDelegate.onGetDevieTime(Int32(msg.time), timeZone: Int32(msg.gmtoff))

        case let msg as EvcamMsg.Device.MountVersion:
            if let dict = try? msg.asDictionary() {
                cameraClientDelegate.onGetMountVersion(dict)
            }

        case let msg as EvcamMsg.Device.IgnitionMode:
            cameraClientDelegate.onGetMonitorMode(msg.mode)

        case let msg as EvcamMsg.Device.HdrMode:
            cameraClientDelegate.onGet(msg.mode)

        case let msg as EvcamMsg.Device.ServerUrl:
            Log.info("Camera Server: \(msg.url)")
            cameraClientDelegate.onGet360Server(msg.url)

        case let msg as EvcamMsg.Device.LTEInformation:
            cameraClientDelegate.onGetICCID(msg.iccid)
            cameraClientDelegate.onGetLTEFirmwareVersionPublic(msg.version, internal: msg.version_internal)
            cameraClientDelegate.onGetAPN(msg.apn)

        case let msg as EvcamMsg.Device.LTEStatus:
            if let dict = try? msg.asDictionary() {
                cameraClientDelegate.onGetLTEStatus(dict)
            }
        case let msg as EvcamMsg.Device.KeepAliveForApp:
            cameraClientDelegate.onGetAppKeepAlive(msg.keepAlive)

        case let msg as EvcamMsg.Device.AccelDetectLevel:
            cameraClientDelegate.onGetMountAccelLevels(msg.levels.map{$0.stringValue}, current: msg.level.stringValue)

            if let params = msg.params {
                cameraClientDelegate.onGetMountAccelParam(params)
            }

        case let msg as EvcamMsg.Device.SupportWlanMode:
            cameraClientDelegate.onGetSupportWlanMode(msg.supported)

        case let msg as EvcamMsg.Device.DriveBehaviourDetect:
            cameraClientDelegate.onGetSupportRiskDriveEvent(msg.enabled)
            if let jsonData = try? JSONSerialization.data(withJSONObject: msg.param, options: []), let jsonString = String(data: jsonData, encoding: .utf8) {
                cameraClientDelegate.onGetIIOEventDetectionParam(jsonString)
            }

        case let msg as EvcamMsg.Device.ProtectionVoltage:
            cameraClientDelegate.onGetProtectionVoltage(Int32(msg.mv))

        case let msg as EvcamMsg.Device.ParkSleepDelay:
            cameraClientDelegate.onGetParkSleepDelay(Int32(msg.delayInSec))

        case let msg as EvcamMsg.Device.TrustACCStatus:
            cameraClientDelegate.onGetMountACCTrust(msg.trust)

        case let msg as EvcamMsg.Device.TFState:
            Log.info("onStorageState:\(msg.state) format:\(msg.system_id)");

            cameraClientDelegate.onStorageState(WLStorageState(tfState: msg.state), format: msg.system_id)

            if isFormatingSDCard {
                if msg.state == .ready {
                    isFormatingSDCard = false
                    cameraClientDelegate.onFormatTFCard(true)
                }
                else if msg.state == .error {
                    isFormatingSDCard = false
                    cameraClientDelegate.onFormatTFCard(false)
                }
            } else {
                isFormatingSDCard = (msg.state == .formatting)
            }

        case let msg as EvcamMsg.Device.AudioPrompts:
            cameraClientDelegate.onGetAudioPromptEnabled(msg.enabled)

        case let msg as EvcamMsg.Device.CameraLog:

            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getCameraLog"), object: msg.ready == 1 ? true : false, userInfo: nil)
           cameraClientDelegate.onCopyLog(msg.ready == 1 ? true : false)
            
        case let msg as EvcamMsg.Device.CameraDebugLog:

            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getCameraLog"), object: msg.ready == 1 ? true : false, userInfo: nil)
            cameraClientDelegate.onCopyDebugLog(msg.ready == 1 ?  true : false)

        case let msg as EvcamMsg.Device.MwSensitivity:
            cameraClientDelegate.onGetRadarSensitivity(Float(msg.level))

        case let msg as EvcamMsg.Device.PowerState:
            cameraClientDelegate.onPowerSupplyState(msg.online ? 1 : 0)
            cameraClientDelegate.onBatteryInfo(msg.asDictionary(), percentage: Int32(msg.percent))

        case let msg as EvcamMsg.Device.DebugProp:
            Log.info("onDebugProp: \(msg)")
            cameraClientDelegate.onDebugProp(msg.prop, value: msg.val)

        case let msg as EvcamMsg.Device.HotspotInfo:
            cameraClientDelegate.onSetHotspotInfo(withSsid: msg.ssid, andPassword: msg.key)

        case let msg as EvcamMsg.Device.ObdMode:
            Log.info("onGetObdWorkModeConfig: \(msg)")

            if let configDict = try? msg.asDictionary(), let config = WLObdWorkModeConfig(dictionary: configDict) {
                cameraClientDelegate.onGet(config)
            }
            
//        case let msg as EvcamMsg.Device.P2pInfo:
//            break
//
//        case let msg as EvcamMsg.Device.PowerOff:
//            break
//
//        case let msg as EvcamMsg.Device.Reboot:
//            break
//
//        case let msg as EvcamMsg.Device.FactoryReset:
//            break
//
//        case let msg as EvcamMsg.Device.Event:
//            break
//
//        case let msg as EvcamMsg.Device.DateTimeFormat:
//            break

        /* Camera */

        case let msg as EvcamMsg.Camera.MarkState:
            if msg.state == .manual {
                cameraClientDelegate.onLiveMark(true)
            }

        case let msg as EvcamMsg.Camera.MarkSettings:
            cameraClientDelegate.onLiveMarkParam(Int32(msg.manualBefore), after: Int32(msg.manualAfter))

        case let msg as EvcamMsg.Camera.RecordMode:
            cameraClientDelegate.onCurrentRecMode(Int32(WLRecordMode(autoRecord: msg.autoRecord, autoDelete: msg.autoDelete).rawValue))

        case let msg as EvcamMsg.Camera.State:
            cameraClientDelegate.onRecordState(msg.state)
            cameraClientDelegate.onRecordingTime(UInt32(msg.recordLength))

        case let msg as EvcamMsg.Camera.StorageSpaceInfo:
            cameraClientDelegate.onStorageSpace(UInt64(msg.totalSpace), free: UInt64(msg.totalSpace - msg.usedSpace))

        case let msg as EvcamMsg.Camera.VideoOverlay:
            cameraClientDelegate.onOverlayInfoName(msg.showName, time: msg.showTime, posi: msg.showGPS, speed: msg.showSpeed)

        case let msg as EvcamMsg.Camera.MaxMarkSpace:
            cameraClientDelegate.onGetMarkStorageOptions(msg.list, current: Int32(msg.max))

        case let msg as EvcamMsg.Camera.RecordConfigList:
            cameraClientDelegate.onGetRecordConfigList(msg.items)

        case let msg as EvcamMsg.Camera.RecordConfig:
            if let dict = try? msg.asDictionary() {
                cameraClientDelegate.onGet(WLCameraRecordConfig(dictionary: dict))
            }

        case let msg as EvcamMsg.Camera.VinMirror:
            cameraClientDelegate.onGetVinMirror(msg.vinMirrorList)

//        case let msg as EvcamMsg.Camera.RecordError:
//            break

        case let msg as EvcamMsg.Camera.AdasCfg:
            Log.info("onGetAdasConfig: \(msg)")

            if let configDict = try? msg.asDictionary() {
                cameraClientDelegate.onGet(WLAdasConfig(dict: configDict))
            }
         
        case let msg as EvcamMsg.Camera.VtIgtCfg:
            Log.info("onGetVirtualIgnitionConfig: \(msg)")
            cameraClientDelegate.onGetVirtualIgnitionConfig(withEnable: msg.enable)
            
        case let msg as EvcamMsg.Camera.AuxCfg:
            Log.info("onGetAuxConfig: \(msg)")

            if let configDict = try? msg.asDictionary() {
                cameraClientDelegate.onGet(WLAuxConfig(dict: configDict))
            }
        
        default:
            if let msgObject = msg as? EvcamMsgObject {
            print("msgObject.name",msgObject.name)
                switch msgObject.name {
                case "cameraLog":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "cameraLog")
                    break
                case "cameraDebugLog":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "cameraDebugLog")
                    break
                case "mountSettings":
                    cameraClientDelegate.onGetMountConfig(msgObject.body)
                    break
                case "DriverInfoCfg":
                    print("DriverInfoCfg",msgObject.body)
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "DriverInfoCfg")
                    break
                case "setting_cfg":
                    print("setting_cfg",msgObject.body)
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "setting_cfg")
                    break
                case "in_out":
                    print("in_out",msgObject.body)
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "in_out")
                    break
                case "01":
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TCVN_01"), object: nil, userInfo: msgObject.body)
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "TCVN_01")
                    break
                case "02":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "TCVN_02")
                    break
                case "03":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "TCVN_03")
                    break
                case "04":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "TCVN_04")
                    break
                case "05":
                    cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "TCVN_05")
                    break
                    
                case "msgSimData":
                    print("msgSimData",msgObject.body)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgSimData"), object: nil, userInfo: msgObject.body)
                   // cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "msgSimData")
                    break
                 
                case "msgCarrier":
                    print("msgCarrier",msgObject.body)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgCarrier"), object: nil, userInfo: msgObject.body)
                   // cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "msgSimData")
                    break
                    
                    
                case "msgDataFW":
                  print("msgDataFW Call")
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgDataFW"), object: nil, userInfo: msgObject.body)
                    break

                case "msgFaceImage":
                  print("msgFaceImage Call")
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgFaceImage"), object: nil, userInfo: msgObject.body)
               break
                case "msg_MOC_method":
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msg_MOC_method"), object: nil, userInfo: msgObject.body)
                    break
//                case "msgFaceData":
//                  print("msgFaceImage Call")
//                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgFaceData"), object: nil, userInfo: msgObject.body)
//
                    // `default` is now a property, not a method call
                 //   cameraClientDelegate.onGetConfigSettingMK(msgObject.body, cmd: "msgFaceImage")
                default:
                    break
                }
            }
        }
    }
    
}
