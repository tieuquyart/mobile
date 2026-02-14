//
//  RemoteCamera.swift
//  Acht
//
//  Created by gliu on 9/1/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation

import CoreLocation
import AlamofireImage
import WaylensFoundation
import WaylensCameraSDK

class RemoteCamera {
    //basic info
    let sn: String
    var name: String
    var isOnline = false
    var onlineStatusChangeTime: Date?
    var thumbnailTime: Date?
    var thumbnailUrl: String?
    // settings
    var parkingConfig: CameraModeConfig?
    var drivingConfig: CameraModeConfig?
    var monitoring: Bool {
        return true // todo: get from state
    }
    var monitoringOffOnce: Bool {
        return false
    }
    //    var nightVision: HNFeatureStatus?
    var logoLed: HNFeatureStatus?
    var siren: HNFeatureStatus?
    // state
    var firmware: String?
    var firmwareShort: String?
    var engineStatus: HNFeatureStatus?
    var powerSource: HNPowerSource?
    var batteryCharging: Bool?
    var batteryRemaining: Int?
    var batteryStatus: HNBatteryStatus? {
        guard let remaining = batteryRemaining else {
            return nil
        }
        if remaining < 30 {
            return .low
        } else if remaining < 60 {
            return .medium
        } else if remaining < 95 {
            return .plenty
        } else {
            return .full
        }
    }
    var mode: HNCameraMode?
    var cellSignalInfo: HNCellSignalInfo?
    var uploadingSpeedBitps: Int?
    var offlineReason: String?
    var location: WLLocation?
    var gpsStatus: HNFeatureStatus?
    var obdStatus: HNFeatureStatus?
    var remoteControlStatus: HNFeatureStatus?
    var model: String?
    var productionSerie : WLProductSerie?
    var mountHwModel: String?
    var mountFwVersion: String?
    var mountCode: Int?
    var supports4g: Bool?
    var longLived: Bool?
    var cacheTime: Date?
    var subscription: DataSubscription?
    var hadSubscription: Bool = false
    var iccid: String?
    //    var imei: String?
    var modem: String?
    var facedown: Bool = false
    
    var lastActiveTime: Date? {
        return laterDate(laterDate(thumbnailTime, onlineStatusChangeTime), cacheTime)
    }
    
    var liveStatusTimer: WLTimer?
    var liveStatus: HNLiveStatus?
    var liveUrl: String?
    var ownerUserId: String?
    var dict: [String: Any]
    var pendingSettings = CameraSettings()
    var settingsTimer: WLTimer?
    
#if FLEET
    var onlineStatusChangeHandler: (() -> Void)? = nil
    var firmwareToUpgradeInfo: FirmwareToUpgradeInfo?
#endif
    
    private func laterDate(_ da:Date?, _ db:Date?) -> Date? {
        if let da = da, let db = db {
            return da > db ? da : db
        }
        return da ?? db
    }
    
    private lazy var heartBeatTimer: WLTimer = WLTimer(reference: self, interval: 3.0, repeat: true, block: { [weak self] in
        self?.heartBeat()
    })
    
