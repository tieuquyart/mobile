//
//  MaintenanceRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MaintenanceRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: MaintenanceIxResponder?

    private var dataSource: MaintenanceDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension MaintenanceRootView {

    func setup() {

    }

    @objc
    func logoutButtonTapped() {
        ixResponder?.logout()
    }

    @objc
    func loginButtonTapped() {
        ixResponder?.login()
    }
}

extension MaintenanceRootView: MaintenanceUserInterface {

    func render(newState: MaintenanceViewControllerState) {
        removeAllBottomItemViews()

        if AccountControlManager.shared.isLogin {
            let logoutButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Back", comment: "Back"), color: UIColor.semanticColor(.background(.tertiary)))
            logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
            addBottomItemView(logoutButton)
        }
        else {
            let loginButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Log In", comment: "Log In"), color: UIColor.semanticColor(.tint(.primary)))
            loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
            addBottomItemView(loginButton)
        }

        dataSource = MaintenanceDataSource(items: newState.sections)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            let item = newState.sections[indexPath.section].items[indexPath.row]

            if let detailViewControllerClass = item.detailViewControllerClass {
                self.ixResponder?.navigateTo(viewController: detailViewControllerClass)
            }

            self.tableView.deselectRow(at: indexPath, animated: true)
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

private class MaintenanceDataSource: TableArrayDataSource<TableViewRow> {

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
            cell.imageView?.image = item.image?.image(with: CGSize(width: 30.0, height: 30.0))
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.detail
        }
    }

}
