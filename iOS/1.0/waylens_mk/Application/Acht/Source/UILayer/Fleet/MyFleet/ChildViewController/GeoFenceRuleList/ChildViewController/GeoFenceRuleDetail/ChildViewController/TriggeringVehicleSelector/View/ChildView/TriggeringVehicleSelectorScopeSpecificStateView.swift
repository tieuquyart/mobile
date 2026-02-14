//
//  TriggeringVehicleSelectorScopeSpecificStateView.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleSelectorScopeSpecificStateView: UIView, Themed {

    var dataSource: TriggeringVehicleSelectorDataSource? = nil {
        didSet {
            reloadData()
        }
    }

    private(set) var saveButton: UIButton = {
        let saveButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Save", comment: "Save"), color: UIColor.semanticColor(.tint(.primary)))
        return saveButton
    }()

    private let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 14.0)
        infoLabel.text = NSLocalizedString("The vehicles that trigger this geo-fence when entering.", comment: "The vehicles that trigger this geo-fence when entering.")
        return infoLabel
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.allowsMultipleSelection = true
        tableView.separatorInset = UIEdgeInsets.zero
        return tableView
    }()

    private lazy var selectAllView: SelectAllView = { [weak self] in
        let selectAllView = SelectAllView()
        selectAllView.backgroundColor = UIColor.clear

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAllViewTapped))
        selectAllView.addGestureRecognizer(tapGestureRecognizer)

        return selectAllView
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

        let buttonHeight: CGFloat = 50.0
        saveButton.frame = dividedFrame.remainder.divided(atDistance: buttonHeight, from: CGRectEdge.maxYEdge).slice

        let selectAllViewHeight: CGFloat = 60.0
        selectAllView.frame = dividedFrame.remainder.divided(atDistance: buttonHeight, from: CGRectEdge.maxYEdge).remainder.divided(atDistance: selectAllViewHeight, from: CGRectEdge.maxYEdge).slice
        tableView.frame = dividedFrame.remainder.divided(atDistance: buttonHeight, from: CGRectEdge.maxYEdge).remainder.divided(atDistance: selectAllViewHeight, from: CGRectEdge.maxYEdge).remainder.divided(atDistance: margin, from: CGRectEdge.minYEdge).remainder
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
        backgroundColor = UIColor.semanticColor(.background(.secondary))
        infoLabel.textColor = UIColor.semanticColor(.label(.primary))
        selectAllView.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        tableView.backgroundColor = UIColor.semanticColor(.cardBackground)

        reloadData()
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(infoLabel)
        addSubview(tableView)
        addSubview(selectAllView)
        addSubview(saveButton)

        tableView.dropShadow(ViewShadowConfig.default)

        applyTheme()
    }

    @objc private func selectAllViewTapped() {
        if !allRowsAreSelected() {
            tableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
                dataSource?.tableItemSelectionHandler?(indexPath)
            })
        }

        Array(0..<totalRows()).map{IndexPath(row: $0, section: 0)}.forEach { (indexPath) in
            dataSource?.tableItemSelectionHandler?(indexPath)
        }

    }

    private func totalRows() -> Int {
        return tableView.numberOfRows(inSection: 0)
    }

    private func allRowsAreSelected() -> Bool {
        let total = totalRows()

        if total != 0, tableView.indexPathsForSelectedRows?.count == total {
            return true
        }
        else {
            return false
        }
    }

}

private extension TriggeringVehicleSelectorScopeSpecificStateView {

    func reloadData() {
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        tableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
            tableView.deselectRow(at: indexPath, animated: false)
        })

        dataSource?.selectedItems.forEach({ (vehicleId) in
            if let index = dataSource?.provider.items.first?.firstIndex(where: {$0.vehicleID == vehicleId}) {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
        })

        if allRowsAreSelected() {
            selectAllView.isSelected = true
        }
        else {
            selectAllView.isSelected = false
        }
    }

}

class TriggeringVehicleSelectorDataSource: TableArrayDataSource<VehicleProfile> {

    public private(set) var selectedItems: [VehicleId] = []

    public convenience init(items: [VehicleProfile], selectedItems: [VehicleId]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 50.0}),
                TableSetting.sectionHeaderHeight({_ in return 34.0}),
                TableSetting.viewForSectionHeader({_ in
                    return TriggeringVehicleSelectorHeaderView()
                })
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .CustomClass(type: TriggeringVehicleSelectorCell.self)
        }
        ) { (cell, item, indexPath) in
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            (cell as? TriggeringVehicleSelectorCell)?.plateNumberLabel.text = item.plateNo

            if let name = item.name, !name.isEmpty {
                (cell as? TriggeringVehicleSelectorCell)?.driverLabel.text = item.name
            }
            else {
                (cell as? TriggeringVehicleSelectorCell)?.driverLabel.text = nil
            }
        }

        self.selectedItems = selectedItems

        appendCellConfigurator { [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            if let vehicleID = item.vehicleID, self.selectedItems.contains(vehicleID) {
                cell.setSelected(true, animated: false)
            }
            else {
                cell.setSelected(false, animated: false)
            }
        }
    }

}

private class TriggeringVehicleSelectorHeaderView: UIView, Themed {

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

    private var saveButton: UIButton = {
        let saveButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Save", comment: "Save"), color: UIColor.semanticColor(.tint(.primary)))
        return saveButton
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
        let dividedFrame = layoutFrame.divided(atDistance: 34.0, from: CGRectEdge.minXEdge)
        plateNumberLabel.frame = dividedFrame.remainder.divided(atDistance: dividedFrame.remainder.size.width / 2, from: CGRectEdge.minXEdge).slice
        driverLabel.frame = dividedFrame.remainder.divided(atDistance: dividedFrame.remainder.size.width / 2, from: CGRectEdge.minXEdge).remainder
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
            label.textColor = UIColor.semanticColor(.label(.primary))
            label.font = UIFont.systemFont(ofSize: 12.0)
        })
        backgroundColor = UIColor.semanticColor(.cardHeaderBackground)
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(plateNumberLabel)
        addSubview(driverLabel)

        applyTheme()
    }

}

private class SelectAllView: UITableViewCell, Themed {

    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView?.image = #imageLiteral(resourceName: "checkbox_selected")
            }
            else {
                imageView?.image = #imageLiteral(resourceName: "checkbox_empty")
            }
        }
    }

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }

    required init?(coder: NSCoder) {
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

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)
        
        textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        textLabel?.text = NSLocalizedString("Select All", comment: "Select All")
        isSelected = false

        applyTheme()
    }

    func applyTheme() {
        backgroundView = nil
        selectionStyle = .none
        selectedBackgroundView = nil
        textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        imageView?.tintColor = UIColor.semanticColor(.tint(.primary))
    }

}
