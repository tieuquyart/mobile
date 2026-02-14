//
//  NotificationListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class NotificationListRootView: CardFlowRootView, WLStatefulView {
    weak var ixResponder: NotificationListIxResponder?

    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configCardFlowView(_ cardFlowView: CardFlowView) {
        super.configCardFlowView(cardFlowView)

        cardFlowView.topMargin = 15.0
    }

}

//MARK: - Private

private extension NotificationListRootView {

    func setup() {
        let menu = setupFilterDropDownMenu(with: [.type, .driver], additionalConfig: { [unowned self] menu in
            menu.menuBarBackgroundColor = self.backgroundColor ?? UIColor.semanticColor(.background(.primary))
        })
        menu.delegate = self

        setupStatefulView()
        startLoading()
    }

}

extension NotificationListRootView: FilterDropDownMenuDelegate {

    func filterDropDownMenuWillHide(_ filterDropDownMenu: FilterDropDownMenu) {
        ixResponder?.applyDataFilter(filterDropDownMenu.dataFilter())
    }

}

extension NotificationListRootView: NotificationListUserInterface {

    func render(newState: NotificationListViewControllerState) {
        newState.dataSource.selectHandler = { [weak self] selectedEvent in
            self?.ixResponder?.showDetail(of: selectedEvent)
        }

        cardFlowView.dataSource = newState.dataSource
        filterDropDownMenu?.updateDropDownView(DriverFilterView.self, updateBlock: { (driverFilterView) in
            driverFilterView.drivers = newState.dataSource.drivers
        })
        cardFlowView.reloadData()

        hasFinishedFirstLoading = newState.hasFinishedFirstLoading
        if hasFinishedFirstLoading && lastState == .loading {
            endLoading()
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        }
    }

}
