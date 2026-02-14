//
//  HNCSNightVisionViewController.swift
//  Acht
//
//  Created by Chester Shen on 2/5/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class HNCSNightVisionViewController: BaseTableViewController, CameraRelated {
    var camera: UnifiedCamera?
    @IBOutlet weak var parkingSwitch: UISwitch!
    @IBOutlet weak var parkingDecriptionLabel: UILabel!
    @IBOutlet weak var drivingSwitch: UISwitch!
    @IBOutlet weak var drivingConfigLabel: UILabel!
    @IBOutlet var drivingDecriptionLabels: [UILabel]!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    var datePicker: UIDatePicker!
    var settingStartTime: Bool = false
    var pendingStartTime: Int?
    var pendingEndTime: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Night Vision", comment: "Night Vision")
        let rect = CGRect(x: 0, y: view.bounds.height - 200, width: view.bounds.width, height: 200)
        datePicker = UIDatePicker(frame: rect)
        view.addSubview(datePicker)
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        datePicker.isHidden = true
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        camera?.local?.settingsDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if pendingEndTime != nil || pendingStartTime != nil {
            var config = camera?.drivingConfig
            if let time = pendingStartTime {
                config?.nightVisionStartTime = time
            }
            if let time = pendingEndTime {
                config?.nightVisionEndTime = time
            }
            camera?.drivingConfig = config
        }
        pendingStartTime = nil
        pendingEndTime = nil
    }
    
    func refreshUI() {
        tableView.reloadData()
        parkingSwitch.isOn = (camera?.parkingConfig?.nightVision == .on)
        
        if camera?.parkingConfig?.nightVision == .on {
            parkingDecriptionLabel.text = NSLocalizedString("night_vision_on_in_parking_mode_description", comment: "")
        } else {
            parkingDecriptionLabel.text = NSLocalizedString("night_vision_off_in_parking_mode_description", comment: "")
        }
        
        if camera?.featureAvailability.isAutoNightVisionAvailable == true {
            switch camera?.drivingConfig?.nightVision {
            case .some(.on):
                drivingConfigLabel.text = NSLocalizedString("Manual", comment: "")
                drivingDecriptionLabels.forEach { (label) in
                    label.text = NSLocalizedString("night_vision_manual_in_driving_mode_description", comment: "")
                }
            case .some(.auto):
                drivingConfigLabel.text = NSLocalizedString(camera?.drivingConfig?.nightVision?.rawValue.wl.capitalizingFirstLetter() ?? "", comment: "")
                drivingDecriptionLabels.forEach { (label) in
                    label.text = NSLocalizedString("night_vision_auto_in_driving_mode_description", comment: "")
                }
            case .some(.off):
                drivingConfigLabel.text = NSLocalizedString(camera?.drivingConfig?.nightVision?.rawValue.wl.capitalizingFirstLetter() ?? "", comment: "")
                drivingDecriptionLabels.forEach { (label) in
                    label.text = NSLocalizedString("night_vision_off_in_driving_mode_description", comment: "")
                }
            default:
                break
            }
        } else {
            drivingSwitch.isOn = (camera?.drivingConfig?.nightVision == .on)
        }
        
        if let time = camera?.drivingConfig?.nightVisionStartTime {
            fromLabel.text = timeToDate(time).toString(format: .timeMin12)
        }
        if let time = camera?.drivingConfig?.nightVisionEndTime {
            toLabel.text = timeToDate(time).toString(format: .timeMin12)
        }
    }
    
    @IBAction func onSwitchParking(_ sender: UISwitch) {
        camera?.parkingConfig?.nightVision = sender.isOn ? .on : .off
    }
    
    @IBAction func onSwitchDriving(_ sender: UISwitch) {
        camera?.drivingConfig?.nightVision = sender.isOn ? .on : .off
        if !sender.isOn {
            hideDatePicker()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let camera = camera else { return 0 }
        if camera.featureAvailability.isNightVisionInDrivingModeAvailable {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 1 {
            if camera?.featureAvailability.isAutoNightVisionAvailable == true {
                if row == 0 {
                    return 0
                }
                
                if camera?.drivingConfig?.nightVision == .auto || camera?.drivingConfig?.nightVision == .off {
                    if row == 2 || row == 3 {
                        return 0
                    }
                }
            } else {
                if row == 1 {
                    return 0
                }
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datePicker.isHidden {
            if indexPath.section == 1 {
                if indexPath.row == 1 {
                    let values = [
                        HNFeatureStatus.on,
                        HNFeatureStatus.auto,
                        HNFeatureStatus.off
                    ]
                    let displayValues = values.map { (status) -> String in
                        if status == .on {
                            return NSLocalizedString("Manual", comment: "")
                        } else {
                            return NSLocalizedString(status.rawValue.wl.capitalizingFirstLetter(), comment: "")
                        }
                    }
                    showPicker(withValues: displayValues) { [unowned self](index) in
                        self.camera?.drivingConfig?.nightVision = values[index]
                        self.refreshUI()
                    }
                } else if indexPath.row == 2 {
                    guard let time = pendingStartTime ?? camera?.drivingConfig?.nightVisionStartTime else { return }
                    settingStartTime = true
                    showDatePicker(time: time)
                    return
                } else if indexPath.row == 3 {
                    guard let time = pendingEndTime ?? camera?.drivingConfig?.nightVisionEndTime else { return }
                    settingStartTime = false
                    showDatePicker(time: time)
                    return
                }
            }
        } else {
            hideDatePicker()
        }
    }
    
    func showDatePicker(time: Int) {
        let date = timeToDate(time)
        if datePicker.isHidden {
            var inset = UIEdgeInsets.zero
            if #available(iOS 11.0, *) {
                inset = view.safeAreaInsets
            }
            let rect = CGRect(x: inset.left, y: view.bounds.height - 300 - inset.bottom, width: view.bounds.width - inset.right - inset.left, height: 300)
            datePicker.frame = rect
            datePicker.isHidden = false
        }
        datePicker.setDate(date, animated: true)
    }
    
    func hideDatePicker() {
        datePicker.isHidden = true
    }
    
    func timeToDate(_ time: Int) -> Date {
        let hour: Int = time / 60
        let minute: Int = time % 60
        let date = Date()
        return date.adjust(hour: hour, minute: minute, second: 0)
    }
    
    @objc func dateChanged(sender: UIDatePicker) {
        Log.verbose("Date did chagned")
        guard let hour = sender.date.component(.hour), let minute = sender.date.component(.minute) else { return }
        let time = hour * 60 + minute
        let timeStr = sender.date.toString(format: .timeMin12)
        if settingStartTime {
            fromLabel.text = timeStr
            pendingStartTime = time
//            camera?.drivingConfig?.nightVisionStartTime = time
        } else {
            toLabel.text = timeStr
            pendingEndTime = time
//            camera?.drivingConfig?.nightVisionEndTime = time
        }
    }
}

extension HNCSNightVisionViewController: WLCameraSettingsDelegate {
    
    func onGetMountConfig(_ config: [AnyHashable : Any]?) {
             refreshUI()
    }
    
}
