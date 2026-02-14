//
//  TriggeringVehicleSelectorRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleSelectorRootView: UIView, StatefulView {
    weak var ixResponder: TriggeringVehicleSelectorIxResponder?

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension TriggeringVehicleSelectorRootView {

    func setup() {
        transition(to: TriggeringVehicleSelectorStatefulViewState.loading, animated: false)
    }

    @objc
    func saveButtonTapped() {
        ixResponder?.saveCurrentState()
    }

}

extension TriggeringVehicleSelectorRootView: TriggeringVehicleSelectorUserInterface {

    func render(newState: TriggeringVehicleSelectorViewControllerState) {
        switch newState.loadedState {
        case .notLoaded:
            break
        case .loaded(let items):
            self.transition(to: TriggeringVehicleSelectorStatefulViewState.loaded, with: { [weak self] stateView in
                guard let self = self else {
                    return
                }

                if let stateView = stateView as? TriggeringVehicleSelectorScopeSpecificStateView {
                    stateView.dataSource = TriggeringVehicleSelectorDataSource(items: items, selectedItems: newState.rule.vehicleList ?? [])
                    stateView.dataSource?.tableItemSelectionHandler = { indexPath in
                        self.ixResponder?.select(indexPath: indexPath)
                    }
                    stateView.dataSource?.tableItemDeselectionHandler = { indexPath in
                        self.ixResponder?.select(indexPath: indexPath)
                    }

                    stateView.saveButton.removeTarget(self, action: #selector(self.saveButtonTapped), for: .touchUpInside)
                    stateView.saveButton.addTarget(self, action: #selector(self.saveButtonTapped), for: .touchUpInside)
                }
            }, animated: true)

            let activityIndicatingState = newState.viewState.activityIndicatingState
            if activityIndicatingState == .none {
                HNMessage.dismiss()
            } else {
                if activityIndicatingState.isSuccess {
                    HNMessage.showSuccess(message: activityIndicatingState.message)
                    HNMessage.dismiss(withDelay: 1.0)
                } else {
                    HNMessage.show(message: activityIndicatingState.message)
                }
            }
        }
    }

}

enum TriggeringVehicleSelectorStatefulViewState: String, StatefulViewState {
    case loading
    case loaded

    var stateView: UIView {
        switch self {
        case .loading:
            return UINib(nibName: String(describing: WLLoadingView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! WLLoadingView
        case .loaded:
            return TriggeringVehicleSelectorScopeSpecificStateView()
        }
    }
}
