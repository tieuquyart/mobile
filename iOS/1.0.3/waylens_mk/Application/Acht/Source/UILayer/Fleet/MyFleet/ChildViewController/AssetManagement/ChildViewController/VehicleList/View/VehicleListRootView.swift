//
//  VehicleListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleListRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: VehicleListIxResponder?

    override init() {
        super.init()

        let addButton = ButtonFactory.makeBigBottomButton(
            NSLocalizedString("+ Add New Vehicle", comment: "+ Add New Vehicle"),
            titleColor: UIColor.semanticColor(.tint(.primary)),
            color: UIColor.clear,
            borderColor: UIColor.semanticColor(.tint(.primary))
        )
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        addBottomItemView(addButton)

        setupStatefulView()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let newLayoutMargins = appDelegate.window?.rootViewController?.view.layoutMargins {
            layoutMargins = UIEdgeInsets(top: 0.0, left: newLayoutMargins.left, bottom: newLayoutMargins.bottom, right: newLayoutMargins.right)
        }
    }

}

//MARK: - Private

private extension VehicleListRootView {

    @objc func addButtonTapped(_ sender: Any) {
        ixResponder?.addNewVehicle()
    }

}

extension VehicleListRootView: VehicleListUserInterface {

    func render(newState: VehicleListViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.selectVehicle(at: indexPath.row)
        }

        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
        tableView.reloadData()

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

