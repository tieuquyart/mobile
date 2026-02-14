//
//  VinMirrorRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VinMirrorRootView: UIView {
    weak var ixResponder: VinMirrorIxResponder?

    private var tableView: UITableView!
    private var vinMirrorDataSource: VinMirrorDataSource? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension VinMirrorRootView {

    func setup() {
        tableView = UITableView(frame: bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(tableView)
    }

}

extension VinMirrorRootView: VinMirrorUserInterface {

    func render(newState: VinMirrorViewControllerState) {
        vinMirrorDataSource = VinMirrorDataSource(items: newState.items)
        vinMirrorDataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)

            if var selectedItems = self?.vinMirrorDataSource?.selectedItems,
                let newSelectedItem = self?.vinMirrorDataSource?.item(at: indexPath) {
                selectedItems.replaceSubrange(indexPath.section...indexPath.section, with: [newSelectedItem])
                self?.ixResponder?.select(vinMirrors: selectedItems)
            }
        }

        tableView.dataSource = vinMirrorDataSource
        tableView.delegate = vinMirrorDataSource
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

private class VinMirrorDataSource: TableArrayDataSource<VinMirror> {
    private(set) var selectedItems: [VinMirror] = []

    convenience init(items: [VinMirror]) {
        self.init(
            array: [VinMirror.allCases, VinMirror.allCases, VinMirror.allCases],
            tableSettings: [
                TableSetting.titleForSectionHeader({ (section) -> String? in
                    return "Lens \(section + 1)"
                })
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .default)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configCell(cell)

            cell.textLabel?.text = item.rawValue

            if items.count > indexPath.section, items[indexPath.section] == item {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        self.selectedItems = items
    }

}
