//
//  MyFleetSettingsRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MyFleetSettingsRootView: ViewContainTableViewAndBottomButton {

    weak var ixResponder: MyFleetSettingsIxResponder?

    private let debugOptionsRow: TableViewRow = TableViewRow(
        title: NSLocalizedString("Debug Options", comment: "Debug Options"),
        cellHeight: 60.0,
        detailViewControllerClass: DebugOptionViewController.self
    )

    private lazy var tableViewData: [TableViewSection] = [
        TableViewSection(
            items: [
                TableViewRow(
                    title: NSLocalizedString("Alert Settings", comment: "Alert Settings"),
                    cellHeight: 60.0,
                    detailViewControllerClass: AlertSettingsViewController.self
                ),
                TableViewRow(
                    title: NSLocalizedString("Clear Cache", comment: "Clear Cache"),
                    cellHeight: 60.0,
                    detailViewControllerClass: nil
                ),
                TableViewRow(
                    title: NSLocalizedString("About", comment: "About"),
                    cellHeight: 60.0,
                    detailViewControllerClass: AboutViewController.self
                ),
                TableViewRow(
                    title: NSLocalizedString("Report an Issue", comment: "Report an Issue"),
                    cellHeight: 60.0,
                    detailViewControllerClass: FeedbackController.self
                ),
                
                TableViewRow(
                    title: NSLocalizedString("Album", comment: "Album"),
                    cellHeight: 60.0,
                    detailViewControllerClass: HNAlbumViewController.self
                )
//                TableViewRow(
//                    title: NSLocalizedString("SecureES Network Setup", comment: "SecureES Network Setup"),
//                    cellHeight: 60.0,
//                    detailViewControllerClass: SecureEsNetworkSetupWayViewController.self
//                ),
//                TableViewRow(
//                    title: NSLocalizedString("APN Setting", comment: "APN Setting"),
//                    cellHeight: 60.0,
//                    detailViewControllerClass: UIAlertController.self
//                )
            ],
            headerHeight: 0.001
        )
    ]

    override init() {
        super.init()

        tableView.delegate = self
        tableView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyFleetSettingsRootView: MyFleetSettingsUserInterface {

    func render(newState: MyFleetSettingsViewState) {
        // Add delay to deal with error `Overlapping accesses to ... but modification requires exclusive access`
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if newState.isDebugOptionsEnable {
                if strongSelf.tableViewData.first?.items.last?.title != strongSelf.debugOptionsRow.title {
                    strongSelf.tableViewData.first?.items.append(strongSelf.debugOptionsRow)
                    strongSelf.tableView.reloadData()
                }
            } else {
                if strongSelf.tableViewData.first?.items.last?.title == strongSelf.debugOptionsRow.title {
                    strongSelf.tableViewData.first?.items.removeLast()
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }

}

//MARK: - Private

extension MyFleetSettingsRootView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].items.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewData[section].headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewData[indexPath.section].items[indexPath.row].cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableViewData[indexPath.section].items[indexPath.row]

        let cell: UITableViewCell = {
            let reuseIdentifier = "\(item.cellType)-\(item.cellStyle.rawValue)"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                return item.cellType.init(style: item.cellStyle, reuseIdentifier: reuseIdentifier)
            }

            return cell
        }()

        cell.imageView?.contentMode = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.detailTextLabel?.font = cell.textLabel?.font
        cell.separatorInset = UIEdgeInsets.zero

        cell.imageView?.image = item.image
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail

        if item.detailViewControllerClass != nil {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = tableViewData[indexPath.section].items[indexPath.row]

        
   
        
        if let detailViewControllerClass = item.detailViewControllerClass {
           
            ixResponder?.navigateTo(viewController: detailViewControllerClass)
        } else {
            ixResponder?.cleanCache()
        }
    }

}
