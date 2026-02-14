//
//  PowerInfoRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class PowerInfoRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: PowerInfoIxResponder?

    private var dataSource: PowerInfoDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension PowerInfoRootView {

    func setup() {

    }

}

extension PowerInfoRootView: PowerInfoUserInterface {

    func render(newState: PowerInfoViewControllerState) {
        let sections = [
            TableViewSection(
                items: [
                    TableViewRow(
                        title: NSLocalizedString("Serial Number", comment: "Serial Number"),
                        detail: newState.camera?.sn ?? "--",
                        detailViewControllerClass: NetworkDiagnosisViewController.self
                    ),
                ],
                headerHeight: 0.001
            ),
            TableViewSection(
                items: [
                    TableViewRow(
                        title: NSLocalizedString("Current Voltage", comment: "Current Voltage"),
                        detail: newState.camera?.batteryInfo?.currentVoltage.localeStringValueWithUnit ?? "--",
                        detailViewControllerClass: nil
                    ),
                    TableViewRow(
                        title: NSLocalizedString("Battery Status", comment: "Battery Status"),
                        detail: newState.camera?.batteryInfo?.status ?? "--",
                        detailViewControllerClass: nil
                    )
                ]
            )
        ]

        dataSource = PowerInfoDataSource(items: sections)

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

private class PowerInfoDataSource: TableArrayDataSource<TableViewRow> {

    public convenience init(items: [TableViewSection]) {
        let setions = items.map { $0.items }

        self.init(
            array: setions,
            tableSettings: [
                TableSetting.rowHeight({_ in return 60.0}),
                TableSetting.sectionHeaderHeight({ section in
                    let tableViewSection = items[section]
                    return tableViewSection.headerHeight
                })
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .value1)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.detail
        }
    }

}
