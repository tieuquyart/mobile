//
//  DriverStatisticViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DriverStatisticViewController: BaseCardFlowViewController {

    private lazy var dataSource: DriverStatisticDataSource = { [unowned self] in
        let dataSource = DriverStatisticDataSource(driver: self.driver)
        dataSource.delegate = self
        return dataSource
    }()
    private var selectedSorter: DriverSorter = .name
    private let driver: Driver

    private lazy var dateRangeHeaderView: DateRangeHeaderView = {[weak self] in
        return DateRangeHeaderView(
            frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 46.0),
            dateRange: dataSource.dateRange,
            dateRangeChangeHandler: { newRange in
                self?.dataSource.dateRange = newRange
                self?.dataSource.update()
        })
    }()

    init(driver: Driver, dateRange: DateRange) {
        self.driver = driver
        super.init(nibName: nil, bundle: nil)

        dataSource.dateRange = dateRange
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = driver.name

        cardFlowView.cardsContainer.setPullRefreshAction(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        cardFlowView.cardsContainer.mj_header?.beginRefreshing()
    }

    override func applyTheme() {
        super.applyTheme()

        cardFlowView.reloadData()
    }

    override func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        if dataSource.doneFirstLoading {
           // return 1
            return  ( dataSource.driverList.isEmpty ? 1 : 2)
         
        } else {
            return 0
        }
    }

    override func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
       
        if index == 0 {
            return ChartCardView(statisticChartModel: dataSource.statisticChartModel, chartType: .line, showActiveVehiclesStatistic: false)
        } else {
            
            
            let items = dataSource.driverList.sorted{selectedSorter.order(for: $0, driver2: $1)}
            let card = DriverStatisticCardView(items: items)
            card.eventHandler.selectBlock = { [weak self] itemSelected in
                guard let strongSelf = self else {
                    return
                }
                if itemSelected.statistics.eventCount > 0 {
                    let driverDetailVC = TripDetailTimelineViewController(nibName: "TripDetailTimelineViewController", bundle: nil)
                    driverDetailVC.cameraSn = strongSelf.driver.vehicle.cameraSN
                    driverDetailVC.name = strongSelf.driver.name
                    driverDetailVC.date = itemSelected.summaryTime
                    strongSelf.navigationController?.pushViewController(driverDetailVC, animated: true)
                }
               
              //  let driverDetailVC = DriverDetailViewController(driver: driver, dateRange: DateRange.pastDays(7), canLoadMore: true)
                

//                strongSelf.navigationController?.pushViewController(DriverDetailViewController(driver: strongSelf.driver, dateRange: DateRange(from: itemSelected.from, to: itemSelected.to), canLoadMore: false), animated: true)
            }
            return card
        }
    }

}

//MARK: - Private

private extension DriverStatisticViewController {

    @objc func didPullRefresh() {
        dataSource.update()
    }

    @objc func didLoadMore() {
    }

}

extension DriverStatisticViewController: StatisticDataSourceDelegate {

    func dataSourceDidUpdate<DataSourceType>(_ dataSource: DataSourceType) {
        cardFlowView.cardsContainer.mj_header?.endRefreshing()
        cardFlowView.reloadData()

        if self.dataSource.doneFirstLoading, cardFlowView.cardsContainer.tableHeaderView !== dateRangeHeaderView {
            cardFlowView.cardsContainer.tableHeaderView = dateRangeHeaderView
        }
    }

}
