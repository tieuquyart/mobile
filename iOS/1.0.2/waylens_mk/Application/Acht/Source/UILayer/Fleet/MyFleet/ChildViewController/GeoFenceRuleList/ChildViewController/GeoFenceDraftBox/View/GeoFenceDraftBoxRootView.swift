//
//  GeoFenceDraftBoxRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceDraftBoxRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: GeoFenceDraftBoxIxResponder?

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension GeoFenceDraftBoxRootView {

    func setup() {

    }

}

extension GeoFenceDraftBoxRootView: GeoFenceDraftBoxUserInterface {

    func render(newState: GeoFenceDraftBoxViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
        }
        
        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
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

public class GeoFenceDraftBoxDataSource: TableArrayDataSource<Any> {

    public convenience init(items: [Any]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in

            
        }
    }

}
