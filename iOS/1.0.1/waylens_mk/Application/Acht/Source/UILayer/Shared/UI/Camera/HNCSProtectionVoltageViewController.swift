//
//  HNCSProtectionVoltageViewController.swift
//  Acht
//
//  Created by forkon on 2019/8/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class HNCSProtectionVoltageViewController: HNCSRadioChoiceBaseViewController<BatteryProtectionChoice> {
    override var subTitle: String? {
        return NSLocalizedString("Which battery protection mode shall the camera utilize", comment: "Which battery protection mode shall the camera utilize")
    }

    override var choices: [BatteryProtectionChoice] {
        if isAdditionalChoiceShown {
            return BatteryProtectionChoice.allCases
        }
        else {
            return [BatteryProtectionChoice.dailyDriver, BatteryProtectionChoice.balanced, BatteryProtectionChoice.extended]
        }
    }

    override var selectedChoice: BatteryProtectionChoice? {
        didSet {
            if selectedChoice == .extreme {
                isAdditionalChoiceShown = true
            }
        }
    }

    private var isAdditionalChoiceShown: Bool = false

    private lazy var showAdditionalChoiceButton: UIButton = { [weak self] in
        let showAdditionalChoiceButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0))
        showAdditionalChoiceButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        showAdditionalChoiceButton.setTitle(NSLocalizedString("The camera often enter battery protection mode.", comment: "The camera often enter battery protection mode."), for: .normal)

        showAdditionalChoiceButton.addTarget(self, action: #selector(showAdditionalChoiceButtonTapped), for: .touchUpInside)

        return showAdditionalChoiceButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Battery Protection", comment: "Battery Protection")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedChoice = BatteryProtectionChoice(voltage: camera?.local?.protectionVoltage)
        updateUI()
    }

    override func applyTheme() {
        super.applyTheme()

        showAdditionalChoiceButton.setTitleColor(UIColor.semanticColor(.label(.primary)), for: .normal)
        showAdditionalChoiceButton.addUnderline(with: UIColor.semanticColor(.label(.primary)))
    }

    override func applySettingsIfNeeded() {
        super.applySettingsIfNeeded()

        if let selectedVoltage = selectedChoice?.voltage, camera?.local?.protectionVoltage != selectedVoltage {
            camera?.local?.doSetProtectionVoltage(selectedVoltage)
            camera?.local?.doGetProtectionVoltage()
        }
    }

    override func needsConfirmation(whenSelected newChoice: BatteryProtectionChoice) -> Bool {
        if newChoice == .extreme {
            return true
        }
        else {
            return false
        }
    }

    override func confirm(newChoice: BatteryProtectionChoice, permission: @escaping (Bool) -> ()) {
        let message = String(format: NSLocalizedString("When utilizing \"xx\", the vehicle may have ignition problem.\nAre you sure to select this mode?", comment: "When utilizing \"xx\", the vehicle may have ignition problem.\nAre you sure to select this mode?"), newChoice.name)

        alert(title: nil, message: message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive) { _ in
                permission(true)
            }
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default) { _ in
            }
        }
    }

}

private extension HNCSProtectionVoltageViewController {

    func updateUI() {
        tableView.reloadData()

        if let index = choices.firstIndex(where: { $0 == selectedChoice }) {
            self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }

        if isAdditionalChoiceShown {
            tableView.tableFooterView = nil
        }
        else {
            tableView.tableFooterView = showAdditionalChoiceButton
        }
    }

    @objc func showAdditionalChoiceButtonTapped() {
        isAdditionalChoiceShown = !isAdditionalChoiceShown
        updateUI()
    }

}

extension HNCSProtectionVoltageViewController: WLCameraSettingsDelegate {

    func onGetProtectionVoltage(_ voltage: Int32) {
        selectedChoice = BatteryProtectionChoice(voltage: voltage)
        updateUI()
    }

}

enum BatteryProtectionChoice {
    case dailyDriver
    case balanced
    case extended
    case extreme

    var voltage: Int32 {
        switch self {
        case .dailyDriver:
            return 12000
        case .balanced:
            return 11900
        case .extended:
            return 11800
        case .extreme:
            return 11701
        }
    }

    init?(voltage: Int32?) {
        switch voltage {
        case .some(BatteryProtectionChoice.dailyDriver.voltage):
            self = .dailyDriver
        case .some(BatteryProtectionChoice.balanced.voltage):
            self = .balanced
        case .some(BatteryProtectionChoice.extended.voltage):
            self = .extended
        case .some(BatteryProtectionChoice.extreme.voltage):
            self = .extreme
        default:
            return nil
        }
    }
}

extension BatteryProtectionChoice: ChoiceItem {

    var name: String {
        switch self {
        case .dailyDriver:
            return NSLocalizedString("Daily Driver", comment: "Battery Protection Choice")
        case .balanced:
            return NSLocalizedString("Balanced", comment: "Battery Protection Choice")
        case .extended:
            return NSLocalizedString("Extended", comment: "Battery Protection Choice")
        case .extreme:
            return NSLocalizedString("Extreme", comment: "Battery Protection Choice")
        }
    }

    var description: String {
        switch self {
        case .dailyDriver:
            return NSLocalizedString("Maintain higher than minimum battery voltage for colder climate starting or for shorter parking duration needs. Best for Daily driven vehicles.", comment: "Battery Protection Choice Description")
        case .balanced:
            return NSLocalizedString("Offers battery voltage protection and a generous parking mode time of up to 7 days. Best for business traveling and road trips.", comment: "Battery Protection Choice Description")
        case .extended:
            return NSLocalizedString("Intended for long term parking mode users who need the full 15 days of secure protection. May reduce battery voltage to lower than normal levels in cold climates. If the vehicle is parked for a longer time, it is recommended to disconnect the camera power cord.", comment: "Battery Protection Choice Description")
        case .extreme:
            return NSLocalizedString("Designed for vehicle batteries with low working voltage. Select this mode only if the camera often enters battery protection mode and be offline. If you select this mode, the vehicle may have ignition problem.", comment: "Battery Protection Choice Description")
        }
    }

}
