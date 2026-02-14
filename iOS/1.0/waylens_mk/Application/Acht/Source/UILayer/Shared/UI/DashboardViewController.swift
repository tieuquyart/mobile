//
//  DashboardViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DashboardViewController: BaseCardFlowViewController {

    private lazy var dataSource: DashboardDataSource = { [weak self] in
        let dataSource = DashboardDataSource()
        dataSource.dateRange = DateRange(from: Date().adjust(.day, offset: -13), to: Date())
        dataSource.delegate = self
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Dashboard", comment: "Dashboard")

        cardFlowView.cardsContainer.setPullRefreshAction(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        cardFlowView.cardsContainer.mj_header.beginRefreshing()

        let header = DateRangeHeaderView(
            frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 46.0),
            timeZone: UserSetting.current.fleetTimeZone,
            dateRange: dataSource.dateRange,//DateRange(from: dataSource.dateRange.from.toFleetTimeZoneDate.targetDate, to: dataSource.dateRange.to.toFleetTimeZoneDate.targetDate),
            dateRangeChangeHandler: { [weak self] newRange in
                self?.dataSource.dateRange = newRange//DateRange(from: newRange.from.adjust(hour: 23, minute: 59, second: 59).thisDateInFleetTimeZone, to: newRange.to.adjust(hour: 23, minute: 59, second: 59).thisDateInFleetTimeZone)
                self?.dataSource.update()
        })
        cardFlowView.cardsContainer.tableHeaderView = header
    }

    override func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return dataSource.statisticList.isEmpty ? 1 : 2
    }

    override func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        if index == 0 {
            return ChartCardView(statisticChartModel: dataSource.statisticChartModel, chartType: .bar)
        } else {
            let items = dataSource.statisticList
            let card = DriverSummaryCardView(items: items)
            card.eventHandler.selectBlock = { [weak self] itemSelected in
                guard let strongSelf = self else {
                    return
                }

                let statisticViewController = DriverStatisticViewController(driver: itemSelected, dateRange: strongSelf.dataSource.dateRange)
                strongSelf.navigationController?.pushViewController(statisticViewController, animated: true)
            }
            return card
        }
    }

}

//MARK: - Private

private extension DashboardViewController {

    @objc func didPullRefresh() {
        dataSource.update()
    }

    @objc func didLoadMore() {
    }

}

extension DashboardViewController: StatisticDataSourceDelegate {

    func dataSourceDidUpdate<DataSourceType>(_ dataSource: DataSourceType) {
        cardFlowView.cardsContainer.mj_header.endRefreshing()
        cardFlowView.reloadData()
    }

}
