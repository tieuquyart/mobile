//
//  TripModel.swift
//  Acht
//
//  Created by TranHoangThanh on 12/31/21.
//  Copyright © 2021 waylens. All rights reserved.
//


import Foundation

struct TripModel: Codable {

    let id: Int?
    let cameraSn: String?
    let cameraId: Int?
    let driverId: Int?
    let driverName: String?
    let vehicleId: Int?
    let vehiclePlate: String?
    let tripId: String?
    let distance: Int?
    let drivingTime: String?
    let parkingTime: String?
    let hours: Double?
    let createTime: String?
    let eventCount: Int?
    
    func drivingTimeToDate() ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: drivingTime!)!
        return date
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case cameraSn = "cameraSn"
        case cameraId = "cameraId"
        case driverId = "driverId"
        case driverName = "driverName"
        case vehicleId = "vehicleId"
        case vehiclePlate = "vehiclePlate"
        case tripId = "tripId"
        case distance = "distance"
        case drivingTime = "drivingTime"
        case parkingTime = "parkingTime"
        case hours = "hours"
        case createTime = "createTime"
        case eventCount = "eventCount"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int?.self, forKey: .id)
        cameraSn = try values.decode(String?.self, forKey: .cameraSn)
        cameraId = try values.decode(Int?.self, forKey: .cameraId)
        driverId = try values.decode(Int?.self, forKey: .driverId)
        driverName = try values.decode(String?.self, forKey: .driverName)
        vehicleId = try values.decode(Int?.self, forKey: .vehicleId)
        vehiclePlate = try values.decode(String?.self, forKey: .vehiclePlate)
        tripId = try values.decode(String?.self, forKey: .tripId)
        distance = try values.decode(Int?.self, forKey: .distance)
        drivingTime = try values.decode(String?.self, forKey: .drivingTime)
        parkingTime = try values.decode(String?.self, forKey: .parkingTime)
        hours = try values.decode(Double?.self, forKey: .hours)
        createTime = try values.decode(String?.self, forKey: .createTime)
        eventCount = try values.decode(Int?.self, forKey: .eventCount)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(cameraSn, forKey: .cameraSn)
        try container.encode(cameraId, forKey: .cameraId)
        try container.encode(driverId, forKey: .driverId)
        try container.encode(driverName, forKey: .driverName)
        try container.encode(vehicleId, forKey: .vehicleId)
        try container.encode(vehiclePlate, forKey: .vehiclePlate)
        try container.encode(tripId, forKey: .tripId)
        try container.encode(distance, forKey: .distance)
        try container.encode(drivingTime, forKey: .drivingTime)
        try container.encode(parkingTime, forKey: .parkingTime)
        try container.encode(hours, forKey: .hours)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(eventCount, forKey: .eventCount)
    }

}
