//
//  HNCSAccelerometerOptionViewController.swift
//  Acht
//
//  Created by gliu on 6/5/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class HNCSAccelerometerOptionViewController: BaseTableViewController, CameraRelated, UITextFieldDelegate {

    @IBOutlet weak var debugInput: UITextField!
    @IBOutlet weak var radarSensitivity: UISlider!

    //debug props
    @IBOutlet weak var debugPropInput: UITextField!
    @IBOutlet weak var debugActionInput: UITextField!
    @IBOutlet weak var debugValueInput: UITextField!
    @IBOutlet weak var debugKeyInput: UITextField!
    @IBOutlet weak var debugResultLabel: UILabel!

    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var currentLevel : String?
    var allLevels = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        self.title = NSLocalizedString("Sensitivity", comment: "Sensitivity")
        self.debugInput.delegate = self
        self.radarSensitivity.minimumValue = 0
        self.radarSensitivity.maximumValue = 10
        self.radarSensitivity.value = 0

        self.debugPropInput.text = ""
        self.debugActionInput.text = ""
        self.debugValueInput.text = ""
        self.debugKeyInput.text = "waylens.com"
        self.debugResultLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.camera?.local != nil {
            camera?.local?.settingsDelegate = self
            camera?.local?.getMountAccelLevels()
            if camera?.local?.isSupportRadarSensitivity ?? false {
                camera?.local?.getRadarSensitivity()
            }
            camera?.local?.getMountAccelParam(HNAccLevel.custom.rawValue)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }

        super.viewWillDisappear(animated)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return camera?.local?.isSupportRadarSensitivity ?? false ? NSLocalizedString("sensitivity_settings_motion_description", comment: "Adjust Motion Sensitivity settings if you want less or more Motion events to be detected.") : nil
        } else if section == 1 {
            return NSLocalizedString("sensitivity_settings_impact_description", comment: "Adjust Impact Sensitivity settings if you want less or more Bump or Impact events to be detected.")
        } else if section == 2 {
            return "[park_heavy park_light drive_heavy drive_light]; \n for each set, {odr width threshold}\n for example, [80 4 12 80 4 3 112 2 64 112 20 21]"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && !(camera?.local?.isSupportRadarSensitivity ?? false) {
            return 0.01
        }
        if section == 2 {
            return 35
        }
        if section == 3 {
            return 35
        }
        return tableView.sectionHeaderHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 2
        if UserSetting.shared.debugEnabled {
            sections += 2
        }
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (camera?.local?.isSupportRadarSensitivity ?? false) ? 2 : 0
        } else if section == 1 {
            return allLevels.count+1
        } else if section == 2 {
            return 2
        } else if section == 3 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
        if indexPath.section == 1 && indexPath.row > 0 {
            let level = allLevels[indexPath.row-1]
            if let accLevel = HNAccLevel(rawValue: level) {
                cell.textLabel?.text = accLevel.displayName
                cell.detailTextLabel?.text = accLevel.description
            } else {
                cell.textLabel?.text = level
            }
            if currentLevel == level {
                cell.accessoryType = .checkmark
            }
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            cell.textLabel?.text = HNAccLevel.custom.displayName
            if currentLevel == HNAccLevel.custom.rawValue {
                cell.accessoryType = .checkmark
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 1 && indexPath.row > 0 ) {
            camera?.local?.setMountAccelLevel(allLevels[indexPath.row-1])
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            camera?.local?.setMountAccelLevel(HNAccLevel.custom.rawValue)
        }
    }

    //
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil && textField.text != "" {
            camera?.local?.setMountAccelForLevel(HNAccLevel.custom.rawValue, param: textField.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func onRadarSensitivityChanged() {
        Log.debug("Change radar sensitivity: \(Int32(self.radarSensitivity.value))")
        camera?.local?.setRadarSensitivity(Int32(self.radarSensitivity.value))

    }
    @IBAction func onDebugPropSet() {
        camera?.local?.doDebugProps(true, prop: self.debugPropInput.text!, action: self.debugActionInput.text!, value: self.debugValueInput.text!, key: self.debugKeyInput.text!)
    }
    @IBAction func onDebugPropGet() {
        camera?.local?.doDebugProps(false, prop: self.debugPropInput.text!, action: self.debugActionInput.text!, value: self.debugValueInput.text!, key: self.debugKeyInput.text!)
    }
}

extension HNCSAccelerometerOptionViewController: WLCameraSettingsDelegate {
    func onGetMountAccelLevels(_ levels: [Any]?, current: String?) {
        allLevels.removeAll()
        allLevels = levels as! [String]
        currentLevel = current
        self.tableView.reloadData()
    }
    func onSetMountAccelLevel(_ result: Bool) {
        camera?.local?.getMountAccelLevels()
    }
    func onGetMountAccelParam(_ param: String?) {
        self.debugInput.text = param
    }
    func onSetMountAccelParam(_ result: Bool) {
        //
    }

    func onGetRadarSensitivity(_ level: Float) {
        self.radarSensitivity.value = level
    }
    func onSetRadarSensitivity(_ level: Float) {
        self.radarSensitivity.value = level
    }
    func onDebugProp(_ prop: String?, value: String?) {
        self.debugResultLabel.text = value
        self.debugPropInput.text = prop
        self.debugValueInput.text = value
        self.debugActionInput.text = ""
    }
}
