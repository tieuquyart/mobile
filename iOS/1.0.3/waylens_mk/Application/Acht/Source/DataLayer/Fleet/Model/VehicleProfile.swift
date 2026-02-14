//
//  VehicleProfile.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public typealias VehicleId = String

public struct VehicleProfile: Codable, Equatable {
    public var vehicleID: VehicleId?
    public var cameraSn: String
    public var plateNo: String
    public var type: String
    public var driverID: String?
    public var userID: String?
    public var name: String? // driver name
    public var verified: Bool?
    
    
    static var emptyProfile: VehicleProfile {
        return VehicleProfile(
             vehicleID: nil,
             cameraSn: "",
             plateNo: "",
             type:  "",
             driverID: nil,
             userID: nil,
             name: nil,
             verified: false
        )
    }
}
