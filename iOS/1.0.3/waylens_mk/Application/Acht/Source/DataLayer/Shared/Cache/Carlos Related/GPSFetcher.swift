//
//  GPSFetcher.swift
//  Acht
//
//  Created by Chester Shen on 1/4/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import WaylensPiedPiper
import WaylensCarlos
import CoreLocation
import WaylensCameraSDK

struct GPSCacheRequest: StringConvertible {
    let cameraID: String
    let clip: WLVDBClip
    let pts: TimeInterval
    var ptsInMs: Int64 {
        return Int64(pts * 1000)
    }
    func toString() -> String {
        return "gps-\(clip.clipID)-\(ptsInMs)"
    }
}

class GPSFetcher: Fetcher {
    typealias KeyType = GPSCacheRequest
    typealias OutputType = CLLocation
    
    func get(_ request: GPSCacheRequest) -> Future<CLLocation> {
        let promise = Promise<CLLocation>()
        if let vdbManager = UnifiedCameraManager.shared.cameraForSN(request.cameraID)?.local?.vdbManager {
            let vdbRequest = vdbManager.getGpsData(forClip: request.clip, atTime: request.pts, completion: { (result) in
                if result.isSuccess, let info = result.value as? gpsInfor_t {
                    let coordinate = CLLocationCoordinate2D(latitude: Double(info.latitude), longitude: Double(info.longitude))
                    let location = CLLocation(coordinate: coordinate, altitude: Double(info.altitude), horizontalAccuracy: Double(info.hdop) / 100.0, verticalAccuracy: Double(info.vdop) / 100.0, course: Double(info.orientation), speed: Double(info.speed), timestamp: Date(timeIntervalSince1970: Double(info.absoluteTime) / 1000.0))
                    promise.succeed(location)
                } else {
                    promise.fail(FetchError.valueNotInCache)
                }
            })
            promise.onCancel {
                vdbRequest.cancel()
            }
        } else {
            DispatchQueue.main.async {
                promise.fail(FetchError.noCacheLevelsRemaining)
            }
        }
        return promise.future
    }
}
