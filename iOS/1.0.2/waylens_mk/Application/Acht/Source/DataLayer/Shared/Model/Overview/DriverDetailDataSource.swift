//
//  DriverDetailDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol DriverDetailDataSourceDelegate: AnyObject {
    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdateEvents events: [Event])
    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdate trips: [Trip])
    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdate change: DataChange<Trip>)
}

class DriverDetailDataSource {
    private var dataProvider: DriverDetailDataProvider
    private weak var driver: Driver? = nil

    weak var delegate: DriverDetailDataSourceDelegate? = nil

    var events: [Event] {
        return dataProvider.events
    }

    var trips: [Trip] {
        return dataProvider.trips
    }

    var isActive: Bool = false {
        didSet {
            dataProvider.isActive = isActive
        }
    }

    deinit {
        debugPrint("\(self) deinit")
    }

    init(driver: Driver) {
        self.driver = driver
        self.dataProvider = DriverDetailDataProvider(driver: driver)
        dataProvider.delegate = self
    }
}

extension DriverDetailDataSource: DriverDetailDataProviderDelegate {

    func driverDetailDataProvider(_ driverDetailDataProvider: DriverDetailDataProvider, didUpdateEvents events: [Event]) {
        delegate?.dataSource(self, didUpdateEvents: events)
    }

    func driverDetailDataProvider(_ driverDetailDataProvider: DriverDetailDataProvider, didUpdate change: DataChange<Trip>) {
        delegate?.dataSource(self, didUpdate: change)
    }

    func driverDetailDataProvider(_ driverDetailDataProvider: DriverDetailDataProvider, didUpdateTrips trips: [Trip]) {
        print("trip all thanh",trips.count)
        delegate?.dataSource(self, didUpdate: trips)
    }

}
