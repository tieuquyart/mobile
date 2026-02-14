//
//  Trip.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import DifferenceKit
import SwiftyJSON
import CoreFoundation
import Combine



class Trip : Codable, NSCopying {
    let id: Int?
    let cameraSn: String?
    let cameraId: Int?
    let driverId: Int?
    let driverName: String?
    let vehicleId: Int?
    let vehiclePlate: String?
    let tripId: String?
//    private(set) var isFinish: Bool
    let distance: Int?
    var drivingTime : String?
    var parkingTime : String?
    var hours : Double?
    let createTime: String?
    let eventCount: Int?
    var isClicked : Bool = false
    private(set) var track: Track? = nil {
        didSet {
            track?.owner = self
        }
    }

    var isLatestTrip: Bool = false

    
    func createTimeToDate() ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: createTime!)!
        return date
    }
    
    func drivingTimeToDate() ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: drivingTime!)!
        return date
    }

    init(trip: Trip) {
        self.id = trip.id
        self.cameraSn = trip.cameraSn
        self.cameraId = trip.cameraId
        self.createTime = trip.createTime
        self.distance = trip.distance
        self.eventCount = trip.eventCount
        self.driverId = trip.driverId
        self.driverName = trip.driverName
        self.vehicleId = trip.vehicleId
        self.vehiclePlate = trip.vehiclePlate
        self.tripId = trip.tripId
//        self.isFinish = trip.isFinish
        self.drivingTime = ""
        self.parkingTime = ""
        self.hours = 0
        self.track = trip.track
        self.isLatestTrip = trip.isLatestTrip
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
    
    required init(from decoder: Decoder) throws {
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
    

    func splitToList(input : [CLLocationCoordinate2D]) -> [[CLLocationCoordinate2D]] {
        let values = input.chunks(100)
        print("valuesMap",values.count)
        return values;
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let theCopyTrip = Trip(trip: self)
        return theCopyTrip
    }
    
    struct MyLocation: Codable {

        let location: Location
        let originalIndex: Int?
        let placeId: String?

    }
    
    struct Location: Codable {

        let latitude: Double
        let longitude: Double

    }
   
    func updateTrack(with trackPoints: [JSON] , closure: @escaping () -> Void) {
        var coordinates: [CLLocationCoordinate2D] = []
        trackPoints.forEach { (trackPoint) in
            if let coordinate = trackPoint["coordinate"] as? [Any], coordinate.count >= 2,
                let longitude = coordinate[0] as? CLLocationDegrees, let latitude = coordinate[1] as? CLLocationDegrees
                 {
                coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude).correctedForChina())
            }
        }
        let itemMap = self.splitToList(input: coordinates)
        itemMap.forEach { item in
            print("thanh array",item.count)
            self.snapToRoad(values: item, closure: closure)
        }
    }
    func snapToRoad(values : [CLLocationCoordinate2D] , closure: @escaping () -> Void) {
        var coordinatesFix: [CLLocationCoordinate2D] = []
        var tempcoordinatesForURL = ""
        values.forEach { location in
            tempcoordinatesForURL.append("\(location.latitude),\(location.longitude)|")
        }
        let str = String(tempcoordinatesForURL.dropLast())
        FleetViewService.shared.snapToRoad(param: str) { result in
            switch result {
            case .success(let value):
                if let data = value["snappedPoints"] as? [JSON] {
                    if let locationData = try? JSONSerialization.data(withJSONObject: data , options: []){
                        do {
                            let items = try JSONDecoder().decode([MyLocation].self, from: locationData)
                            items.forEach { (trackPoint) in
                                let longitude = trackPoint.location.longitude
                                let latitude = trackPoint.location.latitude
                                print("longitude thanh \(longitude) , latitude \(latitude) ")
                                coordinatesFix.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude).correctedForChina())
                            }
                            self.track = Track(owner: self, coordinates: coordinatesFix)
                            closure()
                        } catch let err {
                            print("err get Location",err)
                        }
                    }
                }
            case .failure(let err):
                print("ERROR GET LOCATION",err?.localizedDescription as Any)
            }

        }
    }
    func updateTrack(with anotherTrip: Trip) {
        track = anotherTrip.track
    }
}

extension Trip: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: DifferenceIdentifier {
        return tripId ?? ""
    }
    func isContentEqual(to source: Trip) -> Bool {
        return // isFinish == source.isFinish &&
            track == source.track &&
            isLatestTrip == isLatestTrip
    }
}

extension Array where Element == Trip {

    func updateTracks(with anotherTrips: [Trip]) {
        forEach { (trip) in
            let sameIDTrip = anotherTrips.first(where: { (t) -> Bool in
                return t.tripId == trip.tripId
            })
            if let sameIDTrip = sameIDTrip {
                trip.updateTrack(with: sameIDTrip)
            }
        }
    }
}
extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