    init(dict: [String: Any]) {
        self.dict = dict
#if FLEET
        sn = dict["serialNumber"] as! String
        
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            name = sn
        }
#else
        sn = dict["sn"] as! String
        name = dict["name"] as? String ?? "Waylens Secure360"
#endif
        update(dict: dict)
    }
    
    func update(dict:[String: Any]) {
#if FLEET
        model ??= dict["hardwareVersion"] as? String
        iccid ??= dict["iccid"] as? String
        firmware ??= dict["firmware"] as? String
        firmwareShort ??= dict["firmwareShort"] as? String
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()
        firmwareToUpgradeInfo ??= FirmwareToUpgradeInfo(dict: dict["firmwareToUpgrade"] as? [String : Any])
        isOnline ??= dict["isOnline"] as? Bool
        productionSerie = WLCameraDevice.determineProductSerie(with: model)
        /*
         if AccountControlManager.shared.isLogin, UserSetting.current.userProfile?.roles.contains(.fleetManager) == true {
         WaylensClientS.shared.fetchCameraOnlineStatus(sn, completion: { [weak self] (result) in
         switch result {
         case .success(let dict):
         self?.updateOnlineStatus(dict)
         default:
         break
         }
         })
         }
         */
#else
        name ??= dict["name"] as? String
        ownerUserId ??= dict["ownerUserId"] as? String
        isOnline ??= dict["isOnline"] as? Bool
        model ??= dict["hardwareVersion"] as? String
        supports4g ??= dict["is4G"] as? Bool
        productionSerie = WLCameraDevice.determineProductSerie(with: model)
        
        if let value = dict["_timestamp"] as? Double {
            cacheTime = Date(timeIntervalSince1970: value)
        }
        if let value = dict["onlineStatusChangeTime"] ?? dict["offlineTime"] ?? dict["onlineTime"] {
            onlineStatusChangeTime = Date(timeIntervalSince1970: value as! TimeInterval/1000)
        }
        if let value = dict["thumbnailUrl"] {
            thumbnailUrl = value as? String
        }
        if let value = dict["thumbnailTime"] {
            thumbnailTime = Date(timeIntervalSince1970: value as! TimeInterval/1000)
        }
        if let gps = dict["gps"] as? [String: Any], let address = dict["location"] as? [String: Any] {
            location = WLLocation(coordinate: gps, address: address)
        }
        
        if let value = dict["_4gSignal"] as? [String: Any] {
            cellSignalInfo ??= HNCellSignalInfo.from(dict: value)
        }
        
        if let value = dict["settings"] as? [String: Any] {
            if let subDict = value["parkingMode"] as? [String: Any] {
                parkingConfig = CameraModeConfig(dict: subDict)
            }
            if let subDict = value["drivingMode"] as? [String: Any] {
                drivingConfig = CameraModeConfig(dict: subDict)
            }
            logoLed = HNFeatureStatus(rawValue: value["logoLED"] as? String ?? "")
            siren = HNFeatureStatus(rawValue: value["siren"] as? String ?? "")
        }
        
        if let value = dict["state"] as? [String: Any] {
            mode ??= HNCameraMode(rawValue: value["mode"] as? String ?? "")
            firmware ??= value["firmware"] as? String
            firmwareShort ??= value["firmwareShort"] as? String
            engineStatus ??= HNFeatureStatus(rawValue: value["engineStatus"] as? String ?? "")
            powerSource = HNPowerSource(rawValue: value["poweredBy"] as? String ?? "")
            batteryCharging ??= value["batteryCharging"] as? Bool
            batteryRemaining ??= value["batteryRemaining"] as? Int
            uploadingSpeedBitps ??= value["bps"] as? Int
            offlineReason ??= value["offlineReason"] as? String
            gpsStatus ??= HNFeatureStatus(rawValue: value["gpsStatus"] as? String ?? "")
            obdStatus ??= HNFeatureStatus(rawValue: value["obdStatus"] as? String ?? "")
            remoteControlStatus ??= HNFeatureStatus(rawValue: value["remoteControlStatus"] as? String ?? "")
            //            imei ??= value["imei"] as? String
            modem ??= value["modem"] as? String
            
            if let info = value["mountInfo"] as? [String: Any] {
                mountCode ??= info["code"] as? Int
                mountHwModel ??= info["mountHWVersion"] as? String
                mountFwVersion ??= info["mountFWVersion"] as? String
                longLived ??= info["longLived"] as? Bool
            }
            
        }
        
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue() // Maybe "normal" or "upsidedown"
        
        updateSubscription(dict)
#endif
    }
    
    func updateSubscription(_ dict: [String: Any]) {
        if let iccid = dict["iccid"] as? String {
            self.iccid = iccid
        } else {
            self.iccid = ""
        }
        var total:Int64 = 0
        var used: Int64 = 0
        if let current = dict["currentSubCycle"] as? [String: Any] {
            total = current["totalQuotaInKB"] as? Int64 ?? 0
            used = current["ctdDataUsageInKB"] as? Int64 ?? 0
        }
        var expireAt: Date?
        var name: String?
        if let endTimestamp = dict["subscriptionEnded"] as? Double {
            expireAt =  Date(timeIntervalSince1970: endTimestamp / 1000)
        }
        if let sub = dict["currentRatePlanSubscription"] as? [String: Any] {
            name = sub["ratePlanName"] as? String
        }
        subscription = DataSubscription(state: DataSubscription.State.from(string: (dict["dataPlanStatus"] ?? dict["status"]) as? String) , totalQuataInKB: total, usedInKB: used, expirationDate: expireAt, name: name)
        if let state = subscription?.state {
            hadSubscription = state != .none
        }
    }
    
    func startLive(completion: completionBlock?) {
        liveStatus = nil
        //        WaylensClientS.shared.startLive(sn) { [weak self] (result) in
        //            guard self != nil, self?.liveStatus == nil else {
        //                return
        //            }
        //            if result.isSuccess {
        ////                var url = result.value!["url"] as! String
        ////                if let token = result.value!["playToken"] as? String {
        ////                    url += "?" + token
        ////                }
        //                self?.liveUrl = result.value?["playUrl"] as? String
        //                completion?(result)
        //                self?.heartBeatTimer.start()
        //            } else {
        //                completion?(result)
        //            }
        //        }
        
        FleetViewService.shared.start_live(cameraSn: sn, completion: { [weak self] (result) in
            
            guard self != nil, self?.liveStatus == nil else {
                return
            }
            if result.isSuccess {
                let data = result.value!["data"] as? [String : Any]
                self?.liveUrl = data?["playUrl"] as? String
                completion?(result)
                self?.heartBeatTimer.start()
            } else {
                completion?(result)
            }
            
        })
        
        
    }
    
    
    //    func live_status(completion: completionBlock?) {
    //        liveStatus = nil
    //
    //
    //        FleetViewService.shared.live_status(cameraSn: sn, completion: { [weak self] (result) in
    //
    //            switch result {
    //            case .success(let value):
    //                if let status = value["status"] as? String {
    //
    //                    return
    //                }
    //                if let url = value["playUrl"] as? String {
    //                    self?.liveUrl = url
    //                    completion?(result)
    //                    self?.heartBeatTimer.start()
    //                }
    //            case .failure(let _):
    //                print("Failed to error start live")
    //               // HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Update", comment: "Failed to Update"), to: self?.navigationController)
    //            }
    //
    //
    //
    //        })
    //
    //
    //    }
    
    func stopLive() {
        if heartBeatTimer.isValid {
            WaylensClientS.shared.stopLive(sn, completion: nil)
        }
        heartBeatTimer.stop()
        liveStatusTimer?.stop()
        liveUrl = nil
        liveStatus = .stopped
    }
    
    func getLiveStatus(progress:@escaping (HNLiveStatus)->Void) {
        liveStatusTimer = WLTimer(reference: self, interval: 0.5, repeatTimes: 120) { [unowned self] in
            if self.liveStatusTimer?.remainingCount == 0 {
                self.liveStatus = .timeout
                progress(.timeout)
                return
            }
            
            
            FleetViewService.shared.live_status(cameraSn: sn, completion: { [unowned self] (result) in
                
                if result.isSuccess, let data = result.value!["data"] as? [String : Any] , let status = HNLiveStatus(rawValue: data["status"] as! String) {
                    
                    if let url = data["playUrl"] as? String {
                        self.liveUrl = url
                    }
                    
                    if self.liveStatus != status {
                        self.liveStatus = status
                        progress(status)
                        if status == .streaming || status.shouldStop {
                            self.liveStatusTimer?.stop()
                        }
                    }
                    
                } else {
                    
                    if result.error?.asAPIError == .cameraOffline {
                        self.liveStatus = .offline
                        progress(.offline)
                    }
                    
                    // fetch status failed
                }
                
                
            })
            
            
        }
        liveStatusTimer?.start()
    }
    
