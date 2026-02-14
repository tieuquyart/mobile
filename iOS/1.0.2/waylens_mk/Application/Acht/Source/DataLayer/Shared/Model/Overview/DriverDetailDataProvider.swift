//
//  DriverDetailDataProvider.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import DifferenceKit

enum DataChange<T> {
    case inserted(items: [T])
    case updated(items: [T])
    case deleted(items: [T])
}

protocol DriverDetailDataProviderDelegate: AnyObject {
    func driverDetailDataProvider(_ driverDetailDataProvider: DriverDetailDataProvider, didUpdateEvents events: [Event])
    func driverDetailDataProvider(_ driverDetailDataProvider: DriverDetailDataProvider, didUpdate change: DataChange<Trip>)
}

class DriverDetailDataProvider {
    private lazy var autoUpdateLogic: AutoUpdateLogic = { [weak self] in
        let autoUpdateLogic = AutoUpdateLogic(updateBlock: {
            //            self?.fetchEvents()
            //            self?.fetchTrips()
        })
        return autoUpdateLogic
    }()
    private weak var driver: Driver? = nil
    
    weak var delegate: DriverDetailDataProviderDelegate? = nil
    
    private(set) var events: [Event] = []
    private(set) var trips: [Trip] = []
    
    let api : FleetViewAPI = FleetViewService.shared
    deinit {
        debugPrint("\(self) deinit")
    }
    
    var isActive: Bool = false {
        didSet {
            autoUpdateLogic.isActive = isActive
        }
    }
    
    init(driver: Driver) {
        self.driver = driver
    }
}

//MARK: - Private

extension DriverDetailDataProvider {
    
    
    
    private func fetchEvents() {
        guard let driver = driver else {
            return
        }
        
        
        let dateRange = DateRange.rangeUsingInOverview
        
        api.events(cameraSn: driver.vehicle.cameraSN, eventGroup: 1, startTime: dateRange.from.toString(format: .isoDate), endTime: dateRange.to.toString(format: .isoDate), completion: { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let value):
                if let data = value["data"] as? [JSON] {
                    if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                       let events = try? JSONDecoder().decode([Event].self, from: eventData).sorted(by: {$1.createTimeToDate().compare($0.createTimeToDate()) == .orderedDescending}) {
                        
                        strongSelf.delegate?.driverDetailDataProvider(strongSelf, didUpdateEvents: events)
                    }
                }
            case .failure(_):
                break
            }
        })
    }
    
    private func fetchTrips() {
        guard let driver = driver else {
            return
        }
        
        let date = Date().toString(format: .isoDate)
        //      print("date thanh",date)
        
        api.trips(cameraSn: driver.vehicle.cameraSN, searchDate:  date, completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let value):
                if let tripDicts = value["data"] as? [JSON] {
                    // let trips = tripDicts.map{ Trip(dict: $0) }.sorted{$0.trackEndTime > $1.trackEndTime}
                    //                    let trips = tripDicts.map{ Trip(dict: $0) }
                    //                    let trips = tripDicts.map{ Trip(dict: $0) }
                    if let tripData = try? JSONSerialization.data(withJSONObject: tripDicts, options: []){
                        do {
                            
                            let trips = try JSONDecoder().decode([Trip].self, from: tripData).sorted(by: {$0.id! < $1.id!})
                            
                            trips.first?.isLatestTrip = true
                            trips.updateTracks(with: strongSelf.trips)
                            
                            if let changeset = StagedChangeset(source: strongSelf.trips, target: trips).first {
                                let insertedItems = changeset.elementInserted.map{ trips[$0.element] }
                                strongSelf.delegate?.driverDetailDataProvider(strongSelf, didUpdate: .inserted(items: insertedItems))
                                
                                let updatedItems = changeset.elementUpdated.map{ strongSelf.trips[$0.element] }
                                strongSelf.delegate?.driverDetailDataProvider(strongSelf, didUpdate: .updated(items: updatedItems))
                                
                                let deletedItems = changeset.elementDeleted.map{ strongSelf.trips[$0.element] }
                                strongSelf.delegate?.driverDetailDataProvider(strongSelf, didUpdate: .deleted(items: deletedItems))
                            }
                            
                            strongSelf.trips.forEach({ (trip) in
                                if trip.track == nil /*|| !trip.isFinish*/ {
                                    strongSelf.updateTrack(for: trip)
                                }
                            })
                            
                        } catch let err {
                            print("err get trips",err)
                        }
                    }
                }
            case .failure(_):
                break
            }
            
        })
        
    }
    
    private func updateTrack(for trip: Trip) {
        guard let driver = driver else {
            return
        }
        
        api.track(cameraSn: driver.vehicle.cameraSN, tripId: trip.tripId ?? "", completion: { [weak self] (result) in
            guard self != nil else {
                return
            }
            
            switch result {
            case .success(_):
                let oldTrip = trip.copy() as! Trip
            case .failure(_):
                break
            }
        })
        
    }
    
}
