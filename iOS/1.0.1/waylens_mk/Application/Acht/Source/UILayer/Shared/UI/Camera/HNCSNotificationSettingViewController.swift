//
//  HNCSNotificationSettingViewController.swift
//  Acht
//
//  Created by forkon on 2018/10/11.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

struct HNCSNotificationSettings {
    var parkingMotionOn: Bool
    var parkingBumpOn: Bool
    var parkingImpactOn: Bool
    var drivingBumpOn: Bool
    var drivingImpactOn: Bool
    
    var isAllDisabled: Bool {
        return !parkingMotionOn && !parkingBumpOn && !parkingImpactOn && !drivingBumpOn && !drivingImpactOn
    }
    
    init(parkingMotionOn: Bool = false, parkingBumpOn: Bool = false, parkingImpactOn: Bool = false, drivingBumpOn: Bool = false, drivingImpactOn: Bool = false) {
        self.parkingMotionOn = parkingMotionOn
        self.parkingBumpOn = parkingBumpOn
        self.parkingImpactOn = parkingImpactOn
        self.drivingBumpOn = drivingBumpOn
        self.drivingImpactOn = drivingImpactOn
    }
    
    init(dictionary: [String : Any]) {
        self.parkingMotionOn = (dictionary["parkingMotionOn"] as? Bool) ?? false
        self.parkingBumpOn = (dictionary["parkingBumpOn"] as? Bool) ?? false
        self.parkingImpactOn = (dictionary["parkingImpactOn"] as? Bool) ?? false
        self.drivingBumpOn = (dictionary["drivingBumpOn"] as? Bool) ?? false
        self.drivingImpactOn = (dictionary["drivingImpactOn"] as? Bool) ?? false
    }
    
    mutating func enableAll() {
        parkingMotionOn = true
        parkingBumpOn = true
        parkingImpactOn = true
        drivingBumpOn = true
        drivingImpactOn = true
    }
    
    mutating func disableAll() {
        parkingMotionOn = false
        parkingBumpOn = false
        parkingImpactOn = false
        drivingBumpOn = false
        drivingImpactOn = false
    }
    
    func dictionaryValue() -> [String : Any] {
        return [
            "parkingMotionOn" : parkingMotionOn,
            "parkingBumpOn" : parkingBumpOn,
            "parkingImpactOn" : parkingImpactOn,
            "drivingBumpOn" : drivingBumpOn,
            "drivingImpactOn" : drivingImpactOn
        ]
    }
}

class HNCSNotificationSettingViewController: BaseTableViewController, CameraRelated {
    fileprivate var settings: HNCSNotificationSettings = HNCSNotificationSettings()
    fileprivate var settingsToSend: HNCSNotificationSettings {
        var settings = HNCSNotificationSettings()
        settings.parkingMotionOn = parkingMotionSwitch.isEnabled ? parkingMotionSwitch.isOn : !parkingMotionSwitch.isOn
        settings.parkingBumpOn = parkingBumpSwitch.isEnabled ? parkingBumpSwitch.isOn : !parkingBumpSwitch.isOn
        settings.parkingImpactOn = parkingImpactSwitch.isEnabled ? parkingImpactSwitch.isOn : !parkingImpactSwitch.isOn
        settings.drivingBumpOn = drivingBumpSwitch.isEnabled ? drivingBumpSwitch.isOn : !drivingBumpSwitch.isOn
        settings.drivingImpactOn = drivingImpactSwitch.isEnabled ? drivingImpactSwitch.isOn : !drivingImpactSwitch.isOn
        return settings
    }

    fileprivate var canChangeSettings: Bool = true {
        didSet {
            tableView.reloadSections([Configs.parkingSection, Configs.drivingSection], with: .none)
        }
    }
    
    fileprivate enum Configs {
        static let parkingSection: Int = 1
        static let drivingSection: Int = 2
    }
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var parkingMotionSwitch: UISwitch!
    @IBOutlet weak var parkingBumpSwitch: UISwitch!
    @IBOutlet weak var parkingImpactSwitch: UISwitch!
    @IBOutlet weak var drivingBumpSwitch: UISwitch!
    @IBOutlet weak var drivingImpactSwitch: UISwitch!
    
