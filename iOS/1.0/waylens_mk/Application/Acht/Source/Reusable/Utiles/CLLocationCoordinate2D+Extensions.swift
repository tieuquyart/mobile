//
//  CLLocationCoordinate2D+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/10/23.
//  Copyright © 2019 waylens. All rights reserved.
//

extension CLLocationCoordinate2D {

    var description: String {
        return "\(String(format: "%.6f", latitude)), \(String(format: "%.6f", longitude))"
    }

    func correctedForChina() -> CLLocationCoordinate2D {
        if GPSHelper.out(ofChina: self) {
            return self
        } else {
            return GPSHelper.gms84(toGCJ02: self)
        }
    }

    func convertedToWgsCoordinate() -> CLLocationCoordinate2D {
        return GPSHelper.gcj02(toWgs84: self)
    }

}

extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        return "\(longitude),\(latitude)".hashValue
    }
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return abs(lhs.longitude - rhs.longitude) < 0.000000001 && abs(lhs.latitude - rhs.latitude) < 0.000000001
    }
}

extension CLLocationCoordinate2D {
    func coarseGrained(precision:UInt=4) -> CLLocationCoordinate2D {
        let divisor = pow(10.0, Double(precision))
        let lat = round(latitude * divisor) / divisor
        let lon = round(longitude * divisor) / divisor
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
