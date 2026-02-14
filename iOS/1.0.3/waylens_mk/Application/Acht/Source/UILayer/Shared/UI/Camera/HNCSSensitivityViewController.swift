//
//  HNCSSensitivityViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/14/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif
import WaylensFoundation
import WaylensCameraSDK

class HNCSSensitivityViewController: BaseTableViewController, CameraRelated {

    var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded && isVisible {
                updateLocalSettings()
                refreshUI()
            }
        }
    }
    typealias Option = HNSegmentedSliderView.Option
    var alertOptions: [Option]!
    var uploadOptions: [Option]!
    var detectOptions: [Option]!
    var shouldShowMotionSensitivity: Bool {
        return camera?.local?.isSupportRadarSensitivity ?? false
    }
    var shouldShowNotification: Bool {
        return (camera?.supports4g ?? false) && AccountControlManager.shared.isAuthed && camera?.ownerUserId == AccountControlManager.shared.keyChainMgr.userID
    }

    @IBOutlet weak var modeSegControl: HNTagSegmentedControl!
    @IBOutlet weak var alertSliderView: HNSegmentedSliderView!
    @IBOutlet weak var uploadSliderView: HNSegmentedSliderView!

    let expandableCellId = "ExpandableSliderCell"
    weak var motionSensitivitySlider: UISlider?
    weak var impactSensitivitySlider: ScaledSlider?
    var expandableModels = [ExpandableCellModel]()
    var motionSensitivity: Float = 0 {
        didSet {
            motionSensitivitySlider?.value = motionSensitivity
        }
    }
    var impactSensitivityLevel: String?
    var impactSensitivityLevels = [String]()
    var isVisible: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Sensitivity", comment: "Sensitivity")
        generateSliderOptions()

        modeSegControl.bouncesOnChange = false
        modeSegControl.titles = [NSLocalizedString("Parking", comment: "Parking"), NSLocalizedString("Driving", comment: "Driving")]
        try! modeSegControl.setIndex(camera?.mode == .driving ? 1 : 0)
        
        alertSliderView.delegate = self
        alertSliderView.icon.image = #imageLiteral(resourceName: "icon_setting Albert_n")
        uploadSliderView.delegate = self
        uploadSliderView.icon.image = #imageLiteral(resourceName: "icon_setting upload_n")

        tableView.register(UINib(nibName: expandableCellId, bundle: nil), forCellReuseIdentifier: expandableCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        updateLocalSettings()
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
    }

    override func applyTheme() {
        super.applyTheme()

        modeSegControl.backgroundColor = UIColor.semanticColor(.background(.secondary))
        modeSegControl.indicatorColor = UIColor.semanticColor(.tint(.primary))
        modeSegControl.shadowColor = UIColor.semanticColor(.separator(.opaque))
        modeSegControl.titleColor = UIColor.semanticColor(.label(.secondary))
        modeSegControl.selectedTitleColor = UIColor.semanticColor(.tint(.primary))
        modeSegControl.titleFont = UIFont(name: "BeVietnamPro-Bold", size: 14)!
        modeSegControl.selectedTitleFont = UIFont(name: "BeVietnamPro-Bold", size: 14)!
    }
    
    func updateLocalSettings() {
        if self.camera?.viaWiFi ?? false {
            camera?.local?.settingsDelegate = self
            camera?.local?.getMountAccelLevels()
            if camera?.local?.isSupportRadarSensitivity ?? false {
                camera?.local?.getRadarSensitivity()
            }
            camera?.local?.getMountAccelParam(HNAccLevel.custom.rawValue)
            camera?.local?.getIIOEventDetectionParam()
        }
    }
    
    func generateSliderOptions() {
        alertOptions = [
            Option(
                name: NSLocalizedString("Off", comment: "Off"),
                color: UIColor.semanticColor(.background(.secondary)),
                title: NSLocalizedString("Alert: Off", comment: "Alert: Off"),
                detail: NSLocalizedString("No alerts will be sent.", comment: "No alerts will be sent.")
            ),
            Option(
                name: NSLocalizedString("Impact", comment: "Impact"),
                color: UIColor.semanticColor(.activity(.heavy)),
                title: NSLocalizedString("Alert: Only Impact", comment: "Alert: Only Impact"),
                detail: NSLocalizedString("You'll be notified when an impact is detected.", comment: "You'll be notified when an impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Bump", comment: "Bump"),
                color: UIColor.semanticColor(.activity(.hit)),
                title: NSLocalizedString("Alert: Bump and More", comment: "Alert: Bump and More"),
                detail: NSLocalizedString("You'll be notified when any bump or impact is detected.", comment: "You'll be notified when any bump or impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Motion", comment: "Motion"),
                color: UIColor.semanticColor(.activity(.motion)),
                title: NSLocalizedString("Alert: Motion and More", comment: "Alert: Motion and More"),
                detail: NSLocalizedString("You'll be notified when any activity is detected.", comment: "You'll be notified when any activity is detected.")
            )
        ]
        
        let attributed = NSMutableAttributedString(string: NSLocalizedString("Event video will be uploaded to the cloud when any activity is detected.", comment: "Event video will be uploaded to the cloud when any activity is detected."))
        attributed.append(NSAttributedString(string: NSLocalizedString(" May increase data usage rapidly.", comment: " May increase data usage rapidly."), attributes: [.foregroundColor : UIColor.semanticColor(.label(.tertiary))]))
        uploadOptions = [
            Option(
                name: NSLocalizedString("Off", comment: "Off"),
                color: UIColor.semanticColor(.background(.secondary)),
                title: NSLocalizedString("Upload: Off", comment: "Upload: Off"),
                detail: NSLocalizedString("No videos will be uploaded to the cloud.", comment: "No videos will be uploaded to the cloud.")
            ),
            Option(
                name: NSLocalizedString("Impact", comment: "Impact"),
                color: UIColor.semanticColor(.activity(.heavy)),
                title: NSLocalizedString("Upload: Only Impact", comment: "Upload: Only Impact"),
                detail: NSLocalizedString("Event video will be uploaded to the cloud when an impact is detected.", comment: "Event video will be uploaded to the cloud when an impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Bump", comment: "Bump"),
                color: UIColor.semanticColor(.activity(.hit)),
                title: NSLocalizedString("Upload: Bump and More", comment: "Upload: Bump and More"),
                detail: NSLocalizedString("Event video will be uploaded to the cloud when any bump or impact is detected.", comment: "Event video will be uploaded to the cloud when any bump or impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Motion", comment: "Motion"),
                color: UIColor.semanticColor(.activity(.motion)),
                title: NSLocalizedString("Upload: Motion and More", comment: "Upload: Motion and More"),
                attributedDetail: attributed
            )
        ]
        
        detectOptions = [
            Option(
                name: NSLocalizedString("Off", comment: "Off"),
                color: UIColor.semanticColor(.background(.secondary)),
                title: NSLocalizedString("Detection: Off", comment: "Detection: Off"),
                detail: NSLocalizedString("No events will be recorded.", comment: "No events will be recorded.")
            ),
            Option(
                name: NSLocalizedString("Impact", comment: "Impact"),
                color: UIColor.semanticColor(.activity(.heavy)),
                title: NSLocalizedString("Detection: Only Impact", comment: "Detection: Only Impact"),
                detail: NSLocalizedString("Video is recorded when an impact is detected.", comment: "Video is recorded when an impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Bump", comment: "Bump"),
                color: UIColor.semanticColor(.activity(.hit)),
                title: NSLocalizedString("Detection: Bump and More", comment: "Detection: Bump and More"),
                detail: NSLocalizedString("Video is recorded when any bump or impact is detected.", comment: "Video is recorded when any bump or impact is detected.")
            ),
            Option(
                name: NSLocalizedString("Motion", comment: "Motion"),
                color: UIColor.semanticColor(.activity(.motion)),
                title: NSLocalizedString("Detection: Motion and More", comment: "Detection: Motion and More"),
                detail: NSLocalizedString("Video is recorded when any activity is detected.", comment: "Video is recorded when any activity is detected.")
            )
        ]
    }
    
    func refreshUI() {
        guard let camera = camera else {
            return
        }
        modeSegControl.activeIndex = camera.mode == .driving ? 1 : 0
        refreshModeConfig()
        uploadSliderView.isHidden = !(camera.supports4g)
        let rows: Int
        if camera.viaWiFi {
            rows = (shouldShowMotionSensitivity ? 2 : 1)
        } else {
            rows = 0
        }
        expandableModels.removeAll()
        for _ in 0..<rows {
            expandableModels.append(ExpandableCellModel())
        }
        tableView.reloadData()
    }
    
    func refreshModeConfig() {
        guard let camera = camera else { return }
        let config = modeSegControl.index == 0 ? camera.parkingConfig : camera.drivingConfig
        if camera.supports4g {
            if modeSegControl.index == 0 {
                alertSliderView.options = detectOptions
                uploadSliderView.options = uploadOptions
            } else {
                alertSliderView.options = Array(detectOptions[0...2])
                uploadSliderView.options = Array(uploadOptions[0...2])
            }
            alertSliderView.setIndex(config?.detection.rawValue ?? 0, animated: true)
            uploadSliderView.setIndex(config?.upload.rawValue ?? 0, animated: true)
        } else {
            if modeSegControl.index == 0 {
                alertSliderView.options = detectOptions
            } else {
                alertSliderView.options = Array(detectOptions[0...2])
            }
            alertSliderView.setIndex(config?.detection.rawValue ?? 0, animated: true)
        }
    }
    
    func refreshImactSlider() {
        let count = impactSensitivityLevels.count
        impactSensitivitySlider?.isEnabled = count > 0
        impactSensitivitySlider?.showMarks(true, levels: UInt(count))
        impactSensitivitySlider?.minimumValue = 0
        impactSensitivitySlider?.maximumValue = max(0, Float(count - 1))
        if let level = impactSensitivityLevel, let value = impactSensitivityLevels.firstIndex(of: level) {
            impactSensitivitySlider?.value = Float(value)
        }
    }
    
    @IBAction func onModeChanged(_ sender: HNSegmentedControl) {
        refreshModeConfig()
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            if camera?.viaWiFi ?? false {
                return shouldShowMotionSensitivity ? 2 : 1
            } else {
                return 0
            }
        case 2:
            return shouldShowNotification ? 1 : 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.01
        default:
            return 12
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                return camera?.supports4g ?? false ? 314 : 154
            }
        case 1:
            if indexPath.row < expandableModels.count {
                return expandableModels[indexPath.row].height
            } else {
                return 160
            }
        default:
            break
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case 1:
            if indexPath.row < expandableModels.count {
                cell = tableView.dequeueReusableCell(withIdentifier: expandableCellId, for: indexPath)
                guard let expandableCell = cell as? ExpandableSliderCell else { break }
                let model = expandableModels[indexPath.row]
                // if should animate, set initial state first, else set completed state
                expandableCell.setExpanded(model.isExpanded != model.shouldAnimated, animated: false)
                if indexPath.row == 0 && shouldShowMotionSensitivity {
                    expandableCell.titleLabel.text = NSLocalizedString("Motion Sensitivity", comment: "Motion Sensitivity")
                    expandableCell.detailLabel.text = NSLocalizedString("sensitivity_settings_motion_description", comment: "Adjust Motion Sensitivity settings if you want less or more Motion events to be detected.")
                    expandableCell.slider.showMarks(false, levels: 0)
                    motionSensitivitySlider = expandableCell.slider
                    motionSensitivitySlider?.minimumValue = 0
                    motionSensitivitySlider?.maximumValue = 10
                    motionSensitivitySlider?.value = motionSensitivity
                    motionSensitivitySlider?.addTarget(self, action: #selector(onSliderChanged(_:)), for: .applicationReserved)
                } else {
                    expandableCell.titleLabel.text = NSLocalizedString("Impact Sensitivity", comment: "Impact Sensitivity")
                    expandableCell.detailLabel.text = NSLocalizedString("sensitivity_settings_impact_description", comment: "Adjust Impact Sensitivity settings if you want less or more Bump or Impact events to be detected.")
                    impactSensitivitySlider = expandableCell.slider
                    impactSensitivitySlider?.addTarget(self, action: #selector(onSliderChanged(_:)), for: .applicationReserved)
                    refreshImactSlider()
                }
                model.collapseHeight = expandableCell.height(forWidth: tableView.bounds.width, expanded: false)
                model.expandedHeight = expandableCell.height(forWidth: tableView.bounds.width, expanded: true)
            } else if  indexPath.row == expandableModels.count {
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
            } else {
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 1))
            }
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        if let settingCell = cell as? CameraSettingCell {
            settingCell.isEnabled = camera?.viaWiFi ?? false
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let expandableCell = cell as? ExpandableSliderCell {
            let model = expandableModels[indexPath.row]
            expandableCell.setExpanded(model.isExpanded, animated: model.shouldAnimated)
            model.shouldAnimated = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row < expandableModels.count {
                let model = expandableModels[indexPath.row]
                model.isExpanded = !model.isExpanded
                model.shouldAnimated = true
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CameraRelated {
            var dest = vc
            dest.camera = camera
        }
    }
    
    // MARK: - Actions
    @objc func onSliderChanged(_ sender: UISlider) {
        Log.info("slider.value \(sender.value)")
        let value = Int(sender.value)
        guard value >= 0 else { return }
        if sender == motionSensitivitySlider {
            camera?.local?.setRadarSensitivity(Int32(value))
        } else if sender == impactSensitivitySlider, value < impactSensitivityLevels.count {
            camera?.local?.setMountAccelLevel(impactSensitivityLevels[value])
        }
        var prop = Dictionary<String, Any>()
        prop["section"] = sender == motionSensitivitySlider ? "motion" : "impact"
        prop["value"] = value
        MixpanelHelper.track(event: "Control-Sensor Sensitivity", properties: prop, camera: camera)
    }
    
    @IBAction func onCustomImpactSwitch(_ sender: UISwitch) {
        if sender.isOn {
            camera?.local?.setMountAccelLevel(HNAccLevel.custom.rawValue)
        }
    }
}

extension HNCSSensitivityViewController: HNSegmentedSliderViewDelegate {
    // MARK: - SegmentedSliderView Delegate
    func segmentedSliderDidChange(_ sliderView: HNSegmentedSliderView, index: Int, finished: Bool) {
        Log.info("select \(index), \(sliderView.titleLabel.text!)")
        guard let sensitivity = HNEventSensitivity(rawValue: index), let camera = camera else { return }
        if sliderView == alertSliderView {
            if camera.supports4g {
                if index < uploadSliderView.index {
                    uploadSliderView.setIndex(index)
                }
            }
        } else {
            if index > alertSliderView.index {
                alertSliderView.setIndex(index)
            }
        }
        if !finished {
            return
        }
        var config = modeSegControl.index == 0 ? camera.parkingConfig : camera.drivingConfig
        if config == nil { return }
        var prop = Dictionary<String, Any>()
        prop["index"] = index
        if sliderView == alertSliderView { // detection
            if camera.supports4g {
                if let uploadSensitivity = HNEventSensitivity(rawValue: uploadSliderView.index) {
                    config?.upload = uploadSensitivity
                    config?.alert = uploadSensitivity
                }
            }
            config?.detection = sensitivity
            prop["section"] = "detection"
        } else { // upload
            if let detectionSensitivity = HNEventSensitivity(rawValue: alertSliderView.index) {
                config?.detection = detectionSensitivity
            }
            config?.upload = sensitivity
            config?.alert = sensitivity
            prop["section"] = "upload"
        }
        if modeSegControl.index == 0 {
            camera.parkingConfig = config
        } else {
            camera.drivingConfig = config
        }
        prop["mode"] = modeSegControl.index == 0 ? "parking" : "driving"
        MixpanelHelper.track(event: "Control-Event Sensitivity", properties: prop, camera: camera)
    }
}

extension HNCSSensitivityViewController: WLCameraSettingsDelegate {
    func onGetMountConfig(_ config: [AnyHashable : Any]?) {
        refreshUI()
    }
    
    func onGetMountAccelLevels(_ levels: [Any]?, current: String?) {
        impactSensitivityLevels.removeAll()
        if let levels = levels as? [String] {
            impactSensitivityLevels.append(contentsOf: levels.reversed())
        }
        impactSensitivityLevel = current
        refreshImactSlider()
    }
    
    func onSetMountAccelLevel(_ result: Bool) {
        camera?.local?.getMountAccelLevels()
    }
    
    func onSetMountAccelParam(_ result: Bool) {
        //
    }

    func onSetIIOEventDetectionParam(_ result: Bool) {
        //
    }
    
    func onGetRadarSensitivity(_ level: Float) {
        motionSensitivity = level
    }
    
    func onSetRadarSensitivity(_ level: Float) {
        motionSensitivity = level
    }
}
