//
//  VehicleSelectorRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleSelectorRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: VehicleSelectorIxResponder?

    override init() {
        super.init()

        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(
            string: NSLocalizedString("Please choose a vehicle plate number", comment: "Please choose a vehicle plate number"),
            font: UIFont.systemFont(ofSize: 14.0),
            textColor: UIColor.semanticColor(.label(.primary)),
            indent: 20.0
        )

        label.frame.size = label.attributedText!.size(constrainedToWidth: UIScreen.main.bounds.width)
        label.frame.size.height += 22 * 2

        tableView.tableHeaderView = label

        let addNewView = AddNewView { [weak self] in
            self?.ixResponder?.addNewPlateNumber()
        }
        addNewView.title = NSLocalizedString("Add New Plate Number", comment: "Add New Plate Number")

        tableView.tableFooterView = addNewView

        applyTheme()

        setupStatefulView()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        tableView.tableHeaderView?.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
        tableView.tableFooterView?.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
    }
}

//MARK: - Private

private extension VehicleSelectorRootView {

}

extension VehicleSelectorRootView: VehicleSelectorUserInterface {

    func render(newState: VehicleSelectorViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
        }

        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
        tableView.reloadData()

        hasFinishedFirstLoading = newState.hasFinishedFirstLoading
        if hasFinishedFirstLoading && lastState == .loading {
            endLoading()
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState

        switch activityIndicatingState {
        case .none:
            HNMessage.dismiss()
        case .adding:
            HNMessage.show(message: activityIndicatingState.message)
        case .loading:
            if hasFinishedFirstLoading {
                HNMessage.show(message: activityIndicatingState.message)
            }
        case .doneAdding:
            HNMessage.showSuccess(message: activityIndicatingState.message)
            HNMessage.dismiss(withDelay: 1.0)
        default:
            break
        }

    }

}
