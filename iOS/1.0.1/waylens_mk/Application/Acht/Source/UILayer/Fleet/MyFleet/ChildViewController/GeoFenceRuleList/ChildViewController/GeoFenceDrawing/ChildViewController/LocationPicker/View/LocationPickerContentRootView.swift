//
//  LocationPickerContentRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LocationPickerContentRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: LocationPickerIxResponder?

    private var dataSource: LocationPickerDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension LocationPickerContentRootView {

    func setup() {

    }

}

extension LocationPickerContentRootView: LocationPickerUserInterface {

    func render(newState: LocationPickerViewControllerState) {
        dataSource = LocationPickerDataSource(items: newState.searchResults)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

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

private class LocationPickerDataSource: TableArrayDataSource<NamedLocation> {

    public convenience init(items: [NamedLocation]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 60.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none
            cell.textLabel?.text = item.name
        }
    }

}
