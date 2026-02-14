//
//  TriggeringVehicleListScopeSpecificStateView.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListScopeSpecificStateView: UIView {

    var dataSource: TriggeringVehicleListDataSource? = nil {
        didSet {
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            tableView.reloadData()
        }
    }

    private let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        infoLabel.text = NSLocalizedString("The vehicles that trigger this geo-fence when entering.", comment: "The vehicles that trigger this geo-fence when entering.")
        return infoLabel
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorInset = UIEdgeInsets.zero
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margin = layoutMargins.left
        let layoutFrame = layoutMarginsGuide.layoutFrame.insetBy(dx: 0.0, dy: margin)

        infoLabel.frame.size = infoLabel.sizeThatFits(layoutFrame.size)

        let dividedFrame = layoutFrame.divided(atDistance: infoLabel.frame.height, from: CGRectEdge.minYEdge)
        infoLabel.frame = dividedFrame.slice
        tableView.frame = dividedFrame.remainder.divided(atDistance: margin, from: CGRectEdge.minYEdge).remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    func applyTheme() {
        backgroundColor = UIColor.white
        infoLabel.textColor = UIColor.black
        tableView.backgroundColor = UIColor.white
        tableView.reloadData()
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(infoLabel)
        addSubview(tableView)

        tableView.dropShadow(ViewShadowConfig.default)

        applyTheme()
    }

}

class TriggeringVehicleListDataSource: TableArrayDataSource<VehicleProfile> {

    public convenience init(items: [VehicleProfile]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 50.0}),
                TableSetting.sectionHeaderHeight({_ in return 34.0}),
                TableSetting.viewForSectionHeader({_ in
                    return TriggeringVehicleListHeaderView()
                })
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .CustomClass(type: TriggeringVehicleListCell.self)
        }
        ) { (cell, item, indexPath) in
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            (cell as? TriggeringVehicleListCell)?.plateNumberLabel.text = item.plateNo

            if let name = item.name, !name.isEmpty {
                (cell as? TriggeringVehicleListCell)?.driverLabel.text = item.name
            }
            else {
                (cell as? TriggeringVehicleListCell)?.driverLabel.text = nil
            }
        }
    }

}

private class TriggeringVehicleListHeaderView: UIView {

    private let plateNumberLabel: UILabel = {
        let plateNumberLabel = UILabel()
        plateNumberLabel.text = NSLocalizedString("Plate Number", comment: "Plate Number")
        return plateNumberLabel
    }()

    private let driverLabel: UILabel = {
        let driverLabel = UILabel()
        driverLabel.text = NSLocalizedString("Driver", comment: "Driver")
        return driverLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = layoutMarginsGuide.layoutFrame
        let dividedFrame = layoutFrame.divided(atDistance: bounds.width / 2, from: CGRectEdge.minXEdge)
        plateNumberLabel.frame = dividedFrame.slice
        driverLabel.frame = dividedFrame.remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    func applyTheme() {
        [plateNumberLabel, driverLabel].forEach({ (label) in
            label.textColor = UIColor.black
            label.font = UIFont(name: "BeVietnamPro-Regular", size: 12.0)
        })
        backgroundColor = UIColor.white
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(plateNumberLabel)
        addSubview(driverLabel)

        applyTheme()
    }

}

