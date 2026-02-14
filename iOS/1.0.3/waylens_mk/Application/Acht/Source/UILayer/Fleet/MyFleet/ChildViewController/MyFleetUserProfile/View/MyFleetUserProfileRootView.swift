//
//  MyFleetUserProfileRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MyFleetUserProfileRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: MyFleetUserProfileIxResponder?

    
    private let userNameRow = TableViewRow(
        title: NSLocalizedString("Username" , comment: "Username" ),
        cellHeight: 60.0,
        cellStyle: .value1
    )

    private let nameRow = TableViewRow(
        title: NSLocalizedString("Name", comment: "Name"),
        cellHeight: 60.0,
        cellStyle: .value1
    )

    private let roleRow = TableViewRow(
        title: NSLocalizedString("Role", comment: "Role"),
        cellHeight: 60.0,
        cellStyle: .value1
    )


    private lazy var tableViewData: [TableViewSection] = [
        TableViewSection(
            items: [userNameRow, nameRow, roleRow],
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

extension MyFleetUserProfileRootView: MyFleetUserProfileUserInterface {

    func render(userProfile: UserProfile) {
        nameRow.detail = userProfile.realName
        userNameRow.detail = userProfile.userName
        roleRow.detail = userProfile.get_role()
        tableView.reloadData()
    }

}

//MARK: - Private

private extension MyFleetUserProfileRootView {

    @objc func logoutButtonTapped(_ sender: UIButton) {
        ixResponder?.logout()
    }

    @objc func changePasswordButtonTapped(_ sender: UIButton) {
        ixResponder?.changePassword()
    }

}

extension MyFleetUserProfileRootView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].items.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewData[section].headerHeight
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
        cell.textLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        cell.detailTextLabel?.font = cell.textLabel?.font
        cell.separatorInset = UIEdgeInsets.zero
        cell.selectionStyle = .none

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

    }

}
