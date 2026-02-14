//
//  Vehicle.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import SwiftyJSON

public class Vehicle {
    public enum State: String, Comparable {
        case driving = "driving"
        case parking = "parking"
        case offline = "offline"

        public static func > (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.driving, .parking),
                 (.parking, .offline),
                 (.driving, .offline):
                return true
            default:
                return false
            }
        }

        public static func < (lhs: Vehicle.State, rhs: Vehicle.State) -> Bool {
            switch (lhs, rhs) {
            case (.parking, .driving),
                 (.offline, .parking),
                 (.offline, .driving):
                return true
            default:
                return false
            }
        }
    }

    public var cameraSN: String
    public let plateNumber: String
    public let type: String
    public let brand: String
    private(set) var state: Vehicle.State
    private(set) var coordinate: CLLocationCoordinate2D? = nil
    private(set) var isOnline: Bool = false

    public init(dict: [String : Any]) {
        self.state = Vehicle.State(rawValue: (dict["mode"] as? String) ?? "") ?? .offline
        self.cameraSN = (dict["cameraSn"] as? String) ?? ""
        print("camreraSN",cameraSN)
        self.plateNumber = (dict["plateNo"] as? String) ?? ""
        self.type = (dict["type"] as? String) ?? ""
        self.brand = (dict["brand"] as? String) ?? ""
        self.isOnline = dict["isOnline"] as? Bool ?? false
        
        if let gps = dict["gpsData"] as? JSON {
            if let coordinate = gps["coordinate"] as? [CLLocationDegrees] {
              
                let latitude = coordinate[1]
                let longitude = coordinate[0]
                print("latitude \(latitude) , longitude \(longitude)")
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude).correctedForChina()
            }
        }
        isOnline = (state != .offline)
    }

    public func updateStatus(with dict: [String : Any]) {
        if let gps = dict["gpsData"] as? JSON {
            if let coordinate = gps["coordinate"] as? [CLLocationDegrees] {
                let latitude = coordinate[1]
                let longitude = coordinate[0]
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude).correctedForChina()
            }
        }
        

        state = Vehicle.State(rawValue: (dict["mode"] as? String) ?? "") ?? .offline
        isOnline = (state != .offline)
    }
}

extension Array where Element == Vehicle {

    func count(of state: Vehicle.State) -> Int {
        return filter{$0.state == state}.count
    }

}
