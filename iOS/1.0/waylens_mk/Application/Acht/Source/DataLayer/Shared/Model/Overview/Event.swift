//
//  Event.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import DifferenceKit
import SwiftyJSON
import CoreFoundation
import Combine
import MapKit

public typealias EventType = HNVideoType

class Event : Codable {
    
    let id: Int?
    let clipId: String?
    let cameraSn: String?
    let driverId: Int?
    let driverLicense: String?
    let driverName: String?
    let vehicleId: Int?
    let plateNo: String?
    let eventType: EventType?
    let eventCategory: String?
    let eventLevel: String?
    let startTime: String?
    let duration: Int?
    let tripId: String?
    let gpsTime: String?
    let gpsSpeed: Double?
    let gpsHeading: Double?
    var gpsLongitude: Double?
    var gpsLatitude: Double?
    var coordinate : CLLocationCoordinate2D? = nil
    let gpsAltitude: Int?
    let gpsHdop: Int?
    let gpsVdop: Int?
    let fleetId: Int?
    let fleetName: String?
    let createTime: String?
    let updateTime: String?
    var url : String? = ""
    
    func createTimeToDate() ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: createTime!)!
        return date
    }

    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case clipId = "clipId"
        case cameraSn = "cameraSn"
        case driverId = "driverId"
        case driverLicense = "driverLicense"
        case driverName = "driverName"
        case vehicleId = "vehicleId"
        case plateNo = "plateNo"
        case eventType = "eventType"
        case eventCategory = "eventCategory"
        case eventLevel = "eventLevel"
        case startTime = "startTime"
        case duration = "duration"
        case tripId = "tripId"
        case gpsTime = "gpsTime"
        case gpsSpeed = "gpsSpeed"
        case gpsHeading = "gpsHeading"
        case gpsLongitude = "gpsLongitude"
        case gpsLatitude = "gpsLatitude"
        case gpsAltitude = "gpsAltitude"
        case gpsHdop = "gpsHdop"
        case gpsVdop = "gpsVdop"
        case fleetId = "fleetId"
        case fleetName = "fleetName"
        case createTime = "createTime"
        case updateTime = "updateTime"
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        clipId = try values.decodeIfPresent(String.self, forKey: .clipId)
        cameraSn = try values.decodeIfPresent(String.self, forKey: .cameraSn)
        driverId = try values.decodeIfPresent(Int.self, forKey: .driverId)
        driverLicense = try values.decodeIfPresent(String.self, forKey: .driverLicense)
        driverName = try values.decodeIfPresent(String.self, forKey: .driverName)
        vehicleId = try values.decodeIfPresent(Int.self, forKey: .vehicleId)
        plateNo = try values.decodeIfPresent(String.self, forKey: .plateNo)
        eventType = try EventType.from(string: values.decodeIfPresent(String.self, forKey: .eventType) ?? "")
        eventCategory = try values.decodeIfPresent(String.self, forKey: .eventCategory)
        eventLevel = try values.decodeIfPresent(String.self, forKey: .eventLevel)
        startTime = try values.decodeIfPresent(String.self, forKey: .startTime)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration)
        tripId = try values.decodeIfPresent(String.self, forKey: .tripId)
        gpsTime = try values.decodeIfPresent(String.self, forKey: .gpsTime)
        gpsSpeed = try values.decodeIfPresent(Double.self, forKey: .gpsSpeed)
        gpsHeading = try values.decodeIfPresent(Double.self, forKey: .gpsHeading)
        gpsLongitude = try values.decodeIfPresent(Double.self, forKey: .gpsLongitude)
        gpsLatitude = try values.decodeIfPresent(Double.self, forKey: .gpsLatitude)
        gpsAltitude = try values.decodeIfPresent(Int.self, forKey: .gpsAltitude)
        gpsHdop = try values.decodeIfPresent(Int.self, forKey: .gpsHdop)
        gpsVdop = try values.decodeIfPresent(Int.self, forKey: .gpsVdop)
        fleetId = try values.decodeIfPresent(Int.self, forKey: .fleetId)
        fleetName = try values.decodeIfPresent(String.self, forKey: .fleetName)
        createTime = try values.decodeIfPresent(String.self, forKey: .createTime)
        updateTime = try values.decodeIfPresent(String.self, forKey: .updateTime)
        
        if let latitude = gpsLatitude ,
           let longitude = gpsLongitude {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                .correctedForChina()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(clipId, forKey: .clipId)
        try container.encodeIfPresent(cameraSn, forKey: .cameraSn)
        try container.encodeIfPresent(driverId, forKey: .driverId)
        try container.encodeIfPresent(driverLicense, forKey: .driverLicense)
        try container.encodeIfPresent(driverName, forKey: .driverName)
        try container.encodeIfPresent(vehicleId, forKey: .vehicleId)
        try container.encodeIfPresent(plateNo, forKey: .plateNo)
        try container.encodeIfPresent(eventType?.toString(), forKey: .eventType)
        try container.encodeIfPresent(eventCategory, forKey: .eventCategory)
        try container.encodeIfPresent(eventLevel, forKey: .eventLevel)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(tripId, forKey: .tripId)
        try container.encodeIfPresent(gpsTime, forKey: .gpsTime)
        try container.encodeIfPresent(gpsSpeed, forKey: .gpsSpeed)
        try container.encodeIfPresent(gpsHeading, forKey: .gpsHeading)
        try container.encodeIfPresent(gpsLongitude, forKey: .gpsLongitude)
        try container.encodeIfPresent(gpsLatitude, forKey: .gpsLatitude)
        try container.encodeIfPresent(gpsAltitude, forKey: .gpsAltitude)
        try container.encodeIfPresent(gpsHdop, forKey: .gpsHdop)
        try container.encodeIfPresent(gpsVdop, forKey: .gpsVdop)
        try container.encodeIfPresent(fleetId, forKey: .fleetId)
        try container.encodeIfPresent(fleetName, forKey: .fleetName)
        try container.encodeIfPresent(createTime, forKey: .createTime)
        try container.encodeIfPresent(updateTime, forKey: .updateTime)
    }
}

