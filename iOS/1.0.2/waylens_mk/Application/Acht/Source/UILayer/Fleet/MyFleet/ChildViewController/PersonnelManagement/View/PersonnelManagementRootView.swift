//
//  PersonnelManagementRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class PersonnelManagementRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: PersonnelManagementIxResponder?

    private var tableViewData: [FleetMember] = []

    private var tableViewSectionProvider = TableViewSectionProvider(sectionTemplates: { () -> [TableViewSection] in
        return [
            TableViewSection(rows:
                [
                    TableViewRowCustom<UITableViewCell, FleetMember>(cellInstantiateType: .Class(cellStyle: .subtitle), cellSetup: { (cell) in
                        cell.imageView?.image = #imageLiteral(resourceName: "Driver")
                        cell.imageView?.contentMode = .center
                        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
                        cell.detailTextLabel?.font = cell.textLabel?.font
                        cell.detailTextLabel?.textColor = UIColor.semanticColor(.label(.primary))
                        cell.separatorInset = UIEdgeInsets.zero
                        cell.accessoryType = .disclosureIndicator
                    }, cellDataMapper: { (cell, member) in
                        cell.detailTextLabel?.text = member.roles.description

                        var tag: String? = nil
                        var tagBackgroundColor: UIColor = UIColor.clear
//
//                        if member.isOwner {
//                            tag = NSLocalizedString("Fleet Owner", comment: "Fleet Owner")
//                            tagBackgroundColor = UIColor.semanticColor(.tint(.primary))
//                        } else {
//                            if !member.isVerified {
//                                tag = NSLocalizedString("Not-Verified", comment: "Not-Verified")
//                                tagBackgroundColor = UIColor.semanticColor(.memberTagBackground)
//                            }
//                        }

                        cell.textLabel?.attributedText = NSAttributedString.titleAndTagString(
                            title: member.name,
                            titleFont: UIFont.systemFont(ofSize: 14.0),
                            tag: tag,
                            tagBackgroundColor: tagBackgroundColor
                        )
                    })
                        .configure(handler: { (row) in
                            row.cellHeight = 90.0
                        })
                ],
                             headerHeight: 0.001
            )
        ]
    }, sectionGetter: { (section) -> Int in
        return 0
    }) { (indexPath) -> Int in
        return 0
    }

    override init() {
        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        let addButton = ButtonFactory.makeBigBottomButton(
            NSLocalizedString("+ Add New Member", comment: "+ Add New Member"),
            titleColor: UIColor.semanticColor(.tint(.primary)),
            color: UIColor.clear,
            borderColor: UIColor.semanticColor(.tint(.primary))
        )
        addButton.addTarget(self, action: #selector(addNewMemberButtonTapped(_:)), for: .touchUpInside)
        addBottomItemView(addButton)

        setupStatefulView()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tableView.reloadData()
            }
        }
    }
}

extension PersonnelManagementRootView: PersonnelManagementUserInterface {

    func render(newState: PersonnelManagementViewControllerState) {
        self.tableViewData = newState.members
        tableView.reloadData()

        if newState.hasFinishedFirstLoading && lastState == .loading {
            endLoading()
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        }
    }

}

//MARK: - Private

private extension PersonnelManagementRootView {

    @objc func addNewMemberButtonTapped(_ sender: UIButton) {
        ixResponder?.presentAddNewMember()
    }

}

extension PersonnelManagementRootView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSectionProvider.sectionTemplates[tableViewSectionProvider.sectionGetter(section)].headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewSectionProvider.sectionTemplates[tableViewSectionProvider.sectionGetter(indexPath.section)].rows[tableViewSectionProvider.rowGetter(indexPath)].cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableViewSectionProvider.sectionTemplates[tableViewSectionProvider.sectionGetter(indexPath.section)].rows[tableViewSectionProvider.rowGetter(indexPath)]

        let cell: UITableViewCell = {
            switch item.cellInstantiateType {
            case .Class(let cellStyle):
                let reuseIdentifier = "\(item.cellType)-\(cellStyle.rawValue)"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                    return item.cellType.init(style: cellStyle, reuseIdentifier: reuseIdentifier)
                }

                return cell
            default:
                fatalError("unknown cellInstantiateType")
            }

        }()

        item.cellSetup?(cell)
        (item as? TableViewRowCustom)?.cellDataMapper?(cell, tableViewData[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let member = tableViewData[indexPath.row]
        ixResponder?.showDetail(for: member)
    }

}
