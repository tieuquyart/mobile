//
//  HNLiveDataMonitor.swift
//  Acht
//
//  Created by Chester Shen on 11/9/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import CoreLocation
import WaylensPiedPiper
import WaylensFoundation
import WaylensCameraSDK

protocol HNLiveDataMonitorDelegate: NSObjectProtocol {
    func onLive(obd: obd_raw_data_v2_t?)
    func onLive(acc: iio_raw_data_t?)
    func onLive(gps: CLLocation?)
    func onLive(dms: readsense_dms_data_v2_t?)
    func onLiveES(dmsData: WLDmsData?)
}

class HNLiveDataMonitor:NSObject {
    weak var camera: WLCameraDevice?
    weak var delegate : HNLiveDataMonitorDelegate?
    var rawGPSInfo: gps_raw_data_v3_t?
    //var rawDMSInfo: readsense_dms_data_t?
    var gpsLocation: CLLocation?
    var lastUpdateTime: TimeInterval = 0
    var isUpdating: Bool = false
    var location: WLLocation? {
        didSet {
            if location != nil {
                let interval = Date().timeIntervalSince1970 - lastUpdateTime
                if interval > 1.0 {
                    camera?.notifyUpdate()
                    lastUpdateTime += interval
                }
            }
        }
    }
    var gpsReady: Bool = false {
        didSet {
            if gpsReady != oldValue {
                camera?.notifyUpdate()
            }
        }
    }
    var gpsSignalLostTimer: WLTimer?
    let gpsSignalLostInterval:TimeInterval = 5.0
    var dmsSignalLostTimer: WLTimer?
    let dmsSignalLostInterval:TimeInterval = 1.0
    var dmsUpdating = false
    
    init(with cam: WLCameraDevice) {
        camera = cam
    }
    
    func start(gps: Bool, dms: Bool) {
        camera?.vdbClient.liveDelegate = self
        camera?.vdbClient.dmsLiveDelegate = self

        if gps {
            camera?.doRequireLiveRawData(withACC: false, gps: true, obd: false)
        }
        if dms {
            camera?.doRequireLiveDMS(true)
        }
        dmsUpdating = true
    }
    
    func stop() {
        camera?.doRequireLiveRawData(withACC: false, gps: false, obd: false)
        dmsUpdating = false
        camera?.doRequireLiveDMS(false)
        camera?.vdbClient.liveDelegate = nil
        camera?.vdbClient.dmsLiveDelegate = nil
        gpsSignalLostTimer?.stop()
        gpsSignalLost()
        dmsSignalLostTimer?.stop()
        dmsSignalLost()
    }
}

extension WLLocation {
    mutating func update(with gpsInfo: gps_raw_data_v3_t) {
        let location = CLLocation(latitude: gpsInfo.latitude, longitude: gpsInfo.longitude)
        self.coordinate = location.coordinate
        self.horizontalAccuracy = Double(gpsInfo._hdop) / 100 // convert to precision in meters
        self.verticalAccuracy = Double(gpsInfo._vdop) / 100
        self.speed = Double(gpsInfo.speed)
    }
}

extension HNLiveDataMonitor: WLCameraLiveDelegate, WLDmsCameraLiveDelegate {
    func onLiveRSDMS(_ data: Data?) {
        if (dmsUpdating == false && data == nil) { return }

        guard data!.count >= MemoryLayout<readsense_dms_data_t>.size else { return }
        var dms_v2 = readsense_dms_data_v2_t()

        if data!.count >= MemoryLayout<readsense_dms_data_v2_t>.size {
            dms_v2 = data!.withUnsafeBytes({ (bytes) -> readsense_dms_data_v2_t in
                return bytes.load(as: readsense_dms_data_v2_t.self)
            })
        } else {
//            faceInfo = nil
            dms_v2.v1 = data!.withUnsafeBytes({ (bytes) -> readsense_dms_data_t in
                return bytes.load(as: readsense_dms_data_t.self)
            })
        }

        //rawDMSInfo = dmsInfo
        delegate?.onLive(dms :dms_v2)
        resetDMSTimer()
    }

    func onLiveESDMS(_ dmsData: WLDmsData?) {
        delegate?.onLiveES(dmsData: dmsData)
        resetDMSTimer()
    }

    func onLiveGPS(_ data: Data) {
        guard data.count == MemoryLayout<gps_raw_data_v3_t>.size else { return }

        let gpsInfo = data.withUnsafeBytes { (bytes) -> gps_raw_data_v3_t in
            return bytes.load(as: gps_raw_data_v3_t.self)
        }

        if gpsInfo._hdop < 9999 && gpsInfo._hdop > 0 { // not from cache and is valid
            rawGPSInfo = gpsInfo
            let previous_location = gpsLocation
            gpsLocation = CLLocation(latitude: gpsInfo.latitude, longitude: gpsInfo.longitude)
            gpsReady = true
            guard let current = gpsLocation else { return }
            let distance = previous_location?.distance(from: current) ?? 100000
            let interval = Date().timeIntervalSince1970 - lastUpdateTime
            if distance > 50.0 && interval > 1.0 && !isUpdating {
                // update address
                isUpdating = true
                CacheManager.shared.locationCache.get(current.coordinate.coarseGrained())
                    .onCompletion({ [weak self] (result) in
                        self?.isUpdating = false
                        switch result {
                        case .success(let value):
                            var loc = value
                            loc.update(with: gpsInfo)
                            self?.location = loc
                        default:
                            break
                        }
                    })
            } else if distance > 10.0, self.location != nil {
                var location = self.location
                location?.update(with: gpsInfo)
                self.location = location
            }
            resetGPSTimer()
        }
    }
    
    func resetGPSTimer() {
        gpsSignalLostTimer?.stop()
        gpsSignalLostTimer = WLTimer(reference: self, interval: gpsSignalLostInterval, repeat: false, block: {
            [weak self] in
            self?.gpsSignalLost()
        })
        gpsSignalLostTimer?.start()
    }
    
    func gpsSignalLost() {
        location = nil
        gpsLocation = nil
        gpsReady = false
        delegate?.onLive(gps: nil)
    }
    func resetDMSTimer() {
        dmsSignalLostTimer?.stop()
        dmsSignalLostTimer = WLTimer(reference: self, interval: dmsSignalLostInterval, repeat: false, block: {
            //[weak self] in
            self.dmsSignalLost()
        })
        dmsSignalLostTimer?.start()
    }

    func dmsSignalLost() {
        //rawDMSInfo = nil
        delegate?.onLive(dms: nil)
    }
    
    func onLiveOBD(_ data: Data) {}
    
    func onLiveACC(_ data: Data) {}
}
