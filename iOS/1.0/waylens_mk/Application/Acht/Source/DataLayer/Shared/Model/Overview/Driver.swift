//
//  Driver.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

public class Driver {
    
    public struct Statistics {
        var mileage: Measurement<UnitLength> // in meter
        var duration: Measurement<UnitDuration>
        var eventCount: Int
        var simState : String
        var speed : Double
        var phoneNo : String
        var coordinate: [Double]
        var timeGPS : String
        var gpsData : [String : Any]?
    }
    
    
    private(set) var name: String = ""
    private(set) var id: String = ""
    private(set) var summaryTime: String = ""
    private(set) var phoneNumber: String? = nil
    private(set) var vehicle: Vehicle
    
    private(set) var statistics: Driver.Statistics = Driver.Statistics(
        mileage: 0.measurementLength(unit: .kilometers),
        duration: 0.measurementDuration(unit: .hours),
        eventCount: 0,
        simState: "",
        speed: 0,
        phoneNo: "",
        coordinate:[0],
        timeGPS: ""
    )
    
    
    init(dict: [String : Any]) {
        let id = dict["driverId"] as? Int ?? 0
        self.id = "\(id)"
        
        
        let name = dict["driverName"] as? String ?? ""
        self.name = name
        
        
        let summaryTime = (dict["summaryTime"] as? String) ?? ""
        let distanceTotal = (dict["distanceTotal"] as? Int) ?? 0
        let eventTotal = (dict["eventTotal"] as? Int) ?? 0
        let hoursTotal = (dict["hoursTotal"] as? Double) ?? 0
        
        statistics.mileage = distanceTotal.measurementLength(unit: .kilometers)
        statistics.duration = hoursTotal.measurementDuration(unit: .hours)
        statistics.eventCount = eventTotal
        self.summaryTime = summaryTime
        self.vehicle = Vehicle(dict: dict)
    }
    
    
    
    init(records: [String : Any]) {
        let id = records["driverId"] as? Int ?? 0
        self.id = "\(id)"
        
        
        let name = records["driverName"] as? String ?? ""
        self.name = name
        let distanceTotal = (records["miles"] as? Int) ?? 0
        let eventTotal = (records["events"] as? Int) ?? 0
        let hoursTotal = (records["hours"] as? Double) ?? 0
        let simState = (records["simState"] as? String) ?? ""
//        let speed = (records["speed"] as? Int) ?? 0
        let phoneNo = (records["phoneNo"] as? String) ?? ""
        
        statistics.mileage = distanceTotal.measurementLength(unit: .kilometers)
        statistics.duration = hoursTotal.measurementDuration(unit: .hours)
        statistics.eventCount = eventTotal
        statistics.simState = simState
        statistics.phoneNo = phoneNo
        
        if let gpsData = records["gpsData"] as? JSON {
            statistics.gpsData = gpsData
            if let coordinate = gpsData["coordinate"] as? [Double]{
                statistics.coordinate = coordinate
            }
            
            if let speed = gpsData["speed"] as? Double{
                statistics.speed = speed
            }
            
            if let timeGPS = (gpsData["time"] as? String) {
                statistics.timeGPS = timeGPS
            }
            
        }
        
        
        
        self.vehicle = Vehicle(dict: records)
    }
    
    
    public func updateStatus(with dict: [String : Any]) {
        vehicle.updateStatus(with: dict)
    }
    
    public func fetchAndUpdateInfo(completion: (() -> ())? = nil) {
    }
}

//MARK: - Private

private extension Driver {
    
    func updateStatistics(with dict: [String : Any]) {
        //        statistics.mileage = ((dict["mileage"] as? Double) ?? 0).measurementLength(unit: .meters)
        //        statistics.duration = ((dict["duration"] as? TimeInterval) ?? 0).measurementDuration(unit: .seconds)
        //        statistics.eventCount = (dict["event"] as? Int) ?? 0
    }
    
}

public enum DriverSorter: Equatable, CustomStringConvertible, CaseIterable {
    case status
    case plateNumber
    case mileageDriven
    case timeDriven
    case event
    case name
    
    public var description: String {
        switch self {
        case .status:
            return NSLocalizedString("Status", comment: "Status")
        case .plateNumber:
            return NSLocalizedString("Plate Number", comment: "Plate Number")
        case .mileageDriven:
            return NSLocalizedString("Mileage Driven", comment: "Mileage Driven")
        case .timeDriven:
            return NSLocalizedString("Time Driven", comment: "Time Driven")
        case .event:
            return NSLocalizedString("Event", comment: "Event")
        case .name:
            return NSLocalizedString("Name", comment: "Name")
        }
    }
    
    public func order(for driver1: Driver, driver2: Driver) -> Bool {
        switch self {
        case .status:
            if driver1.vehicle.state != driver2.vehicle.state {
                return driver1.vehicle.state > driver2.vehicle.state
            }
            else if driver1.statistics.mileage != driver2.statistics.mileage {
                return driver1.statistics.mileage > driver2.statistics.mileage
            }
            else {
                return driver1.vehicle.plateNumber.localizedStandardCompare(driver2.vehicle.plateNumber) == .orderedAscending
            }
        case .mileageDriven:
            if driver1.statistics.mileage != driver2.statistics.mileage {
                return driver1.statistics.mileage > driver2.statistics.mileage
            }
            else {
                return driver1.vehicle.plateNumber.localizedStandardCompare(driver2.vehicle.plateNumber) == .orderedAscending
            }
        case .timeDriven:
            if driver1.statistics.duration != driver2.statistics.duration {
                return driver1.statistics.duration > driver2.statistics.duration
            }
            else {
                return driver1.vehicle.plateNumber.localizedStandardCompare(driver2.vehicle.plateNumber) == .orderedAscending
            }
        case .event:
            if driver1.statistics.eventCount != driver2.statistics.eventCount {
                return driver1.statistics.eventCount > driver2.statistics.eventCount
            }
            else {
                return driver1.vehicle.plateNumber.localizedStandardCompare(driver2.vehicle.plateNumber) == .orderedAscending
            }
        case .plateNumber:
            return driver1.vehicle.plateNumber.localizedStandardCompare(driver2.vehicle.plateNumber) == .orderedAscending
        case .name:
            return driver1.name.localizedStandardCompare(driver2.name) == .orderedAscending
        }
    }
}
