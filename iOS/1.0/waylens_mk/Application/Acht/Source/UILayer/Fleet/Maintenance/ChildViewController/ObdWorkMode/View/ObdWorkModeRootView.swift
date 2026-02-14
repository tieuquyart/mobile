//
//  ObdWorkModeRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class ObdWorkModeRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: ObdWorkModeIxResponder?

    private var dataSource: ObdWorkModeDataSource? = nil
    private var selectedIndexPath: IndexPath? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        tableView.tableHeaderView?.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
}

//MARK: - Private

private extension ObdWorkModeRootView {

    func setup() {
        setupStatefulView()

        tableView.tableHeaderView = LabelHeaderView(title: NSLocalizedString("Select the OBD Work Mode suitable for the vehicle type.", comment: "Select the OBD Work Mode suitable for the vehicle type."))

        applyTheme()
    }

}

extension ObdWorkModeRootView: ObdWorkModeUserInterface {

    func render(newState: ObdWorkModeViewControllerState) {
        func refreshSelectedRow() {
            if let selectedItem = newState.config?.mode, let index = newState.items.firstIndex(of: selectedItem) {
                selectedIndexPath = IndexPath(row: index, section: 0)
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }

        var items: [[Any]] = []
        items.append(newState.items)

        var voltages: [(PartialKeyPath<WLObdWorkModeConfig>, Measurement<UnitElectricPotentialDifference>)] = []

        if let config = newState.config,
           let voltageOn = config.voltageOn,
           let voltageOff = config.voltageOff,
           let voltageCheck = config.voltageCheck
        {
            voltages = [
                (\WLObdWorkModeConfig.voltageOn, voltageOn),
                (\WLObdWorkModeConfig.voltageOff, voltageOff),
                (\WLObdWorkModeConfig.voltageCheck, voltageCheck),
            ]
        }
        items.append(voltages)

        dataSource = ObdWorkModeDataSource(items: items)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            if indexPath.section == 0 {
                self?.ixResponder?.select(mode: newState.items[indexPath.row])
            }
            else {
                self?.ixResponder?.select(voltage: voltages[indexPath.row])
                refreshSelectedRow()
            }
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        refreshSelectedRow()

        endLoading()

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

private class ObdWorkModeDataSource: TableArrayDataSource<Any> {
    public convenience init(items: [[Any]]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return UITableView.automaticDimension}),
                TableSetting.sectionHeaderHeight({ section in
                    return section == 0 ? 0.001 : Constants.UI.sectionHeaderHeight
                }),
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                if indexPath.section == 0 {
                    return .Nib(nibName: String(describing: HNCSRadioChoiceCell.self))
                }
                else {
                    return .Class(cellStyle: UITableViewCell.CellStyle.value1)
                }
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none

            if let cell = cell as? HNCSRadioChoiceCell, let item = item as? WLObdWorkMode {
                cell.nameLabel?.text = item.name
                cell.detailLabel?.text = item.description
            }
            else if let item = item as? (PartialKeyPath<WLObdWorkModeConfig>, Measurement<UnitElectricPotentialDifference>) {
                switch item.0 {
                case \WLObdWorkModeConfig.voltageOff:
                    cell.textLabel?.text = NSLocalizedString("Voltage Off", comment: "Voltage Off")
                case \WLObdWorkModeConfig.voltageOn:
                    cell.textLabel?.text = NSLocalizedString("Voltage On", comment: "Voltage On")
                case \WLObdWorkModeConfig.voltageCheck:
                    cell.textLabel?.text = NSLocalizedString("Voltage Check", comment: "Voltage Check")
                default:
                    break
                }
                cell.detailTextLabel?.text = item.1.localeStringValueWithUnit
            }
        }
    }

}
