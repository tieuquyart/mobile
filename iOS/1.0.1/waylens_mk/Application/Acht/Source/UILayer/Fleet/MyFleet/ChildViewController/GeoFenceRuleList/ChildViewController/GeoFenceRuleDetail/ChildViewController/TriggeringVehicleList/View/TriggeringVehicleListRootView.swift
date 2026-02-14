//
//  TriggeringVehicleListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListRootView: UIView, StatefulView {
    weak var ixResponder: TriggeringVehicleListIxResponder?

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension TriggeringVehicleListRootView {

    func setup() {
        transition(to: TriggeringVehicleListStatefulViewState.loading, animated: false)
    }

    @objc
    func addButtonTapped() {
        ixResponder?.addItems()
    }

}

extension TriggeringVehicleListRootView: TriggeringVehicleListUserInterface {

    func render(newState: TriggeringVehicleListViewControllerState) {
        if newState.rule.scope == .specific {
            switch newState.loadedState {
            case .notLoaded:
                break
            case .loaded(let items):
                let selectedVehicleIds = newState.rule.vehicleList ?? []
                let items = items.filter{ vehicle in
                    if let vehicleId = vehicle.vehicleID {
                        return selectedVehicleIds.contains(vehicleId)
                    }
                    else {
                        return false
                    }
                }

                if items.isEmpty {
                    self.transition(to: TriggeringVehicleListStatefulViewState.empty, with: { [weak self] stateView in
                        guard let self = self else {
                            return
                        }

                        if let stateView = stateView as? TriggeringVehicleListScopeSpecificEmptyStateView {
                            stateView.button.removeTarget(self, action: #selector(self.addButtonTapped), for: .touchUpInside)
                            stateView.button.addTarget(self, action: #selector(self.addButtonTapped), for: .touchUpInside)
                        }
                    }, animated: true)
                }
                else {
                    self.transition(to: TriggeringVehicleListStatefulViewState.specific, with: { stateView in
                        if let stateView = stateView as? TriggeringVehicleListScopeSpecificStateView {
                            stateView.dataSource = TriggeringVehicleListDataSource(items: items)
                            stateView.dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
                                self?.ixResponder?.select(indexPath: indexPath)
                            }
                        }
                    }, animated: true)
                }
            }
        }
        else {
            self.transition(to: TriggeringVehicleListStatefulViewState.all, animated: true)
        }
    }

}

enum TriggeringVehicleListStatefulViewState: String, StatefulViewState {
    case loading
    case all
    case specific
    case empty

    var stateView: UIView {
        switch self {
        case .loading:
            return UINib(nibName: String(describing: WLLoadingView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! WLLoadingView
        case .all:
            return TriggeringVehicleListScopeAllStateView()
        case .specific:
            return TriggeringVehicleListScopeSpecificStateView()
        case .empty:
            return TriggeringVehicleListScopeSpecificEmptyStateView()
        }
    }
}