    var camera: UnifiedCamera?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Notifications", comment: "Notifications")
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
        HNMessage.show()
        WaylensClientS.shared.fetchNotificationSettings(camera!.sn) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let response):
                strongSelf.settings.parkingMotionOn = (response["PARKING_MOTION"] as? String) == "on" ? true : false
                strongSelf.settings.parkingBumpOn = (response["PARKING_HIT"] as? String) == "on" ? true : false
                strongSelf.settings.parkingImpactOn = (response["PARKING_HEAVY_HIT"] as? String) == "on" ? true : false
                strongSelf.settings.drivingBumpOn = (response["DRIVING_HIT"] as? String) == "on" ? true : false
                strongSelf.settings.drivingImpactOn = (response["DRIVING_HEAVY_HIT"] as? String) == "on" ? true : false
                strongSelf.updateUI()
            case .failure(let error):
                if let errorMsg = error?.localizedDescription {
                    strongSelf.alert(message: errorMsg)
                }
            }
            HNMessage.dismiss()
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 12.0
        }
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()
        
//        if section == 0 {
            header.backgroundColor = UIColor.clear
//        } else {
//            header.backgroundColor = UIColor.semanticColor(.background(.secondary))
//        }

        if section == Configs.parkingSection {
            header.text = NSLocalizedString("Park Mode", comment: "Park Mode")
        }
        if section == Configs.drivingSection {
            header.text = NSLocalizedString("Drive Mode", comment: "Drive Mode")
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == Configs.parkingSection || indexPath.section == Configs.drivingSection {
            if indexPath.item != tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
            } else {
                cell.separatorInset = UIEdgeInsets.zero
            }

        }
        return cell
    }

    fileprivate func updateUI() {
        notificationsSwitch.setOn(!settings.isAllDisabled, animated: true)
        parkingMotionSwitch.setOn(settings.parkingMotionOn, animated: true)
        parkingBumpSwitch.setOn(settings.parkingBumpOn, animated: true)
        parkingImpactSwitch.setOn(settings.parkingImpactOn, animated: true)
        drivingBumpSwitch.setOn(settings.drivingBumpOn, animated: true)
        drivingImpactSwitch.setOn(settings.drivingImpactOn, animated: true)
        tableView.reloadSections([Configs.parkingSection, Configs.drivingSection], with: .none)
    }
    
    fileprivate func enableAllOptionSwitches() {
        parkingMotionSwitch.isEnabled = true
        parkingBumpSwitch.isEnabled = true
        parkingImpactSwitch.isEnabled = true
        drivingBumpSwitch.isEnabled = true
        drivingImpactSwitch.isEnabled = true
    }
	
    fileprivate func optionSwitchValueChanged(_ theSwitch: UISwitch) {
        HNMessage.show()
        
        WaylensClientS.shared.updateNotificationSettings(
            camera!.sn,
            settings: settingsToSend
        ) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(_):
                if theSwitch == strongSelf.parkingMotionSwitch {
                    strongSelf.settings.parkingMotionOn = !strongSelf.settings.parkingMotionOn
                } else if theSwitch == strongSelf.parkingBumpSwitch {
                    strongSelf.settings.parkingBumpOn = !strongSelf.settings.parkingBumpOn
                } else if theSwitch == strongSelf.parkingImpactSwitch {
                    strongSelf.settings.parkingImpactOn = !strongSelf.settings.parkingImpactOn
                } else if theSwitch == strongSelf.drivingBumpSwitch {
                    strongSelf.settings.drivingBumpOn = !strongSelf.settings.drivingBumpOn
                } else {
                    strongSelf.settings.drivingImpactOn = !strongSelf.settings.drivingImpactOn
                }
                strongSelf.updateUI()
            case .failure(let error):
                if let errorMsg = error?.localizedDescription {
                    strongSelf.alert(message: errorMsg)
                }
            }
            
            HNMessage.dismiss()
            theSwitch.isEnabled = true
        }
        
        theSwitch.isEnabled = false
        
        if theSwitch == parkingMotionSwitch {
            theSwitch.setOn(settings.parkingMotionOn, animated: true)
        } else if theSwitch == parkingBumpSwitch {
            theSwitch.setOn(settings.parkingBumpOn, animated: true)
        } else if theSwitch == parkingImpactSwitch {
            theSwitch.setOn(settings.parkingImpactOn, animated: true)
        } else if theSwitch == drivingBumpSwitch {
            theSwitch.setOn(settings.drivingBumpOn, animated: true)
        } else {
            theSwitch.setOn(settings.drivingImpactOn, animated: true)
        }
    }
    
}

