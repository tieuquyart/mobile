//
//  DashboardViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import SnapKit

class DashboardViewController: BaseCardFlowViewController {

    private lazy var dataSource: DashboardDataSource = { [weak self] in
        let dataSource = DashboardDataSource()
        dataSource.dateRange =  DateRange(from: Date().adjust(.day, offset: -7), to: Date())
        dataSource.delegate = self
        return dataSource
    }()

    private var selectedSorter: DriverSorter = .name

    var viewChooseTime : TaskOverViewTime = TaskOverViewTime()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()

        cardFlowView.cardsContainer.setPullRefreshAction(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        cardFlowView.cardsContainer.mj_header?.beginRefreshing()
        self.view.backgroundColor = .white
    }

    override func applyTheme() {
        super.applyTheme()

        cardFlowView.reloadData()
        
        self.view.addSubview(viewChooseTime)
        viewChooseTime.snp.makeConstraints { make in
            make.height.equalTo(64)
            make.top.left.right.equalToSuperview()
        }
        
        
        viewChooseTime.closureFast = { [weak self] newRange in
            self?.dataSource.dateRange = newRange
            self?.dataSource.update()
            self?.showProgress()
        }
       
    }


    override func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        if dataSource.doneAllStatisticsFirstLoading {
           return 1
          // return dataSource.statisticList.isEmpty ? 1 : 2
        } else {
            return 0
        }
        
    }

    override func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        //return ChartCardView(statisticChartModel: dataSource.statisticChartModel, chartType: .bar)
        if index == 0 {
            return ChartCardView(statisticChartModel: dataSource.statisticChartModel, chartType: .bar)
        } else {
            
            
            let items = dataSource.statisticList.sorted{selectedSorter.order(for: $0, driver2: $1)}
            let card = DriverSummaryCardView (
                items: items,
                selectedSorter: selectedSorter,
                selectedSorterChangeHandler: { [weak self] selectedSorter in
                    self?.selectedSorter = selectedSorter
                    self?.cardFlowView.reloadCard(at: index)
                }
            )

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
        self.showProgress()
        dataSource.update()
    }

    @objc func didLoadMore() {
    }

}

extension DashboardViewController: StatisticDataSourceDelegate {

    func dataSourceDidUpdate<DataSourceType>(_ dataSource: DataSourceType) {
        
        self.hideProgress()
        cardFlowView.cardsContainer.mj_header?.endRefreshing()
        cardFlowView.reloadData()
        if self.dataSource.doneAllStatisticsFirstLoading, cardFlowView.cardsContainer.tableHeaderView !==  viewChooseTime {
            cardFlowView.cardsContainer.tableHeaderView =  viewChooseTime
        }
    }

}
