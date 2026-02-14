//
//  HNCameraSettingViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/11/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WaylensCameraSDK

class HNCameraSettingViewController: BaseTableViewController, CameraRelated {
    
    enum HNCameraSettingsItem {
        case server
        case blueTooth
        case sleep
        case ipAddress
        case apn
        case supportWlanMode
        case supportRiskDriveEvent
        case videoQuality
        case wiFiMode
        case debugProperty
        case iioEventDetectionParam
        case customImpactSensitivity
    }
    
    enum Sections: Int, CaseIterable {
        case debug
        
        var settings: [HNCameraSettingsItem?] {
            if UserSetting.shared.debugEnabled {
                return [
                    .server,
                    .blueTooth,
                    .sleep,
                    .ipAddress,
                    .apn,
                    .supportWlanMode,
                    .supportRiskDriveEvent,
                    .videoQuality,
                    .wiFiMode,
                    .debugProperty,
                    .iioEventDetectionParam,
                    .customImpactSensitivity,
                ]
            }
            else if UserSetting.shared.showCameraDebugSettings {
                return [
                    nil, // Server
                    .blueTooth,
                    nil, // Sleep
                    .ipAddress,
                    .apn,
                    nil, // Support Wlan Mode
                    .supportRiskDriveEvent,
                    .videoQuality,
                    nil, // WiFi Mode
                    .debugProperty,
                    nil, // IIO Event Detection Param
                    nil, // Custom Impact Sensitivity
                ]
            }
            else {
                return [
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                ]
            }
        }
    }
    
    @objc var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded && isVisible {
                refreshUI()
            }
        }
    }
#if FLEET
    private var cameraInCloud: CameraProfile? = nil
#endif
    
    @IBOutlet weak var monitorSwitch: UISwitch!
    //    @IBOutlet weak var advancedSwitch: UISwitch!
    @IBOutlet weak var recordingHeight: NSLayoutConstraint!
    //    @IBOutlet weak var nightVisionSwitch: UISwitch!
    @IBOutlet weak var logoLedSwitch: UISwitch!
    @IBOutlet weak var hdrSwitch: UISwitch!
    @IBOutlet weak var hdrModeLabel: UILabel!
    @IBOutlet weak var cameraServerLabel: UILabel!
    
    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var apnLabel: UILabel!
    @IBOutlet weak var wlanModeLabel: UILabel!
    @IBOutlet weak var riskDriveEventLabel: UILabel!
    @IBOutlet weak var parkSleepDelayLabel: UILabel!
    @IBOutlet weak var protectionVoltageLabel: UILabel!
    @IBOutlet weak var wifiModeLabel: UILabel!
    @IBOutlet weak var drivingDetectionLabel: UILabel!
    @IBOutlet weak var cameraViewLabel: UILabel!
    @IBOutlet weak var obdWorkModeLabel: UILabel!
    
    @IBOutlet weak var videoQualityLabel: UILabel!
    @IBOutlet weak var trialIndicator: UIButton!
    @IBOutlet weak var dataPlanUsageLabel: UILabel!
    @IBOutlet weak var dataServiceIndicator: UIButton!
    @IBOutlet weak var blueTooth: UILabel!
    
    @IBOutlet weak var customImpactInput: UITextField!
    @IBOutlet weak var customImpactSwitch: UISwitch!
    @IBOutlet weak var iioDetectionParamInput: UITextField!
    
    var mask: UIView?
    var disposeBag = DisposeBag()
    struct SettingOption: OptionSet {
        let rawValue: Int
        static let profile = SettingOption(rawValue: 1)
        static let control = SettingOption(rawValue: 2)
        static let settings = SettingOption(rawValue: 4)
        static let reset = SettingOption(rawValue: 8)
        static let debug = SettingOption(rawValue: 16)
        static let remove = SettingOption(rawValue: 32)
    }
    
    var settingSections: SettingOption = []
    
    var isVisible: Bool = false
    var shouldShowRecording: Bool {
        return camera?.viaWiFi ?? false
    }
    var shouldShowSubscription: Bool {
#if FLEET
        return false
#else
        return AccountControlManager.shared.isAuthed && (camera?.supports4g ?? false) && camera?.ownerUserId == AccountControlManager.shared.keyChainMgr.userID
#endif
    }
    
    static func createViewController() -> HNCameraSettingViewController {
        let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "HNCameraSettingViewController")
        return vc as! HNCameraSettingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trialIndicator.layer.borderWidth = 1
        trialIndicator.layer.borderColor = UIColor.semanticColor(.tint(.primary)).cgColor
        trialIndicator.layer.cornerRadius = trialIndicator.bounds.height / 2
        trialIndicator.layer.masksToBounds = true
        dataPlanUsageLabel.text = ""
        dataServiceIndicator.layer.cornerRadius = dataServiceIndicator.bounds.height / 2
        dataServiceIndicator.layer.masksToBounds = true
        
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        
        customImpactInput.delegate = self
        iioDetectionParamInput.delegate = self
        
        //NSLocalizedString("Camera Settings", comment: "Camera Settings")
        self.rx.observeWeakly(WLRecordState.self, #keyPath(camera.local.recState))
            .subscribe(onNext: { [weak self] recState in
                guard let this = self, let recState = recState else {
                    return
                }
                
                if recState == .stopped || recState == .recording {
                    this.monitorSwitch.isEnabled = true
                    this.monitorSwitch.setOn(this.camera?.monitoring ?? false, animated: true)
                }
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
#if FLEET
#endif
        
        camera?.local?.settingsDelegate = self
        updateLocalDebugSettingsIfNeeded()
        refreshUI()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsUpdated(sender:)), name: Notification.Name.Remote.settingsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsUpdateTimeOut(sender:)), name: Notification.Name.Remote.settingsUpdateTimeOut, object: nil)
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
        
        isVisible = false
        HNMessage.hideWhisper()
        
