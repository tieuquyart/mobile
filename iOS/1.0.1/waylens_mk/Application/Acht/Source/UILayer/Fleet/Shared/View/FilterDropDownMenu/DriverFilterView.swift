//
//  DriverFilterView.swift
//  Fleet
//
//  Created by forkon on 2019/12/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import YNDropDownMenu

class DriverFilterView: YNDropDownView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    
    var drivers: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private(set) var selectedDrivers: Set<String> = []

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.backgroundColor = UIColor.clear
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        applyTheme()
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

private extension DriverFilterView {

    func updateUI() {
        let selectedItemsCount = selectedDrivers.count
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done") + ((selectedItemsCount != 0) ? "(\(selectedItemsCount))" : ""), for: .normal)
        changeMenu(title: NSLocalizedString("Driver", comment: "Driver") + ((selectedItemsCount != 0) ? " (\(selectedItemsCount))" : ""), at: 1)
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        hideMenu()
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        selectedDrivers.removeAll()
        updateUI()
        hideMenu()
    }

}

extension DriverFilterView: Themed {

    func applyTheme() {
        seperatorView.backgroundColor = UIColor.semanticColor(.separator(.opaque))
        tableView.reloadData()
    }

}

extension DriverFilterView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = drivers[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = UIColor.clear
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        cell.selectionStyle = .none

        let driver = drivers[indexPath.row]
        if selectedDrivers.contains(driver) {
            cell.textLabel?.textColor = UIColor.semanticColor(.tint(.primary))
        } else {
            cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let driver = drivers[indexPath.row]

        if selectedDrivers.contains(driver) {
            selectedDrivers.remove(driver)
        } else {
            selectedDrivers.insert(driver)
        }

        tableView.reloadRows(at: [indexPath], with: .none)

        updateUI()
    }

}

extension DriverFilterView: DataFilterGenerator {

    func dataFilter() -> DataFilter {
        return DriverFilter(namesToMatch: Array(selectedDrivers))
    }

}

extension DriverFilterView: NibCreatable {}

