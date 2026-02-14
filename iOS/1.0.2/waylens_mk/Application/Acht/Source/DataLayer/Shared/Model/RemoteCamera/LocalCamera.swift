//
//  LocalCamera.swift
//  Acht
//
//  Created by Chester Shen on 9/6/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import CoreLocation
import WaylensPiedPiper
import WaylensCarlos
import RxSwift
import WaylensFoundation
import WaylensCameraSDK

extension WLCameraDevice {
    private struct AK {
        static var vdbManager = "vdbManager"
        static var liveDataMonitor = "liveDataMonitor"
    }
    
    var vdbManager: WLVDBRequestManager? {
        get {
            var tmp = objc_getAssociatedObject(self, &AK.vdbManager) as? WLVDBRequestManager
            if tmp == nil && isConnected {
                tmp = WLVDBRequestManager(withVDB: vdbClient)
                objc_setAssociatedObject(self, &AK.vdbManager, tmp, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return tmp
        }
    }
    
    var liveDataMonitor: HNLiveDataMonitor? {
        var tmp = objc_getAssociatedObject(self, &AK.liveDataMonitor) as? HNLiveDataMonitor
        if tmp == nil && isConnected {
            tmp = HNLiveDataMonitor(with: self)
            objc_setAssociatedObject(self, &AK.liveDataMonitor, tmp, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return tmp
    }
    
    var mode: HNCameraMode {
        return isParking ? .parking : .driving
    }
    
    var parkingConfig: CameraModeConfig? {
        get {
            if let value = mountConfig as? [String: Any] {
                return CameraModeConfig(dict: value["parkingMode"] as! [String: Any])
            }
            return nil
        }
        set {
            var settings = CameraSettings()
            settings.parkingConfig = newValue
            mountConfig = settings.dict
        }
    }
    
    var drivingConfig: CameraModeConfig? {
        get {
            if let value = mountConfig as? [String: Any] {
                return CameraModeConfig(dict: value["drivingMode"] as! [String: Any])
            }
            return nil
        }
        set {
            var settings = CameraSettings()
            settings.drivingConfig = newValue
            mountConfig = settings.dict
        }
    }
    
    @objc var monitoring: Bool {
        get {
            return recState == .recording
        }
        set {
            if newValue {
                startRecord()
            } else {
                stopRecord()
            }
        }
    }
    var monitoringOffOnce: Bool {
        return false
    }
    
    var logoLed: HNFeatureStatus? {
        get {
            if let value = mountConfig as? [String: Any] {
                return HNFeatureStatus(rawValue: value["logoLED"] as? String ?? "")
            }
            return nil
        }
        set {
            var settings = CameraSettings()
            settings.logoLed = newValue
            mountConfig = settings.dict
        }
    }
    var siren: HNFeatureStatus? {
        get {
            if let value = mountConfig as? [String: Any] {
                return HNFeatureStatus(rawValue: value["siren"] as? String ?? "")
            }
            return nil
        }
        set {
            var settings = CameraSettings()
            settings.siren = newValue
            mountConfig = settings.dict
        }
    }
    
    var gpsStatus: HNFeatureStatus? {
        if let ready = liveDataMonitor?.gpsReady {
            return ready ? .on : .off
        }
        return nil
    }
    
    var batteryStatus: HNBatteryStatus? {
        if let level = batteryInfo?.capacityLevel {
            return HNBatteryStatus.from(string: level)
        }
        return nil
    }
    
    var powerSource: HNPowerSource? {
        if let mv = batteryInfo?.currentVoltage.value {
            return mv > 9000 ? .directWire : .cigarLighter
        }
        return nil
    }

    var cellSignalStatus: HNSignalStatus? {
        if  let lteInfo = lteInfo,
            let signals = (lteInfo["signal"] as? String)?.split(separator: ",") {
            if signals.count >= 3,
               let rsrp = Float(signals[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")) {
                return HNSignalStatus(db: rsrp)
            } else {
                return HNSignalStatus.no_signal
            }
        } else {
            return nil
        }
    }
    
    var accLevel: HNAccLevel? {
        if let raw = self.accelerometerLevel {
            return HNAccLevel(rawValue: raw)
        } else {
            return nil
        }
    }
    
    var videoQualityName: String? {
        if let qualityList = self.qualityList, self.quality.rawValue < qualityList.count {
            return (qualityList[Int(quality.rawValue)] as? WLCameraSettingsListItem)?.title
        } else {
            return nil
        }
    }
    
    var shouldFormat: Bool {
        if let format = self.format, !format.isEmpty && !format.hasPrefix("AGTS") {
            return true
        } else {
            return false
        }
    }
    
    private func searchGPS(forClip clip: WLVDBClip, offset: TimeInterval, precise: Bool) -> Future<CLLocation> {
        let promise = Promise<CLLocation>()
        if offset > clip.duration || offset > 300 {
            promise.fail(FetchError.noCacheLevelsRemaining)
            return promise.future
        }
        let time = clip.startTime + offset
        let gpsRequest = GPSCacheRequest(cameraID: sn!, clip: clip, pts: time)
        let result = CacheManager.shared.gpsCache.get(gpsRequest).filter { (location) -> Bool in
            return !precise || location.horizontalAccuracy < 99
        }
        promise.mimic(result.recover({ [weak self] () -> Future<CLLocation> in
            if let this = self {
                return this.searchGPS(forClip: clip, offset: offset + 10, precise: precise)
            } else {
                let nextPromise = Promise<CLLocation>()
                nextPromise.cancel()
                return nextPromise.future
            }
        }))
        return result.future
    }
    
    func getLocation(forClip clip:HNClip, completion: ((WLLocation?)->Void)?) {
        guard let rawclip = clip.rawClip else {
            completion?(nil)
            return
        }
        let offset: TimeInterval = rawclip.duration > 1 ? 1 : 0
        var gpsFuture: Future<CLLocation>?
        if clip.videoType.isParking {
            // find cached data
            gpsFuture = searchGPS(forClip: rawclip, offset: offset, precise: false)
        } else {
            gpsFuture = searchGPS(forClip: rawclip, offset: offset, precise: true)
                        .recover { [weak self]() -> Future<CLLocation> in
                            Log.verbose("Precise GPS not found for clip \(clip.clipID)")
                            if let this = self {
                                return this.searchGPS(forClip: rawclip, offset: offset, precise: false)
                            } else {
                                let nextPromise = Promise<CLLocation>()
                                nextPromise.cancel()
                                return nextPromise.future
                            }
                        }
        }
        gpsFuture?.onFailure { (_) in
                Log.verbose("Cached GPS not found for clip \(clip.clipID)")
                clip.location = WLLocation(coordinate: nil, address: nil)
                completion?(nil)
            }
            .flatMap { (location) -> Future<WLLocation> in
                Log.verbose("GPS found for clip \(clip.clipID): \(location)")
                clip.location = WLLocation(coordinate: location.coordinate, address: nil)
                return CacheManager.shared.locationCache.get(location.coordinate.coarseGrained())
                    .flatMap({ (wllocation) -> WLLocation? in
                        var result = wllocation
                        result.coordinate = location.coordinate
                        result.horizontalAccuracy = location.horizontalAccuracy
                        result.verticalAccuracy = location.verticalAccuracy
                        result.speed = location.speed
                        return result
                    })
            }
            .onSuccess { (location) in
                clip.location = location
                completion?(location)
            }
            .onFailure { (_) in
                completion?(nil)
            }
    }
    
    func dictForReport() -> [String: Any] {
        var d = [
            "hardwareVersion": hardwareModel,
            "settings": mountConfig,
            "rotate" : isUpsideDown ? CameraInstallationMode.lensDown.toParameterValue() : CameraInstallationMode.lensUp.toParameterValue(),
            "state": [
                "mode": mode.rawValue,
                "monitoring": monitoring ? "on" : "off",
                "poweredBy": powerSource?.rawValue,
                "batteryCharging": isCharging,
                //                "batteryRemaining": batteryStatus?.rawValue
                "gps": gpsStatus?.rawValue
                ] as [String: Any?]
            ] as [String : Any?]

        if let fwVersion = firmwareVersion, let apiVersion = apiVersion, let mountHwModel = mountHardwareModel, let mountFwVersion = mountFirmwareVersion {
            d["version"] = [
                "firmware": fwVersion,
                "api": apiVersion,
                "mount": [
                    "HW": mountHwModel,
                    "FW": mountFwVersion,
                    "is4G": isSupport4g
                ]
            ]
        }
        return d.dried()
    }
}