#if FLEET
    private func updateOnlineStatus(_ dict: [String: Any]) {
        isOnline ??= dict["isOnline"] as? Bool
        mode ??= HNCameraMode(rawValue: dict["mode"] as? String ?? "")
        
        if let rsrp = dict["RSRP"] as? Float, let band = dict["Band"] as? String, let dlearfcn = dict["DLEarfcn"] as? Int {
            let value: [String : Any] = ["RSRP" : rsrp, "Band" : band, "DLEarfcn" : dlearfcn]
            cellSignalInfo ??= HNCellSignalInfo.from(dict: value)
        }
        
        if let gps = dict["lastGps"] as? [String: Any], let coordinate = gps["coordinate"] as? [Double], coordinate.count >= 3/*, let address = dict["location"] as? [String: Any]*/ {
            location = WLLocation(coordinate: ["longitude" : coordinate[0], "latitude" : coordinate[1]], address: nil)
        }
        
        onlineStatusChangeHandler?()
    }
#endif
    
    private func heartBeat() {
        if liveStatus == .streaming {
            
            FleetViewService.shared.upload_status(cameraSn: sn) { [unowned self] (result) in
                if result.isSuccess {
                    if let dict = result.value {
#if FLEET
                        let data = dict["data"] as? [String : Any]
                        self.uploadingSpeedBitps = data!["bytesInRate"] as? Int
#else
                        self.uploadingSpeedBitps = dict["bps"] as? Int
#endif
                    }
                }
            }
        }
    }
    
    func getThumbnail(size: CGSize?=nil, completion: @escaping (UIImage?)->Void) {
        if let urlString = thumbnailUrl, let url = URL(string: urlString) {
            CacheManager.shared.imageFetcher.get(url).onSuccess(completion)
        } else {
            completion(nil)
        }
    }
    
    func setName(_ name: String) {
        let oldName = self.name
        self.name = name
        WaylensClientS.shared.updateCameraName(sn, name: name) { [weak self] (result) in
            if result.isFailure {
                self?.name = oldName
            }
        }
    }
    
