//
//  DashboardDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/10/21.
//  Copyright © 2019 waylens. All rights reserved.
//

public protocol DashboardDataSourceDelegate: AnyObject {
    func dataSource(_ dataSource: DashboardDataSource, didUpdateAllStatistics statisticChartModel: DashboardStatisticChartModel)
    func dataSource(_ dataSource: DashboardDataSource, didUpdateStatisticList statisticList: [Driver])
}

public class DashboardDataSource: StatisticDataSource {
    private(set) var statisticList: [Driver] = []
    private(set) var doneAllStatisticsFirstLoading = false
    private let api : StatusReportAPI = StatusReport_Service.shared
    public override func update() {
        fetchAllStatistics()
     
    }
}

//MARK: - Private

private extension DashboardDataSource {

    func fetchAllStatistics() {
        
        let startTime = dateRange.from.toString(format: .isoDate)
        let endTime = dateRange.to.toString(format: .isoDate)
        
        api.status_report(status: .driver, startTime: startTime, endTime: endTime) { [weak self] _result in
            guard let strongSelf = self else {
                return
            }
        
            switch _result {
            case .success(let dict):
                if let data = dict["data"] as? JSON {
                    strongSelf.statisticChartModel = DashboardStatisticChartModel(data)
                    if let driversList = data["driversList"] as? JSON {
                        if let records = driversList["records"] as? [JSON]{
                            strongSelf.statisticList = records.compactMap{ Driver(dict: $0) }
                        }
                    }
                    strongSelf.doneAllStatisticsFirstLoading = true
                }
            case .failure(_):
                break
            }
            
            strongSelf.delegate?.dataSourceDidUpdate(self)
        }

    }

  

}
