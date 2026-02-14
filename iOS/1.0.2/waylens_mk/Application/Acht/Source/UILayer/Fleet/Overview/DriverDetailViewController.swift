//
//  DriverDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DriverDetailViewController: BaseCardFlowViewController {
    private var driver: Driver
    private var dataSource: DriverTimelineDataSource!
    private var canLoadMore: Bool

    deinit {
        debugPrint("\(self) deinit")
    }

    init(driver: Driver, dateRange: DateRange, canLoadMore: Bool) {
        self.driver = driver
        self.canLoadMore = canLoadMore
        super.init(nibName: nil, bundle: nil)

        dataSource = DriverTimelineDataSource(driver: driver, initialDateRange: dateRange)
        dataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = driver.name

        // driver single day timeline
        if canLoadMore {
            let menu = view.setupFilterDropDownMenu(with: [.type, .time], additionalConfig: { [unowned self] menu in
                menu.menuBarBackgroundColor = self.view.backgroundColor ?? UIColor.semanticColor(.background(.primary))
            })
            menu.delegate = self
        }

        cardFlowView.cardsContainer.setPullRefreshAction(self, refreshAction:  #selector(didPullRefresh), loadMoreAction: canLoadMore ? #selector(didLoadMore) : nil)

        cardFlowView.cardsContainer.mj_header?.beginRefreshing()
    }

    override func addAdditionalConfig(to cardFlowView: CardFlowView) {
        super.addAdditionalConfig(to: cardFlowView)

        cardFlowView.topMargin = 15.0
    }

    override func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return dataSource.cardModelsFiltered.count
    }

    override func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        let model = dataSource.cardModelsFiltered[index]
        let card = TimelineCardView(model: model)
        card.eventHandler.selectBlock = { [weak self] itemSelected in
            guard let strongSelf = self else {
                return
            }

            if let timelineEvent = itemSelected.object as? DriverTimelineEvent, let eventContent = timelineEvent.content as? DriverTimelineCameraEventContent {
                HNMessage.show()
                strongSelf.dataSource.fetchEventDetail(eventContent.clipID, completion: { (event, error) in
                    if let event = event {
                        HNMessage.dismiss()

                        let eventVC = EventDetailViewController(event: event)
                        strongSelf.navigationController?.pushViewController(eventVC, animated: true)
                    } else {
                        HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Unknown Error", comment: "Unknown Error"))
                    }
                })
            }
        }

        return card
    }

}

//MARK: - Private

private extension DriverDetailViewController {

    @objc func didPullRefresh() {
        dataSource.reload()
    }

    @objc func didLoadMore() {
        dataSource.loadMore()
    }

}

extension DriverDetailViewController: DriverTimelineDataSourceDelegate {

    func dataSource(_ dataSource: DriverTimelineDataSource, didReload cardModels: [TimelineCardModel], allIsLoaded: Bool) {
        self.cardFlowView.cardsContainer.mj_header?.endRefreshing()

        if canLoadMore {
            if allIsLoaded {
                self.cardFlowView.cardsContainer.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.cardFlowView.cardsContainer.mj_footer?.endRefreshing()
            }
        }

        self.cardFlowView.reloadData()
    }

    func dataSource(_ dataSource: DriverTimelineDataSource, didLoadMore cardModels: [TimelineCardModel], allIsLoaded: Bool) {
        if allIsLoaded {
            self.cardFlowView.cardsContainer.mj_footer?.endRefreshingWithNoMoreData()
        } else {
            self.cardFlowView.cardsContainer.mj_footer?.endRefreshing()
        }

        self.cardFlowView.reloadData()
    }

}

extension DriverDetailViewController: FilterDropDownMenuDelegate {

    func filterDropDownMenuWillHide(_ filterDropDownMenu: FilterDropDownMenu) {
        dataSource.dataFilter = filterDropDownMenu.dataFilter()
        cardFlowView.reloadData()
    }

}
