//
//  DriverListDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol DriverListDataSourceDelegate: AnyObject {
    func dataSource(_ driverListDataSource: DriverListDataSource, didSelectDriver driver: Driver)
    func dataSource(_ driverListDataSource: DriverListDataSource, didUpdateVehicles vehicles: [Vehicle])
    func presentMsg(msg :String)
    func showProgressss(value: Bool)
}

class DriverListDataSource: NSObject {
    
    private lazy var dataProvider: DriverListDataProvider = { [weak self] in
        let dataProvider = DriverListDataProvider()
        dataProvider.delegate = self
        return dataProvider
    }()

    weak var tableView: UITableView? = nil
    weak var headerView: DriverListHeader? = nil
    weak var delegate: DriverListDataSourceDelegate? = nil
    let rc = UIRefreshControl()
    private var index = 1
    private var pageSize : Int32 = 0;

    var sorter: DriverSorter = .status {
        didSet {
            if sorter != oldValue {
                drivers = drivers.sorted{sorter.order(for: $0, driver2: $1)}
            }
        }
    }
    var vehicles: [Vehicle] = []

//    var vehicles: [Vehicle] {
//        return dataProvider.vehicles
//    }

    var drivers: [Driver] = []

    var isActive: Bool = false {
        didSet {
            dataProvider.isActive = isActive
        }
    }

    init(tableView: UITableView, headerView: DriverListHeader) {
        self.tableView = tableView
        self.headerView = headerView
        super.init()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView?.setPullRefreshActionT(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
    }
    
    @objc func didPullRefresh() {
        print("didPullRefresh")
        index = 1
        dataProvider.fetchDrivers();
        self.tableView?.mj_header?.endRefreshing()
    }
    
    @objc func didLoadMore() {
        if index < pageSize{
            print("didLoadMore")
            index += 1
            print("index: ", Int32(index))
            dataProvider.getMoreDrivers(index: Int32(index), drivers: self.drivers)
        }else{
            print("No more items to load")
        }
        
        self.tableView?.mj_footer?.endRefreshing()
        
    }
    
}

extension DriverListDataSource: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverListCell", for: indexPath) as! DriverListCell
       // cell.accessoryType = .disclosureIndicator

        let driver = drivers[indexPath.row]
        cell.driver = driver

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let driver = drivers[indexPath.row]
        delegate?.dataSource(self, didSelectDriver: driver)
    }

}


extension DriverListDataSource: DriverListDataProviderDelegate {

    func driverListDataProvider(_ driverListDataProvider: DriverListDataProvider, didUpdateDrivers drivers: [Driver]) {

        self.drivers = drivers.sorted{sorter.order(for: $0, driver2: $1)}

        tableView?.reloadData()
    }

    func driverListDataProvider(_ driverListDataProvider: DriverListDataProvider, didUpdateVehicles vehicles: [Vehicle]) {
        headerView?.totalCount = vehicles.count
        headerView?.drivingCount = vehicles.count(of: .driving)
        headerView?.parkingCount = vehicles.count(of: .parking)
        tableView?.reloadData()
        
        delegate?.dataSource(self, didUpdateVehicles: vehicles)
    }
    
    func presentMsg(msg: String) {
        delegate?.presentMsg(msg: msg)
    }
    
    func showProgress(value: Bool) {
        delegate?.showProgressss(value: value)
    }
    func fleetViewPageSize(size: Int32) {
        self.pageSize = size
    }

}
