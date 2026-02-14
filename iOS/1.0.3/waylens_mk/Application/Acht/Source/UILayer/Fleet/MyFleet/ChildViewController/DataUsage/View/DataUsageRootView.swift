//
//  DataUsageRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DataUsageRootView: CardFlowRootView, WLStatefulView {
    weak var ixResponder: DataUsageIxResponder?

    private var isFirstTimeLoading: Bool = true

    init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension DataUsageRootView {

    func setup() {
        setupStatefulView()
        startLoading()
    }

}

extension DataUsageRootView: DataUsageUserInterface {

    func render(newState: DataUsageViewControllerState) {
        newState.dataSource.itemSelectionHandler = { [weak self] selectedItem in
            self?.ixResponder?.select(item: selectedItem)
        }
        cardFlowView.dataSource = newState.dataSource
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