#if FLEET
    func commitSettings(of cameraInstallationMode: CameraInstallationMode, completion: completionBlock?) {
        WaylensClientS.shared.updateSettings(
            sn,
            settings: ["rotate" : cameraInstallationMode.toParameterValue()],
            completion: completion
        )
    }
#else
    func commitSettings() {
        let dict = pendingSettings.dict
        if settingsTimer == nil {
            settingsTimer = WLTimer(reference: self, interval: 60, repeat: false, block: { [weak self] in
                self?.onSettingsTimeOut()
            })
        }
        if !dict.isEmpty && pendingSettings.status == .pending {
            self.pendingSettings.status = .updating
            WaylensClientS.shared.updateSettings(sn, settings: dict, completion: { [weak self] (result) in
                if result.isSuccess {
                    self?.settingsTimer?.stop()
                    self?.settingsTimer?.start()
                } else {
                    self?.pendingSettings.status = .failed
                }
            })
        }
    }
#endif
    
    func onSettingsUpdated() {
        self.settingsTimer?.stop()
        if pendingSettings.status == .updating {
            clearPendingSettings()
        }
    }
    
    func onSettingsTimeOut() {
        if pendingSettings.status == .updating {
            clearPendingSettings()
            NotificationCenter.default.post(name: Notification.Name.Remote.settingsUpdateTimeOut, object: sn)
        }
    }
    
    func clearPendingSettings() {
        pendingSettings = CameraSettings()
    }
}