#if !FLEET
        if isMovingFromParent {
            camera?.remote?.commitSettings()
        }
#endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mask?.frame = CGRect(origin: .zero, size: tableView.contentSize)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRecordChanged(_ sender: UISwitch) {
        let wasOn = camera?.monitoring ?? false
        camera?.monitoring = monitorSwitch.isOn
        monitorSwitch.isEnabled = false
        
        DispatchQueue.main.async { [weak self] in
            self?.monitorSwitch.setOn(wasOn, animated: true)
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController.init(
            title: NSLocalizedString("Remove Camera", comment: "Remove Camera"),
            message: NSLocalizedString("remove_camera_message", comment: "Are you sure to remove this camera from your account?"),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove"), style: .destructive, handler: { [weak self] (_) in
            self?.camera?.unbind(completion: { (result) in
                if result.isSuccess {
                    HNMessage.showSuccess(message: NSLocalizedString("Camera Removed", comment: "Camera Removed"), to: self?.navigationController)
                    self?.navigationController?.popToRootViewController(animated: true)
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Failed", comment: "Failed"), to: self?.navigationController)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //    @IBAction func onSwitchAdvanced(_ sender: UISwitch) {
    //        UserSetting.shared.advancedSettings = sender.isOn
    //        refreshSettingSections()
    //        if sender.isOn {
    //            if let point = sender.superview?.superview?.frame.origin {
    ////            let point = tableView.convert(CGPoint.zero, from: sender.superview)
    //                tableView.setContentOffset(CGPoint(x: 0, y: point.y), animated: true)
    //            }
    //        }
    //    }
    
    //    @IBAction func onSwitchNightVision(_ sender: UISwitch) {
    //        camera?.nightVision = sender.isOn ? .on : .off
    //    }
    
    
    @IBAction func onSwitchLogoLed(_ sender: UISwitch) {
        camera?.logoLed = sender.isOn ? .on : .off
    }
    
    
    @IBAction func onSwitchHDR(_ sender: UISwitch) {
        camera?.local?.setHDRMode(sender.isOn ? .on : .off)
    }
    
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let option = SettingOption(rawValue: 1 << section)
        //        if option == .settings {
        //            return 0.01
        //        }
        if option == .debug && settingSections.contains(.debug) {
            return 30
        }
        
#if FLEET
        if option == .control || option == .reset {
            return 0.01
        }
#endif
        
        return settingSections.contains(option) ? tableView.sectionHeaderHeight : 0.01
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 4 && settingSections.contains(.debug) {
            return NSLocalizedString("Debug", comment: "Debug")
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard camera != nil else { return 0 }
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return settingSections.contains(.profile) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
        } else if section == 1 {
            return settingSections.contains(.control) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
        } else if section == 2 {
            return settingSections.contains(.settings) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
        } else if section == 3 {
            return settingSections.contains(.reset) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
        }
//        else if section == 4 {
//            return settingSections.contains(.debug) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
//        }
        else if section == 5 {
#if FLEET
            return 0
#else
            return settingSections.contains(.remove) ? super.tableView(tableView, numberOfRowsInSection: section) : 0
#endif
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            switch row {
            case  1 : return 0
            default:
                break
            }
        } else if  section == 3 || section == 1 {
            return 0
        }
        else if section == 4 {
            if Sections.debug.settings[indexPath.row] == nil {

                return 0
            }
        }
        

        else if section == 2 {
            switch row {
               case 0, 1, 2 , 3 , 4 , 5 , 8 , 9 ,10 , 11  , 14, 15 , 16 , 17 , 18 , 19 : return 0
            default:
                break
            }

        }
        
        
        
        //        #if FLEET
        //        if section == 1 || section == 3 {
        //            return 0
        //        } else {
        //            switch section {
        //            case 0:
        //                switch row {
        //                case 1: //1: 4G Plan
        //                    if !shouldShowSubscription {
        //                        return 0
        //                    }
        //                default:
        //                    break
        //                }
        //            case 2:
        //                switch row {
        //                case 6: // SD Card
        //
        //                    break
        //                case 8: // Camera View
        //                    if camera?.featureAvailability.isMultiInstallationModesAvailable == false {
        //                        return 0
        //                    }
        //                case 13: // Calib the Driving Facing Camera
        //                    if camera?.local == nil || !camera!.local!.hasDmsCamera {
        //                        return 0
        //                    }
        //                case 14: // Power Cord
        //                    if UserSetting.current.userProfile?.roles.contains(.fleetManager) == true {
        //                        break
        //                    }
        //                    else {
        //                        return 0
        //                    }
        //                case 15: // Network
        //                    if camera!.local!.productSerie == .secureES {
        //                        return 0
        //                    }
        //                    else {
        //                        if UserSetting.current.userProfile?.roles.contains(.fleetManager) == true {
        //                            break
        //                        }
        //                        else {
        //                            return 0
        //                        }
        //                    }
        //                case 16: // Camera Tour
        //                    if UserSetting.current.userProfile?.roles.contains(.fleetManager) == true {
        //                        break
        //                    }
        //                    else {
        //                        return 0
        //                    }
        //                case 17: // Vehicle Power Information
        //                    break
        //                case 18: // OBD Work Mode
        //                    if WLBonjourCameraListManager.shared.currentCamera?.obdWorkModeConfig != nil {
        //                        break
        //                    }
        //                    else {
        //                        return 0.0
        //                    }
        //                case 19: // ADAS Settings
        //                    if WLBonjourCameraListManager.shared.currentCamera?.adasConfig != nil {
        //                        break
        //                    }
        //                    else {
        //                        return 0.0
        //                    }
        //                default:
        //                    return 0
        //                }
        //            case 4:
        //                if Sections.debug.settings[indexPath.row] == nil {
        //                    return 0
        //                }
        //            default:
        //                break
        //            }
        //        }
        //        #else
        //        switch section {
        //        case 0:
        //            switch row {
        //            case 1: //1: 4G Plan
        //                if !shouldShowSubscription {
        //                    return 0
        //                }
        //            default:
        //                break
        //            }
        //        case 2:
        //            switch row {
        //            case 4: // HDR switch
        //                if camera?.featureAvailability.isAutoHDRAvailable == true {
        //                    return 0
        //                }
        //            case 5: // Auto HDR
        //                if camera?.featureAvailability.isAutoHDRAvailable == false {
        //                    return 0
        //                }
        //            case 7: // Driving Detection Method
        //                if camera?.featureAvailability.isUntrustACCWireSupportAvailable == false {
        //                    return 0
        //                }
        //            case 8: // Camera View
        //                if camera?.featureAvailability.isMultiInstallationModesAvailable == false {
        //                    return 0
        //                }
        //            case 9: // Driving Mode Timeout
        //                if camera?.featureAvailability.isDrivingModeTimeoutSettingsAvailable == false {
        //                    return 0
        //                }
        //            case 10: // Battery Protection
        //                if camera?.featureAvailability.isProtectionVoltageAvailable == false {
        //                    return 0
        //                }
        //            case 11: // Vin Mirror
        //                if camera?.featureAvailability.isVinMirrorAvailable == false {
        //                    return 0
        //                }
        //            case 12: // Record Config
        //                if camera?.featureAvailability.isRecordConfigAvailable == false {
        //                    return 0
        //                }
        //            case 13: // Calib the Driving Facing Camera
        //                return 0
        //            case 14: // Power Cord
        //                return 0
        //            case 15: // Network
        //                return 0
        //            case 16: // Camera Tour
        //                return 0
        //            case 17: // Vehicle Power Information
        //                return 0
        //            case 18: // OBD Work Mode
        //                return 0
        //            case 19: // ADAS Settings
        //                return 0
        //            default:
        //                break
        //            }
        //        case 4:
        //            if Sections.debug.settings[indexPath.row] == nil {
        //                return 0
        //            }
        //        default:
        //            break
        //        }
        //        #endif
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let settingCell = cell as? CameraSettingCell {
            settingCell.isEnabled = camera?.viaWiFi ?? false
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("devthanh indexPath.section \(indexPath.section), indexPath.row \(indexPath.row)")
        switch (indexPath.section, indexPath.row) {
        case (2, 5):
            let allModes = WLCameraHDRMode.allModes()
            showPicker(withValues: allModes.map{NSLocalizedString($0.toString(), comment: "")}) { [unowned self](index) in
                self.camera?.local?.setHDRMode(allModes[index])
            }
        case (2, 9): // Driving Mode Timeout
            let values = [30, 60, 120, 300, 600];
            showPicker(
                withValues: values.map{TimeInterval($0).toHourMinSecString()},
                message: NSLocalizedString("Your Secure360 will remain in Driving mode when connected by WIFI to your mobile App.", comment: "Your Secure360 will remain in Driving mode when connected by WIFI to your mobile App.")) { [unowned self](index) in
                    self.camera?.local?.doSetParkSleepDelay(Int32(values[index]))
                    self.camera?.local?.doGetParkSleepDelay()
                }
        case (2, 11): // Vin Mirror
            if let camera = camera { navigationController?.pushViewController(VinMirrorDependencyContainer(camera: camera).makeVinMirrorViewController(), animated: true)
            }
        case (2, 12): // Record Config
            if let camera = camera { navigationController?.pushViewController(RecordConfigDependencyContainer(camera: camera).makeRecordConfigViewController(), animated: true)
            }
#if FLEET
        case (2, 13): // Calib the Driving Facing Camera
            if camera?.featureAvailability.isDmsCameraCalibrationAvailable == true {
                CalibrationGuide(presenter: CalibrationGuidePresenter()).start()
            }
            else {
                alert(message: NSLocalizedString("firmware_out_of_date", comment: "Firmware out of date.\nPlease update your camera's firmware."))
            }
        case (2, 14): // Power Cord
            performFleetCameraAction {
                _ = showPowerCordTestIfPossible()
            }
        case (2, 15): // Network
            performFleetCameraAction {
                let vc = NetworkDiagnosisViewController.createViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
        case (2, 16): // Camera Tour
            performFleetCameraAction {
                let guide = SetupGuide(scene: .cameraTour, presenter: CameraTourSetupGuidePresenter())
                guide.camera = cameraInCloud
                guide.start()
            }
        case (2, 17): // Vehicle Power Information
            let vc = PowerInfoDependencyContainer().makePowerInfoViewController()
            navigationController?.pushViewController(vc, animated: true)
        case (2, 18): // OBD Work Mode
            performFleetCameraAction {
                let vc = ObdWorkModeDependencyContainer().makeObdWorkModeViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
        case (2, 19): // ADAS Settings
            let vc = AdasConfigDependencyContainer().makeAdasConfigViewController()
            navigationController?.pushViewController(vc, animated: true)
#endif
        case (3, 0):
            let alert = UIAlertController.init(
                title: NSLocalizedString("Factory Reset", comment: "Factory Reset"),
                message: NSLocalizedString("factory_reset_message", comment: "Your camera's settings will be reset to factory default(recorded videos will not be affected)"),
                preferredStyle:  .actionSheet
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { [weak self] (_) in
                self?.camera?.local?.factoryReset()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case (4, 0):
            let servers = AppConfig.CameraServer.allCases.filter({ (s) -> Bool in
                return s.rawValue != camera?.local?.serverAddress
            })
            
            let alert = UIAlertController(
                title: NSLocalizedString("Switch Camera Server", comment: "Switch Camera Server"),
                message: NSLocalizedString("switch to new server and reboot", comment: "switch to new server and reboot"),
                preferredStyle: .actionSheet
            )
            
            for server in servers {
                let displayName = server.displayName
                
                alert.addAction(UIAlertAction(title: displayName, style: .default, handler: { [weak self] (_) in
                    self?.camera?.local?.setCameraServer(address: server.rawValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        self?.camera?.local?.reboot()
                        self?.refreshUI()
                    }
                }))
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            //        case (4, 1):
            //            let alert = UIAlertController.init(
            //                title: NSLocalizedString("Rotate", comment: "Rotate"),
            //                message: NSLocalizedString("Are you sure to rotate the camera?", comment: ""),
            //                preferredStyle: .actionSheetOrAlertOnPad
            //            )
            //            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { [weak self] (_) in
            //                self?.camera?.local?.setAttitude(!(self?.camera?.local?.isUpsideDown)!)
            //            }))
            //            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            //            present(alert, animated: true, completion: nil)
        case (4, 2):
            let alert = UIAlertController.init(
                title: NSLocalizedString("Sleep", comment: "Sleep"),
                message: NSLocalizedString("Your camera will go to sleep", comment: "Your camera will go to sleep"),
                preferredStyle:  .actionSheet
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { [weak self] (_) in
                self?.camera?.local?.reboot()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case (4, 4): // APN
            showApnSetting(masked: false)
        case (4, 6): // Support Risky Event Detection
            let values = [true, false];
            showPicker(withValues: values.map{$0.yesNoString()}) { [unowned self](index) in
                self.camera?.local?.setSupportRiskDriveEvent(values[index])
                self.camera?.local?.getSupportRiskDriveEvent()
            }
        default:
            break
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let settingCell = sender as? CameraSettingCell {
            return settingCell.isEnabled
        } else if identifier == "dataPlan" {
            guard let iccid = camera?.remote?.iccid, let subscription = camera?.remote?.subscription else {
                // subscription data not fetched yet
                return false
            }
            if iccid.isEmpty {
                showAlert(title: WLCopy.simCardNotReported, message: nil)
                return false
            }
            if subscription.state == .none {
                UIApplication.shared.open(URL(string: "\(UserSetting.shared.webServer.rawValue)/my/device/\(camera!.sn)/4g_subscription/plans")!, options: [:], completionHandler: nil)
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CameraRelated {
            var dest = vc
            dest.camera = camera
        }
    }
    
    
    
    // MARK: - Notifications
    @objc func onSettingsUpdated(sender: Notification) {
        if let sn = sender.object as? String, sn == camera?.sn {
            HNMessage.showWhisper(
                type: .success,
                message: NSLocalizedString("Camera settings applied.", comment: "Camera settings applied."),
                in: self
            )
            refreshSettingsStatus()
        }
    }
    
    @objc func onSettingsUpdateTimeOut(sender: Notification) {
        if let sn = sender.object as? String, sn == camera?.sn {
            refreshUI()
        }
    }
    
    @IBAction func onCustomImpactSwitch(_ sender: UISwitch) {
        if sender.isOn {
            camera?.local?.setMountAccelLevel(HNAccLevel.custom.rawValue)
        }
    }
}

private extension HNCameraSettingViewController {
    
    func refreshUI() {
        guard let camera = camera else {
            refreshSettingSections()
            return
        }
        title = "Cấu hình"
        monitorSwitch.setOn(camera.monitoring, animated: isVisible)
        monitorSwitch.isEnabled = true
        
        if let subscription = camera.remote?.subscription {
            dataServiceIndicator.setTitle(subscription.state.displayName, for: .normal)
            dataPlanUsageLabel.isHidden = true
            trialIndicator.isHidden = !subscription.isTrial
            if subscription.state == DataSubscription.State.inService || subscription.state == .paid {
                dataPlanUsageLabel.text = subscription.usageDescription()
                dataServiceIndicator.isHidden = true
                dataPlanUsageLabel.isHidden = false
            } else if subscription.state == DataSubscription.State.suspended {
                dataServiceIndicator.setBackgroundImageColor(UIColor.semanticColor(.fill(.senary)))
                dataServiceIndicator.isHidden = false
            } else if subscription.state == DataSubscription.State.expired {
                dataServiceIndicator.setBackgroundImageColor(UIColor.semanticColor(.fill(.quaternary)))
                dataServiceIndicator.isHidden = false
            } else if subscription.state == DataSubscription.State.none {
                dataServiceIndicator.setBackgroundImageColor(UIColor.semanticColor(.fill(.quinary)))
                dataServiceIndicator.isHidden = false
            }
        } else {
            trialIndicator.isHidden = true
            dataPlanUsageLabel.isHidden = true
            dataServiceIndicator.isHidden = true
        }
        
        logoLedSwitch.setOn(camera.logoLed == .on, animated: isVisible)
        if camera.featureAvailability.isAutoHDRAvailable == true {
            hdrModeLabel.text = NSLocalizedString(camera.local?.hdrMode.toString() ?? "", comment: "")
        } else {
            hdrSwitch.setOn(camera.local?.hdrMode == .on ? true : false, animated: isVisible)
        }
        
#if FLEET
        if FirmwareUtils.updateRequired(for: camera) {
            firmwareLabel.text = NSLocalizedString("New update available", comment: "New update available")
            firmwareLabel.textColor = UIColor.semanticColor(.label(.tertiary))
        } else {
            firmwareLabel.text = NSLocalizedString("Up to date", comment: "Up to date")
            firmwareLabel.textColor = UIColor.semanticColor(.label(.primary))
        }
        
        if let obdWorkModeConfig = camera.local?.obdWorkModeConfig {
            obdWorkModeLabel.text = NSLocalizedString(obdWorkModeConfig.mode.name, comment: "")
        }
#else
        if let model = camera.model, let firmware = camera.firmware,
           WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: model)?.needUpgrade(firmware) ?? false {
            firmwareLabel.text = NSLocalizedString("New update available", comment: "New update available")
            firmwareLabel.textColor = UIColor.semanticColor(.label(.tertiary))
        } else {
            firmwareLabel.text = NSLocalizedString("Up to date", comment: "Up to date")
            firmwareLabel.textColor = UIColor.semanticColor(.label(.primary))
        }
#endif
        
        // debug
        
        if let str = camera.local?.serverAddress, let server = AppConfig.CameraServer(rawValue: str) {
            cameraServerLabel.text = server.displayName
        } else {
            cameraServerLabel.text = camera.local?.serverAddress
        }
        
        if let str = camera.local?.getIP() {
            ipLabel.text = str
        }
        videoQualityLabel.text      = camera.local?.videoQualityName
        apnLabel.text               = camera.local?.apn
        blueTooth.text              = camera.local?.isBluetoothOpen ?? false ? "Open" : "Disabled"
        wlanModeLabel.text          = camera.local?.isSupportWlanMode.yesNoString()
        riskDriveEventLabel.text    = camera.local?.isSupportRiskDriveEvent.yesNoString()
        wifiModeLabel.text          = camera.local?.wifiMode.name
        parkSleepDelayLabel.text    = TimeInterval(camera.local?.parkSleepDelay ?? 0).toHourMinSecString()
        protectionVoltageLabel.text = BatteryProtectionChoice(voltage: camera.local?.protectionVoltage)?.name
        drivingDetectionLabel.text  = DrivingDetectionMethod(trusted: camera.local?.isMountACCTrusted ?? false).name
        cameraViewLabel.text        = CameraInstallationMode(isUpsideDown: camera.local?.isUpsideDown ?? false).name
        
        refreshSettingSections()
        refreshSettingsStatus()
    }
    
    func refreshSettingsStatus() {
        var shouldMask = false
        if let settingStatus = camera?.remote?.pendingSettings.status {
            if settingStatus == .updating {
                shouldMask = true
                HNMessage.showWhisper(
                    type: .loading,
                    message: NSLocalizedString("Applying camera settings...", comment: "Applying camera settings..."),
                    in: self
                )
            } else if settingStatus == .failed {
                HNMessage.showWhisper(
                    type: .error,
                    message: NSLocalizedString("Failed to apply camera settings.", comment: "Failed to apply camera settings."),
                    in: self
                )
            }
        }
        if shouldMask {
            if mask == nil {
                mask = UIView()
                mask?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                view.addSubview(mask!)
            }
            mask?.isHidden = false
        } else {
            mask?.isHidden = true
        }
    }
    
    func refreshSettingSections() {
        settingSections = []
        guard let camera = camera else {
            tableView.reloadData()
            return
        }
        settingSections.update(with: .profile)
        if shouldShowRecording {
            settingSections.update(with: .control)
        }
        if !camera.isOffline {
            settingSections.update(with: .settings)
        }
        if camera.viaWiFi {
            settingSections.update(with: .reset)
        }
        if camera.viaWiFi {
            if  UserSetting.shared.debugEnabled || UserSetting.shared.showCameraDebugSettings {
                settingSections.update(with: .debug)
            }
        }
        if camera.remote != nil {
            settingSections.update(with: .remove)
        }
        tableView.reloadData()
    }
    
    func updateLocalDebugSettingsIfNeeded() {
        if camera?.viaWiFi == true && (UserSetting.shared.debugEnabled || UserSetting.shared.showCameraDebugSettings) {
            camera?.local?.getMountAccelLevels()
            camera?.local?.getMountAccelParam(HNAccLevel.custom.rawValue)
            camera?.local?.getIIOEventDetectionParam()
        }
    }
    
#if FLEET
    func performFleetCameraAction(_ action: () -> ()) {
        if cameraInCloud != nil {
            action()
        }
        else {
            alert(title: nil, message: NSLocalizedString("The camera has not been added to the fleet, please add it or change a camera.", comment: "The camera has not been added to the fleet, please add it or change a camera.")) { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            } action2: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .default) { [weak self] (_) in
                    guard let self = self else {
                        return
                    }
                    
                    let vc = AddNewCameraDependencyContainer().makeAddNewCameraViewController().embedInNavigationController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        }
    }
#endif
    
}

extension HNCameraSettingViewController: WLCameraSettingsDelegate {
    
    func onGet(_ mode: WLCameraHDRMode) {
        if isVisible {
            refreshUI()
        }
    }
    
    func onGetAttitude(_ isUpsideDown: Bool) {
        //        if isVisible {
        refreshUI()
        //        }
    }
    
    func onGetAPN(_ apn: String?) {
        if isVisible {
            refreshUI()
        }
    }
    
    func onGetSupportUpsideDown(_ isSupported: Bool) {
        if isVisible {
            refreshUI()
        }
    }
    
    func onGetParkSleepDelay(_ delaySeconds: Int32) {
        if isVisible {
            refreshUI()
        }
    }
    
    func onGetProtectionVoltage(_ voltage: Int32) {
        //        if isVisible {
        refreshUI()
        //        }
    }
    
    func onGetMountACCTrust(_ trusted: Bool) {
        refreshUI()
    }
    
    func onGetMountAccelParam(_ param: String?) {
        customImpactInput.text = param
    }
    
    func onGetIIOEventDetectionParam(_ param: String?) {
        iioDetectionParamInput.text = param
    }
    
    func onGetMountAccelLevels(_ levels: [Any]?, current: String?) {
        customImpactSwitch.isOn = (current == HNAccLevel.custom.rawValue)
    }
    
}

extension HNCameraSettingViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil && textField.text != "" {
            if textField == customImpactInput {
                camera?.local?.setMountAccelForLevel(HNAccLevel.custom.rawValue, param: textField.text!)
            }
            if textField == iioDetectionParamInput {
                camera?.local?.setIIOEventDetectionParam(textField.text!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
