//
//  GeoFenceRuleListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceRuleListRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: GeoFenceRuleListIxResponder?

    private var dataSource: GeoFenceRuleListDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension GeoFenceRuleListRootView {

    func setup() {
        setupStatefulView()
        startLoading()
    }

}

extension GeoFenceRuleListRootView: GeoFenceRuleListUserInterface {

    func render(newState: GeoFenceRuleListViewControllerState) {
        switch newState.loadedState {
        case .notLoaded:
            break
        case .loaded(let rules):
            dataSource = GeoFenceRuleListDataSource(items: rules, hasDrafts: newState.hasDrafts)
            dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
                self?.ixResponder?.select(indexPath: indexPath)
            }

            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            tableView.reloadData()

            endLoading()
        }
    }

}

public class GeoFenceRuleListDataSource: TableArrayDataSource<Any> {

    public convenience init(items: [GeoFenceRule], hasDrafts: Bool = false) {
        var groups: [[Any]] = []

        if hasDrafts {
            groups.append([NSLocalizedString("Draft Box", comment: "Draft Box")])
        }

        groups.append(items)

        self.init(
            array: groups,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.sectionHeaderHeight({section in
                    if section == 0 {
                        return 0.001
                    }
                    else {
                        return 20.0
                    }
                })
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            switch item {
            case let rule as GeoFenceRule:
                cell.imageView?.image = FleetResource.Image.icon(for: rule.type)
                cell.textLabel?.text = rule.name
                cell.detailTextLabel?.text = NSLocalizedString("Trigger Mode", comment: "Trigger Mode") + ": " + rule.type.description
            case let draft as String:
                cell.imageView?.image = #imageLiteral(resourceName: "Draft box")
                cell.textLabel?.text = draft
                cell.detailTextLabel?.text = nil
            default:
                break
            }
        }
    }

}