extension HNClip {
    
    convenience init(event: Event) {
        let camera = UnifiedCameraManager.shared.cameraForSN(event.cameraSn!) ?? UnifiedCamera(dict: ["serialNumber": event.cameraSn as Any])
        
        let clipDict: [String : Any] = [
            "momentID" : Int64(event.id!),
            "cameraSN" : event.cameraSn!,
            "mp4Url" : event.url,
            "startTime" : event.startTime?.miliSecFromDate() as Any,
            "duration" : TimeInterval(event.duration!), // seconds to milliseconds
            "needDewarp" : camera.featureAvailability.isViewModeAvailable
        ]
        self.init(dict: clipDict)
    }
    
    convenience init(notiItem: NotiItem){
        let camera = UnifiedCameraManager.shared.cameraForSN(notiItem.cameraSn!) ?? UnifiedCamera(dict: ["serialNumber" : notiItem.cameraSn as Any])
        
        NSLog("doanvt-hn", notiItem.url!)
        
        let clipId : [String : Any] = [
            "momentID" : Int64(0),
            "cameraSN" : notiItem.cameraSn!,
            "mp4Url" : notiItem.url ?? "",
            "startTime" : notiItem.eventTime?.miliSecFromDate() as Any,
            "duration" : notiItem.clipDuration as Any,
            "needDewarp" : false
            
        ]
        
        self.init(dict: clipId)
    }

}


extension String {
    func miliSecFromDate() -> TimeInterval {
            let strTime = self
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let ObjDate = formatter.date(from: strTime)
            return (ObjDate?.timeIntervalSinceNow)!
    }

}

