//
//  NotiItem.swift
//  Acht
//
//  Created by TranHoangThanh on 8/11/22.
//  Copyright © 2022 waylens. All rights reserved.

import DifferenceKit
import SwiftyJSON
import CoreFoundation
import Combine
import MapKit

class NotiItem: Codable {

    let id: String?
    let category: String?
    let eventType: EventType?
    let eventTime: String?
    let eventRemark: String?
    let fleetId: Int?
    let fleetName: String?
    let cameraSn: String?
    let url: String?
    let driverName: String?
    let driverId: Int?
    let plateNo: String?
    let gpsLongitude: Double?
    let gpsLatitude: Double?
    let gpsAltitude: Int?
    let gpsHdop: Int?
    let gpsVdop: Int?
    let gpsHeading: Double?
    let gpsSpeed: Double?
    let gpsTime: String?
    let clipId: String?
    let clipDuration: Double?
    let createTime: String?
    let alert: String?
    var markRead: Bool = false
    let statusUpdatePhone: Bool?
    
    let subscriptionName : String?
    
    
    let accountName :  String?
    
    func categorySub() -> String {
        return NSLocalizedString(category ?? "null", comment:category ?? "null")
    }

    private enum CodingKeys: String, CodingKey {

        case id = "id"
        case category = "category"
        case eventType = "eventType"
        case eventTime = "eventTime"
        case eventRemark = "eventRemark"
        case fleetId = "fleetId"
        case fleetName = "fleetName"
        case cameraSn = "cameraSn"
        case driverName = "driverName"
        case driverId = "driverId"
        case plateNo = "plateNo"
        case gpsLongitude = "gpsLongitude"
        case gpsLatitude = "gpsLatitude"
        case gpsAltitude = "gpsAltitude"
        case gpsHdop = "gpsHdop"
        case gpsVdop = "gpsVdop"
        case gpsHeading = "gpsHeading"
        case gpsSpeed = "gpsSpeed"
        case gpsTime = "gpsTime"
        case clipId = "clipId"
        case clipDuration = "clipDuration"
        case accountName = "accountName"
        case createTime = "createTime"
        case alert = "alert"
        case markRead = "markRead"
        case url = "url"
        case subscriptionName = "subscriptionName"
        case statusUpdatePhone = "statusUpdatePhone"
        
       
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String?.self, forKey: .id)
        category = try values.decode(String?.self, forKey: .category)
        eventType = try EventType.from(string: values.decodeIfPresent(String.self, forKey: .eventType) ?? "")
        eventTime = try values.decode(String?.self, forKey: .eventTime)
        eventRemark = try values.decode(String?.self, forKey: .eventRemark)
        fleetId = try values.decode(Int?.self, forKey: .fleetId)
        fleetName = try values.decode(String?.self, forKey: .fleetName)
        cameraSn = try values.decode(String?.self, forKey: .cameraSn)
        driverName = try values.decode(String?.self, forKey: .driverName) // TODO: Add code for decoding `driverName`, It was null at the time of model creation.
        driverId = try values.decode(Int?.self, forKey: .driverId) // TODO: Add code for decoding `driverId`, It was null at the time of model creation.
        plateNo = try values.decode(String?.self, forKey: .plateNo)
        gpsLongitude = try values.decode(Double?.self, forKey: .gpsLongitude)
        gpsLatitude = try values.decode(Double?.self, forKey: .gpsLatitude)
        gpsAltitude = try values.decode(Int?.self, forKey: .gpsAltitude)
        gpsHdop = try values.decode(Int?.self, forKey: .gpsHdop)
        gpsVdop = try values.decode(Int?.self, forKey: .gpsVdop)
        gpsHeading = try values.decode(Double?.self, forKey: .gpsHeading)
        gpsSpeed = try values.decode(Double?.self, forKey: .gpsSpeed)
        gpsTime = try values.decode(String?.self, forKey: .gpsTime)
        clipDuration = try values.decode(Double?.self, forKey: .clipDuration) // TODO: Add code for decoding `clipDuration`, It was null at the time of model creation.
        createTime = try values.decode(String?.self, forKey: .createTime)
        alert = try values.decode(String?.self, forKey: .alert)
        markRead = try values.decode(Bool?.self, forKey: .markRead) ?? false
        url =  try values.decode(String?.self, forKey: .url)
        clipId =  try values.decode(String?.self, forKey: .clipId)
        subscriptionName  =  try values.decode(String?.self, forKey: .subscriptionName)
        statusUpdatePhone = try values.decode(Bool?.self, forKey: .statusUpdatePhone)
        accountName  = try values.decode(String?.self, forKey: .accountName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(eventType?.toString(), forKey: .eventType)
        try container.encode(eventTime, forKey: .eventTime)
        try container.encode(eventRemark, forKey: .eventRemark)
        try container.encode(fleetId, forKey: .fleetId)
        try container.encode(fleetName, forKey: .fleetName)
        try container.encode(cameraSn, forKey: .cameraSn)
        try container.encode(driverName, forKey: .driverName)
        try container.encode(driverId, forKey: .driverId)
        try container.encode(plateNo, forKey: .plateNo)
        try container.encode(gpsLongitude, forKey: .gpsLongitude)
        try container.encode(gpsLatitude, forKey: .gpsLatitude)
        try container.encode(gpsAltitude, forKey: .gpsAltitude)
        try container.encode(gpsHdop, forKey: .gpsHdop)
        try container.encode(gpsVdop, forKey: .gpsVdop)
        try container.encode(gpsHeading, forKey: .gpsHeading)
        try container.encode(gpsSpeed, forKey: .gpsSpeed)
        try container.encode(gpsTime, forKey: .gpsTime)
        try container.encode(clipDuration, forKey: .clipDuration)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(alert, forKey: .alert)
        try container.encode(markRead, forKey: .markRead)
        try container.encode(url, forKey: .url)
        try container.encode(clipId, forKey: .clipId)
        try container.encode(subscriptionName, forKey: . subscriptionName)
        try container.encode(statusUpdatePhone, forKey: .statusUpdatePhone)
        try container.encode(accountName , forKey: .accountName )
       
    }

}
