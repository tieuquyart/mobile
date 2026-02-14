//
//  CalibrationVehicleInfoRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CalibrationVehicleInfoRootView: FlowStepRootView<CalibrationVehicleInfoContentView> {
    weak var ixResponder: CalibrationVehicleInfoIxResponder?

    private var dataSource: CalibrationVehicleInfoDataSource? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "3. " + NSLocalizedString("Input the vehicle information.", comment: "Input the vehicle information.")
        progressLabel.text = "3 / 5"
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    override func applyTheme() {
        super.applyTheme()

        contentView.tableView.reloadData()
    }
}

//MARK: - Private

private extension CalibrationVehicleInfoRootView {

    @objc
    private func actionButtonTapped() {
        ixResponder?.nextStep(with: dataSource?.selectedItems ?? [])
    }
    
}

extension CalibrationVehicleInfoRootView: CalibrationVehicleInfoUserInterface {

    func render(newState: CalibrationVehicleInfoViewControllerState) {
        dataSource = CalibrationVehicleInfoDataSource(
            items: newState.viewState.elements,
            selectedItems: Array(newState.viewState.selectedElements)
        )
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            self.ixResponder?.select(indexPath: indexPath)
        }

        contentView.tableView.dataSource = dataSource
        contentView.tableView.delegate = dataSource
        contentView.tableView.reloadData()
    }

}

class CalibrationVehicleInfoDataSource: TableArrayDataSource<CalibrationVehicleInfoViewState.Element> {

    var selectedItems: [CalibrationVehicleInfoViewState.Element] = []

    public convenience init(items: [CalibrationVehicleInfoViewState.Element], selectedItems: [CalibrationVehicleInfoViewState.Element] = []) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({ indexPath in
                    let item = items[indexPath.row]
                    switch item {
                    case .rudderSideTitle:
                        return UITableView.automaticDimension
                    case .cabinSizeTitle:
                        return UITableView.automaticDimension
                    case .seperator:
                        return 20.0
                    default:
                        return 40.0
                    }
                }),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.imageView?.image = nil
            cell.textLabel?.numberOfLines = 0
            cell.separatorInset = .zero

            cell.textLabel?.text = item.title

            let seperatorTag = 888
            if item == .seperator {
                if let seperator = cell.contentView.viewWithTag(seperatorTag) {
                    seperator.backgroundColor = UIColor.semanticColor(.separator(.opaque))
                }
                else {
                    let seperator = UIView()
                    seperator.translatesAutoresizingMaskIntoConstraints = false
                    seperator.tag = seperatorTag
                    seperator.backgroundColor = UIColor.semanticColor(.separator(.opaque))
                    cell.contentView.addSubview(seperator)

                    seperator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
                    seperator.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                    seperator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: cell.separatorInset.left).isActive = true
                    seperator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -cell.separatorInset.left).isActive = true
                }
            }
            else {
                cell.contentView.viewWithTag(seperatorTag)?.removeFromSuperview()
            }
        }

        self.selectedItems = selectedItems

        appendCellConfigurator{ [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            switch item {
            case .left, .right:
                if self.selectedItems.contains(item) {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
                }
                else {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
                }
            case .truck, .largeSuvOrPickup, .carOrSmallSuv:
                if self.selectedItems.contains(item) {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
                }
                else {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
                }
            default:
                break
            }
        }
    }

}
