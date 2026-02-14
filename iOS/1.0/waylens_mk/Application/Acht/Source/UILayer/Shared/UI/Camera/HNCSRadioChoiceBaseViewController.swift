//
//  HNCSRadioChoiceBaseViewController.swift
//  Acht
//
//  Created by forkon on 2019/8/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ChoiceItem: CaseIterable, Equatable {
    var name: String { get }
    var description: String { get }
}

class HNCSRadioChoiceBaseViewController<ChoiceType: ChoiceItem>: HNCSSettingsBaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    open var choices: [ChoiceType] {
        return ChoiceType.allCases as! [ChoiceType]
    }

    open var subTitle: String? {
        return nil
    }

    private var _selectedChoice: ChoiceType? = nil
    var selectedChoice: ChoiceType? {
        set {
            _selectedChoice = newValue

            if let index = choices.firstIndex(where: { $0 == newValue }) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                }
            }
        }

        get {
            return _selectedChoice
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: HNCSRadioChoiceCell.nibName!, bundle: nil), forCellReuseIdentifier: "HNCSRadioChoiceCell")
    }

    open func needsConfirmation(whenSelected newChoice: ChoiceType) -> Bool {
        return false
    }

    open func confirm(newChoice: ChoiceType, permission: @escaping (_ granted: Bool) -> ()) {

    }

    func calucalteHeaderHeight() -> CGFloat {
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: nil)
        headerView.frame.size.width = tableView.frame.width
        headerView.textLabel?.text = subTitle
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        if let textLabelHeight = headerView.textLabel?.frame.height {
            return textLabelHeight + 10.0
        } else {
            return Constants.UI.sectionHeaderHeight
        }
    }

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }

    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return subTitle
    }

    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return calucalteHeaderHeight()
    }

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HNCSRadioChoiceCell") as! HNCSRadioChoiceCell

        let choice = choices[indexPath.row]
        cell.nameLabel.text = choice.name
        cell.detailLabel.text = choice.description

        return cell
    }

    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedChoice = selectedChoice

        let choice = choices[indexPath.row]

        guard choice != oldSelectedChoice else {
            return
        }

        if needsConfirmation(whenSelected: choice) {
            tableView.deselectRow(at: indexPath, animated: false)

            selectedChoice = oldSelectedChoice

            confirm(newChoice: choice) { [weak self] (granted) in
                guard let self = self else {
                    return
                }

                if granted {
                    self.selectedChoice = choice
                }
            }
        }
        else {
            _selectedChoice = choice
        }
    }
}
