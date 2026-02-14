//
//  DriverStatisticDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/10/22.
//  Copyright © 2019 waylens. All rights reserved.
//

protocol DriverStatisticDataSourceDelegate: class {

}

class DriverStatisticDataSource: StatisticDataSource {
    weak var driver: Driver? = nil
    private(set) var doneFirstLoading = false
    private let api : StatusReportAPI = StatusReport_Service.shared
    
    var driverList = [Driver]()
    
    init(driver: Driver?) {
        self.driver = driver
    }
    
    
    override func update() {
        guard let driver = driver else {
            return
        }
        
        let startTime = dateRange.from.dateManager.fleetDate.dateAt(.startOfDay).date.toString(format: .isoDate)
        let endTime = dateRange.to.dateManager.fleetDate.dateAt(.endOfDay).date.toString(format: .isoDate)
        api.one_driver_status_report(driver:Int(driver.id) ?? 0 , startTime: startTime, endTime: endTime, completion:  { [weak self] _result in
            guard let strongSelf = self else {
                return
            }
            switch _result {
            case .success(let dict):
                if let data = dict["data"] as? JSON {
                    strongSelf.statisticChartModel =  DashboardStatisticChartModel(data)
                    if let driversList = data["driversList"] as? JSON {
                        if let records = driversList["records"] as? [JSON]{
                            strongSelf.driverList = records.compactMap{ Driver(dict: $0) }
                        }
                    }
                    strongSelf.doneFirstLoading = true
                }
               
            case .failure(_):
                break
            }
            
            
            
        
            strongSelf.delegate?.dataSourceDidUpdate(self)
        })
        
    }

//    override func update() {
////        guard let driver = driver else {
////            return
////        }
//
////        WaylensClientS.shared.fetchDriverStatisticAll(
////            driver.id,
////            from: dateRange.from.dateManager.fleetDate.dateAt(.startOfDay).date.millisecondsSince1970,
////            to: dateRange.to.dateManager.fleetDate.dateAt(.endOfDay).date.millisecondsSince1970
////        ) { [weak self] (result) in
////            guard let strongSelf = self else {
////                return
////            }
////
////            switch result {
////            case .success(let value):
////                strongSelf.doneFirstLoading = true
////                strongSelf.statisticChartModel = DashboardStatisticChartModel(dict: value)
////            case .failure(_):
////                break
////            }
////            strongSelf.delegate?.dataSourceDidUpdate(strongSelf)
////        }
//    }
}

//MARK: - Private

private extension DriverStatisticDataSource {

}
