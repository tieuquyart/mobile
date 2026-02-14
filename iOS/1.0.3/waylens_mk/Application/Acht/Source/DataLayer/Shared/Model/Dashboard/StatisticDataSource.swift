//
//  StatisticDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/10/22.
//  Copyright © 2019 waylens. All rights reserved.
//

public protocol StatisticDataSourceDelegate: class {
    func dataSourceDidUpdate<DataSourceType>(_ dataSource: DataSourceType)
}

public class StatisticDataSource {
    public internal(set) var statisticChartModel: DashboardStatisticChartModel? = nil
    public var dateRange = DateRange(from: Date(), to: Date())

    weak var delegate: StatisticDataSourceDelegate?

    public func update() {
        
    }

}
