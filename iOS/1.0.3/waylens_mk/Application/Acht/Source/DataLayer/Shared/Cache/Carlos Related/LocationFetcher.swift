//
//  LocationFetcher.swift
//  Acht
//
//  Created by Chester Shen on 1/4/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import WaylensCarlos
import WaylensPiedPiper
import CoreLocation

extension CLLocationCoordinate2D: StringConvertible {
    public func toString() -> String {
        let lat = Int(round(latitude * 10000))
        let lon = Int(round(longitude * 10000))
        return "\(lat),\(lon)"
    }
}

extension CLLocationCoordinate2D: ExpensiveObject {
    public var cost: Int {
        return 1
    }
}

extension WLLocation: ExpensiveObject {
    var cost: Int {
        return 1
    }
}

class LocationFetcher: Fetcher {
    typealias KeyType = CLLocationCoordinate2D
    typealias OutputType = WLLocation
    func get(_ key: CLLocationCoordinate2D) -> Future<WLLocation> {
        let promise = Promise<WLLocation>()
        let dataRequest = WaylensClientS.shared.getAddress(longitude: Double(key.longitude), latitude: Double(key.latitude)) { (result) in
            if result.isSuccess, let dict = result.value?["address"] as? [String: Any]  {
                let address = WLLocation.Address(dict: dict)
                let location = WLLocation(coordinate: key, address: address)
                promise.succeed(location)
            } else {
                promise.fail(result.error ?? FetchError.valueNotInCache)
            }
        }
        promise.onCancel {
            dataRequest.cancel()
        }
        return promise.future
    }
}

//class LocationFetcher: Fetcher {
//    typealias  KeyType = CLLocationCoordinate2D
//    typealias OutputType = WLLocation
//    func get(_ key: CLLocationCoordinate2D) -> Future<WLLocation> {
//        let promise = Promise<WLLocation>()
//        let geoEncoder = CLGeocoder()
//        let corrected = key.correctedForChina()
//        let location = CLLocation(latitude: corrected.latitude, longitude: corrected.longitude)
//        geoEncoder.reverseGeocodeLocation(location) { (placemarks, error) in
//            if let placemark = placemarks?.first {
//                let wllocation = WLLocation(coordinate: key, address: WLLocation.Address(placemark: placemark))
//                promise.succeed(wllocation)
//            } else {
//                if let error = error {
//                    Log.error(error.localizedDescription)
//                }
//                promise.fail(error ?? FetchError.valueNotInCache)
//            }
//        }
//        promise.onCancel {
//            geoEncoder.cancelGeocode()
//        }
//        return promise.future
//    }
//}
