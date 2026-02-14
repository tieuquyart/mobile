//
//  RecordConfigRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class RecordConfigRootView: UIView {
    weak var ixResponder: RecordConfigIxResponder?

    private var tableView: UITableView!
    private var recordConfigDataSource: RecordConfigDataSource? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
}

//MARK: - Private

private extension RecordConfigRootView {

    func setup() {
        tableView = UITableView(frame: bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(tableView)
    }

}

extension RecordConfigRootView: RecordConfigUserInterface {

    func render(newState: RecordConfigViewControllerState) {
        recordConfigDataSource = RecordConfigDataSource(items: newState.items, selectedItem: newState.selectedItem, willSelectedItem: newState.willSelectedItem)
        recordConfigDataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            self.tableView.deselectRow(at: indexPath, animated: true)

            guard let recordConfigDataSource = self.recordConfigDataSource else {
                return
            }

            switch indexPath.section {
            case 0:
                let selectedConfig = newState.items[indexPath.row]
                self.ixResponder?.select(recordConfig: selectedConfig.name, bitrateFactor: Int(newState.selectedItem?.bitrateFactor ?? 0), forceCodec: recordConfigDataSource.forceCodec)
            default:
                break
            }
        }

        tableView.dataSource = recordConfigDataSource
        tableView.delegate = recordConfigDataSource
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

extension RecordConfigRootView: Themed {

    func applyTheme() {
        tableView.reloadData()
    }

}

private class RecordConfigDataSource: TableArrayDataSource<Any> {
    private(set) var selectedItem: WLCameraRecordConfig?
    private(set) var willSelectedItem: WLEvcamRecordConfigListItem?

    private(set) var forceCodec: Int = 0

    var forceCodecValueChangedHandler: ((Int) -> ())? = nil

    private var indexPathOfSelectedItem: IndexPath?

    convenience init(items: [WLEvcamRecordConfigListItem], selectedItem: WLCameraRecordConfig?, willSelectedItem: WLEvcamRecordConfigListItem?) {
        var groups: [[Any]] = []
        groups.append(items)
        groups.append(["Force H264"])

        self.init(
            array: groups,
            tableSettings: [

            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .default)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configCell(cell)

            cell.textLabel?.text = nil
            cell.accessoryView = nil
        }

        appendCellConfigurator { [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            switch item {
            case let recordConfigListItem as WLEvcamRecordConfigListItem:
                cell.selectionStyle = .default
                cell.textLabel?.text = recordConfigListItem.name

                if recordConfigListItem.name == selectedItem?.recordConfig {
                    self.indexPathOfSelectedItem = indexPath
                    cell.accessoryType = .checkmark
                }
                else if recordConfigListItem.name == willSelectedItem?.name {
                    let activityIndicator = UIActivityIndicatorView()

                    if #available(iOS 12.0, *), cell.traitCollection.userInterfaceStyle == .dark {
                        activityIndicator.style = .white
                    }
                    else {
                        activityIndicator.style = .gray
                    }

                    activityIndicator.sizeToFit()
                    activityIndicator.startAnimating()
                    cell.accessoryView = activityIndicator
                }
                else {
                    cell.accessoryType = .none
                }
            case let forceH264 as String:
                cell.selectionStyle = .none
                cell.textLabel?.text = forceH264

                let s = UISwitch()
                s.addTarget(self, action: #selector(RecordConfigDataSource.forceCodecSwitchValueChanged(_:)), for: .valueChanged)
                s.isOn = selectedItem?.forceCodec == 1
                cell.accessoryView = s
            default:
                break
            }
        }

        self.selectedItem = selectedItem
        self.willSelectedItem = willSelectedItem
        self.forceCodec = Int(selectedItem?.forceCodec ?? 0)
    }

    @objc private func forceCodecSwitchValueChanged(_ sender: UISwitch) {
        self.forceCodec = sender.isOn ? 1 : 0

        if let indexPathOfSelectedItem = indexPathOfSelectedItem {
            tableItemSelectionHandler?(indexPathOfSelectedItem)
        }
    }

}