extension HNCSNotificationSettingViewController {
    
    @IBAction fileprivate func notificationsSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        
        sender.isEnabled = false

        if sender.isOn {
            sender.setOn(false, animated: true)
            
            let savedSettings = UserSetting.shared.notificationSettings
            
            HNMessage.show()
            WaylensClientS.shared.updateNotificationSettings(
                camera!.sn,
                parkingMotionOn: savedSettings.isAllDisabled ? true : savedSettings.parkingMotionOn,
                parkingBumpOn: savedSettings.isAllDisabled ? true : savedSettings.parkingBumpOn,
                parkingImpactOn: savedSettings.isAllDisabled ? true : savedSettings.parkingImpactOn,
                drivingBumpOn: savedSettings.isAllDisabled ? true : savedSettings.drivingBumpOn,
                drivingImpactOn: savedSettings.isAllDisabled ? true : savedSettings.drivingImpactOn
            ) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(_):
                    strongSelf.settings = savedSettings
                    if strongSelf.settings.isAllDisabled {
                        strongSelf.settings.enableAll()
                        UserSetting.shared.notificationSettings = strongSelf.settings
                    }
                    strongSelf.updateUI()
                case .failure(let error):
                    if let errorMsg = error?.localizedDescription {
                        strongSelf.alert(message: errorMsg)
                    }
                }
                
                HNMessage.dismiss()
                sender.isEnabled = true
                strongSelf.canChangeSettings = true
            }
        } else {
            sender.setOn(true, animated: true)
            
            let alertVC = UIAlertController(
                title: NSLocalizedString("Disable notification for all events?", comment: "Disable notification for all events?"),
                message: NSLocalizedString("You will not receive any notifications when events are detected", comment: "You will not receive any notifications when events are detected"),
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(title: NSLocalizedString("Keep it on", comment: "Keep it on"), style: .cancel) { [weak self] (action) in
                guard let strongSelf = self else {
                    return
                }
                
                sender.isEnabled = true
                strongSelf.canChangeSettings = true
            }
            let disableAction = UIAlertAction(title: NSLocalizedString("Disable Alerts", comment: "Disable Alerts"), style: UIAlertAction.Style.destructive) { [weak self] (action) in
                guard let strongSelf = self else {
                    return
                }
                
                UserSetting.shared.notificationSettings = strongSelf.settings
                
                HNMessage.show()
                WaylensClientS.shared.updateNotificationSettings(
                    strongSelf.camera!.sn,
                    parkingMotionOn: false,
                    parkingBumpOn: false,
                    parkingImpactOn: false,
                    drivingBumpOn: false,
                    drivingImpactOn: false
                ) { (result) in
                    switch result {
                    case .success(_):
                        strongSelf.settings.disableAll()
                        strongSelf.updateUI()
                    case .failure(let error):
                        if let errorMsg = error?.localizedDescription {
                            strongSelf.alert(message: errorMsg)
                        }
                    }
                    
                    HNMessage.dismiss()
                    sender.isEnabled = true
                    strongSelf.enableAllOptionSwitches()
                    strongSelf.canChangeSettings = true
                }
                
            }
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(disableAction)
            present(alertVC, animated: true, completion: nil)
            
            canChangeSettings = false
        }
    }
    
    @IBAction fileprivate func parkingMotionSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        optionSwitchValueChanged(sender)
    }
    
    @IBAction fileprivate func parkingBumpSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        optionSwitchValueChanged(sender)
    }
    
    @IBAction fileprivate func parkingImpactSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        optionSwitchValueChanged(sender)
    }
    
    @IBAction fileprivate func drivingBumpSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        optionSwitchValueChanged(sender)
    }
    
    @IBAction fileprivate func drivingImpactSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isEnabled else {
            return
        }
        optionSwitchValueChanged(sender)
    }
}

fileprivate class HeaderView: UIView {
    private var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.semanticColor(.label(.primary))
        return label
    }()
    
    var text: String? = nil {
        didSet {
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 25.0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0)
        ])
    }
    
}
