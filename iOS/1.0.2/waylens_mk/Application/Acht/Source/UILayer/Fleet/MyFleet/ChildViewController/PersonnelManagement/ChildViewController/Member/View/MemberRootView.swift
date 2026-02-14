//
//  MemberRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MemberRootView: ViewContainTableViewAndBottomButton {

    weak var ixResponder: MemberIxResponder?

//    private let emailRow = TableViewRow(
//        title: NSLocalizedString("Email", comment: "Email"),
//        cellHeight: 60.0,
//        cellStyle: .value1
//    )

    private let roleRow = TableViewRow(
        title: NSLocalizedString("Role", comment: "Role"),
        cellHeight: 60.0,
        cellStyle: .value1
    )

    private let nameRow = TableViewRow(
        title: NSLocalizedString("Name", comment: "Name"),
        cellHeight: 60.0,
        cellStyle: .value1
    )
    
    private let userNameRow = TableViewRow(
        title: NSLocalizedString("User Name", comment: "User Name"),
        cellHeight: 60.0,
        cellStyle: .value1
    )

    
//    private let phoneNumberRow = TableViewRow(
//        title: NSLocalizedString("Phone Number", comment: "Phone Number"),
//        cellHeight: 60.0,
//        cellStyle: .value1
//    )

    private lazy var tableViewData: [TableViewSection] = [
        TableViewSection(
           // items: [nameRow, roleRow, emailRow, phoneNumberRow],
            items: [userNameRow,nameRow, roleRow],
            headerHeight: 0.001
        )
    ]

    override init() {
        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        let avatarHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 600.0, height: 100.0))

        let avatarImageView = UIImageView(image: #imageLiteral(resourceName: "Driver"))
        avatarImageView.frame = CGRect(x: 0, y: 0, width: 52.0, height: 52.0)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        avatarHeaderView.addSubview(avatarImageView)

        avatarImageView.centerXAnchor.constraint(equalTo: avatarHeaderView.centerXAnchor).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: avatarHeaderView.centerYAnchor).isActive = true

        tableView.tableHeaderView = avatarHeaderView

        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        tableView.tableHeaderView?.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
    }
}

extension MemberRootView: MemberUserInterface {

    func render(newState: MemberViewControllerState) {
       
        let scene = newState.scene
        let memberProfile = newState.memberProfile
     //   let roles = memberProfile.roles

        userNameRow.detail = memberProfile.get_userName()
        nameRow.detail = memberProfile.getName()
        roleRow.detail = memberProfile.get_role()
        
        //emailRow.detail = memberProfile.email
       // phoneNumberRow.detail = memberProfile.phoneNumber

        if scene == .addingNew {
            tableViewData = [
             TableViewSection(
                 items: [userNameRow,nameRow],
                 headerHeight: 0.001
             )]
            removeAllBottomItemViews()

            let saveButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Save", comment: "Save"), color: UIColor.semanticColor(.tint(.primary)))
            saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
            saveButton.setBackgroundImage(with: UIColor.semanticColor(.background(.quaternary)), for: .disabled)
            addBottomItemView(saveButton)

            func isValidProfile() -> Bool {
//                if roles.contains(.fleetManager) {
//                    if memberProfile.name.isEmpty || memberProfile.email == nil || memberProfile.email?.isEmpty == true {
//                        return false
//                    }
//                }
//                else if roles.contains(.driver) {
//                    if memberProfile.name.isEmpty {
//                        return false
//                    }
//                }
                if memberProfile.name.isEmpty || memberProfile.email == nil || memberProfile.email?.isEmpty == true {
                    return false
                }
                return true
            }

            saveButton.isEnabled = isValidProfile()

            if newState.viewState.isEditing {
                tableViewData.first?.items.forEach({ (row) in
                    row.detailViewControllerClass = MemberProfileInfoComposingViewController.self
                })
            } else {
                tableViewData.first?.items.forEach({ (row) in
                    row.detailViewControllerClass = nil
                })
            }
        } else {
            removeAllBottomItemViews()

            if !memberProfile.isOwner {
                if UserSetting.current.userProfile?.isOwner == true && memberProfile.roles.contains(.fleetManager) && memberProfile.isVerified {
                    let setOwnerButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Set as Fleet Owner", comment: "Set as Fleet Owner"), color: UIColor.semanticColor(.tint(.primary)))
                    setOwnerButton.addTarget(self, action: #selector(setOwnerButtonTapped(_:)), for: .touchUpInside)
                    addBottomItemView(setOwnerButton)
                }

                let removeButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Remove", comment: "Remove"), color: UIColor.semanticColor(.background(.tertiary)))
                removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(removeButton)
            }


            if newState.viewState.isEditing {
                tableViewData.first?.items.forEach({ (row) in
                    row.detailViewControllerClass = MemberProfileInfoComposingViewController.self
                })
            } else {
                tableViewData.first?.items.forEach({ (row) in
                    row.detailViewControllerClass = nil
                })
            }
        }

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

        tableView.reloadData()
    }

    func render(memberProfile: MemberProfile) {

    }

}

//MARK: - Private

private extension MemberRootView {

    @objc func saveButtonTapped(_ sender: Any) {
        ixResponder?.saveMember()
    }

    @objc func removeButtonTapped(_ sender: Any) {
        ixResponder?.removeMember()
    }

    @objc func setOwnerButtonTapped(_ sender: Any) {
        ixResponder?.setAsFleetOwner()
    }

}

extension MemberRootView: UITableViewDataSource, UITableViewDelegate {

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
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = tableViewData[indexPath.section].items[indexPath.row]

        if item.detailViewControllerClass != nil {
            if tableViewData.first?.items[indexPath.row] === nameRow {
                ixResponder?.beginComposeProfileInfo(.name(""))
            }
            else if tableViewData.first?.items[indexPath.row] === roleRow {
                ixResponder?.beginComposeProfileInfo(.role(UserRoles.driver))
            }
            else if tableViewData.first?.items[indexPath.row] === userNameRow {
                ixResponder?.beginComposeProfileInfo(.user_name(""))
            }
//            else if tableViewData.first?.items[indexPath.row] === emailRow {
//                ixResponder?.beginComposeProfileInfo(.email(""))
//            }
//            else if tableViewData.first?.items[indexPath.row] === phoneNumberRow {
//                ixResponder?.beginComposeProfileInfo(.phoneNumber(""))
//            }
        }
    }

}
