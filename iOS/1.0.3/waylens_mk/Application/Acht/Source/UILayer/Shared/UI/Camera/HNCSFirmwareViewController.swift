//
//  HNCSFirmwareViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/16/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class HNCSFirmwareViewController: BaseViewController, CameraRelated{
    enum State {
        case unknown
        case infoNotFetched
        case upToDate
        // need update
        case notDownloaded
        case downloading
        case downloaded
        case sending
        case sent
        case downloadFailed
        case sentFailed
    }

    var isExternal : Bool = false
    var externalUrl : String?
    var isLoaded : Bool = false

    @IBOutlet weak var updatedVersionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var currentversionLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var releaseNoteLabel: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var updatingView: UIStackView!
    @IBOutlet weak var updatedView: UIView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var progressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var progressViewHeight: NSLayoutConstraint!
    var state: State = .unknown {
        didSet {
            if state != oldValue && isViewLoaded {
                refreshUI()
            }
        }
    }
    var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    var firmwareInfo: WLFirmwareInfo?
    var downloadProgress: Double = 0 {
        didSet {
            progressBarWidth.constant = (progressBar.superview?.bounds.width ?? 0) * CGFloat(downloadProgress)
            progressBar.setNeedsLayout()
        }
    }

    #if FLEET
    lazy var firmwareUpdater = FirmwareUpdater()
    #endif
    
    static func createViewController() -> HNCSFirmwareViewController {
        let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "HNCSFirmwareViewController")
        return vc as! HNCSFirmwareViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        upgradeButton.setBackgroundImageColor(UIColor.semanticColor(.tint(.primary)), disabledColor: UIColor.semanticColor(.background(.quaternary)))
        view.backgroundColor = UIColor.white //semanticColor(.background(.secondary))
        updatingView.isHidden = true
        updatedView.isHidden = true
        scrollview.isHidden = true
        
        //setFont
        let font = UIFont(name: "BeVietnamPro-Regular", size: 12)!
        updatedVersionLabel.font = font
        infoLabel.font = font
        currentversionLabel.font = font
        versionLabel.font = font
        releaseNoteLabel.font = font
        tipLabel.font = font
        upgradeButton.titleLabel?.font = font
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WLFirmwareUpgradeManager.shared().add(self)

        if !isExternal {
            initHeader(text: NSLocalizedString("Firmware", comment: "Firmware"), leftButton: true)
        } else {
            initHeader(text: NSLocalizedString("External Firmware", comment: "External Firmware"), leftButton: true)
        }
        
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WLFirmwareUpgradeManager.shared().remove(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoaded && !isExternal {
            let string = UIPasteboard.general.string
            if (string?.lowercased().hasPrefix("http") == true &&
                string?.lowercased().contains(".tsf") == true) { //https://d3dxhfn6er5hd4.cloudfront.net/software/firmware/SC_V0D_1.13.01_2.63.45.107.366_1554481235291.tsf
                if (WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: "external")?.downloadUrl() == string &&
                    WLFirmwareUpgradeManager.shared().isExternalFirmwareValid()) {
                    //
                } else {
                    self.alert(title: NSLocalizedString("Download firmware from this link?",
                                                        comment: "Download firmware from this link?"), message: string ?? "", cancelHandler: {}, okHandler: {
                        self.openExternal2(string!)
                        WLFirmwareUpgradeManager.shared().downloadExternalFirmware(fromUrl: string!)
                    })
                }
            }
            isLoaded = true
        }

        if (!isExternal) {
            if WLFirmwareUpgradeManager.shared().isExternalFirmwareValid() {
                let externalButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "navbar_more _n"), style: .plain, target: self, action: #selector(self.openExternal))
                self.navigationItem.rightBarButtonItem = externalButton
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        } else {
            let removeButton = UIBarButtonItem.init(title: "Remove", style: .plain, target: self, action: #selector(self.removeExternal))
            self.navigationItem.rightBarButtonItem = removeButton
        }
    }

    @objc func openExternal() {
        openExternal2(nil)
    }
    @objc func openExternal2(_ url : String?) {
        let vc = HNCSFirmwareViewController.createViewController()
        vc.isExternal = true
        vc.camera = camera
        vc.externalUrl = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func removeExternal() {
        WLFirmwareUpgradeManager.shared().removeExternalFirmware()
        self.navigationController?.popViewController(animated: true)
    }

    func checkState() -> State {
        #if FLEET
        guard let camera = camera, let driverName = camera.model, FirmwareUtils.updateRequired(for: camera) else {
            return .upToDate
        }

        if firmwareInfo == nil {
            firmwareInfo = WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: driverName, bspVersion: camera.remote?.firmwareToUpgradeInfo?.firmware)
        }

        guard let firmwareInfo = firmwareInfo else {
            firmwareUpdater.fetchFirmwareInfo(for: camera) { [weak self] (fwInfo) in
                self?.firmwareInfo = fwInfo
            }
            return .infoNotFetched
        }

        UserSetting.shared.recentFirmwareUpdateRemindDate = Date()
        switch firmwareInfo.getStatus() {
        case .idle:
            return .notDownloaded
        case .downloading:
            return .downloading
        case .downloaded:
            if let cam = camera.local, WLFirmwareUpgradeManager.shared().isUpgradingCamera(cam) == true {
                return .sending
            } else {
                return .downloaded
            }
        case .failed, .notFound:
            return .downloadFailed
        default:
            return .upToDate
        }

        #else
        guard let model = camera?.model, let current = camera?.firmware else {
            return .upToDate
        }

        if isExternal {
            firmwareInfo = WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: "external")
        } else {
            firmwareInfo = WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: model)
        }
        guard let firmwareInfo = firmwareInfo else {
            return .infoNotFetched
        }
        if !isExternal {
            if !(firmwareInfo.needUpgrade(current)) {
                if (firmwareInfo.getLatestFirmwareVersion() == current) {
                    return .upToDate
                } else {
                    Log.info("No need to upgrade, but version is different: " + firmwareInfo.getLatestFirmwareVersion() + " vs " + current)
                }
            }
        }
        UserSetting.shared.recentFirmwareUpdateRemindDate = Date()
        switch firmwareInfo.getStatus() {
        case .idle:
            return .notDownloaded
        case .downloading:
            return .downloading
        case .downloaded:
            if let cam = camera?.local, WLFirmwareUpgradeManager.shared().isUpgradingCamera(cam) == true {
                return .sending
            } else {
                return .downloaded
            }
        case .failed, .notFound:
            return .downloadFailed
        default:
            return .upToDate
        }
        #endif
    }
    
    private func showProgress(show: Bool, animated: Bool) {
        if show {
            progressBar.backgroundColor = UIColor.semanticColor(.tint(.primary))
            progressViewHeight.constant = 4
            progressViewLeadingSpace.constant = 25
        } else {
            progressBar.backgroundColor = .clear
            progressViewHeight.constant = 1
            progressViewLeadingSpace.constant = 20
        }
        view.setNeedsLayout()
    }
    
    func refreshUI(animated:Bool=false) {
        if state == .unknown {
            state = checkState()
        }
        updatingView.isHidden = true
        updatedView.isHidden = true
        scrollview.isHidden = true
        if state == .infoNotFetched {
            WLFirmwareUpgradeManager.shared().checkFromServer()
            updatingView.isHidden = false
            return
        } else if state == .upToDate {
            updatedVersionLabel.text = NSLocalizedString("Version", comment: "Version") + " " + (camera?.firmwareShort ?? "") + " (\((camera?.firmware ?? "")))"
            updatedView.isHidden = false
            return
        }
        scrollview.isHidden = false
        guard let firmwareInfo = firmwareInfo else {
            return
        }
        tipLabel.text = nil
        let bytes = firmwareInfo.getFirmwareSize()
        let size = String.fromBytes(Int64(bytes), countStyle: .file)
        currentversionLabel.text = NSLocalizedString("Current", comment: "current firmware version") + ": " + (camera?.firmwareShort ?? "") + " (\((camera?.firmware ?? "")))"
        if isExternal {
            versionLabel.text = ""
            releaseNoteLabel.text = firmwareInfo.downloadUrl()
        } else {
            versionLabel.text = NSLocalizedString("Latest: ", comment: "latest firmware version") + (firmwareInfo.getLatestAPIVersion() ?? "") + " (\((firmwareInfo.getLatestFirmwareVersion() ?? "")))"
            releaseNoteLabel.text = firmwareInfo.getLocalizedUpgradeDescription()
        }
        switch state {
        case .notDownloaded:
            infoLabel.text = size
            showProgress(show: false, animated: animated)
            if camera?.viaWiFi ?? false {
                upgradeButton.setTitle(NSLocalizedString("Update", comment: "Update"), for: .normal)
            } else {
                upgradeButton.setTitle(NSLocalizedString("Download", comment: "Download"), for: .normal)
            }
            upgradeButton.isEnabled = true
        case .downloading:
            infoLabel.text = NSLocalizedString("Downloading", comment: "Downloading")
            downloadProgress = 0
            showProgress(show: true, animated: animated)
            upgradeButton.setTitle(NSLocalizedString("Downloading", comment: "Downloading"), for: .disabled)
            upgradeButton.isEnabled = false
        case .downloaded:
            infoLabel.text = NSLocalizedString("Downloaded", comment: "Downloaded")
            showProgress(show: false, animated: animated)
            let (ready, message) = isReadyToUpdate()
            upgradeButton.setTitle(NSLocalizedString("Update", comment: "Update"), for: .normal)
            upgradeButton.setTitle(NSLocalizedString("Update", comment: "Update"), for: .disabled)
            upgradeButton.isEnabled = ready
            tipLabel.text = message
        case .sending:
            infoLabel.text = NSLocalizedString("Updating", comment: "Updating")
            downloadProgress = 0
            showProgress(show: true, animated: animated)
            upgradeButton.setTitle(NSLocalizedString("Updating", comment: "Updating"), for: .disabled)
            upgradeButton.isEnabled = false
            tipLabel.text = NSLocalizedString("Keep camera's power on while updating", comment: "Keep camera's power on while updating")
        case .sent:
            infoLabel.text = NSLocalizedString("Rebooting", comment: "Rebooting")
            showProgress(show: false, animated: animated)
            upgradeButton.setTitle(NSLocalizedString("Updating", comment: "Updating"), for: .disabled)
            upgradeButton.isEnabled = false
            tipLabel.text = NSLocalizedString("Camera may reboot several times during the update process. Standy by.", comment: "Camera may reboot several times during the update process. Standy by.")
        case .downloadFailed:
            infoLabel.text = NSLocalizedString("Failed", comment: "Failed")
            upgradeButton.setTitle(NSLocalizedString("Download failed", comment: "Download failed"), for: .normal)
            upgradeButton.isEnabled = true
        case .sentFailed:
            infoLabel.text = NSLocalizedString("Failed", comment: "Failed")
            upgradeButton.setTitle(NSLocalizedString("Update failed", comment: "Update failed"), for: .normal)
            upgradeButton.isEnabled = true
        default:
            break
        }
    }
    
    @IBAction func onUpgrade(_ sender: Any) {
        guard let firmwareInfo = firmwareInfo else { return }
        let status = firmwareInfo.getStatus()
        if status == .downloading {
            return
        } else if status == .downloaded {
            let (ready, message) = isReadyToUpdate()
            if let cam = camera?.local, ready {
                WLFirmwareUpgradeManager.shared().addCamera(cam)
                WLFirmwareUpgradeManager.shared().doUpgrade(forCamera: cam)
                state = .sending
            } else {
                HNMessage.showError(message: message)
                tipLabel.text = message
            }
        } else {
            #if FLEET
            WLFirmwareUpgradeManager.shared().downloadFirmware(for: firmwareInfo)
            #else
            WLFirmwareUpgradeManager.shared().downloadFirmware(forHardware: firmwareInfo.getHardwareVersion())
            #endif
            state = .downloading
        }
    }
    
    func isReadyToUpdate() -> (Bool, String) {
        guard let firmwareInfo = firmwareInfo else {
            return (false, NSLocalizedString("Come back and retry later.", comment: "Come back and retry later."))
        }
        guard firmwareInfo.getStatus() == .downloaded else {
            return (false, NSLocalizedString("Firmware not downloaded yet.", comment: "Firmware not downloaded yet."))
        }
        guard let local = camera?.local else {
            return (false, NSLocalizedString("Connect your camera's Wi-Fi and update.", comment: "Connect your camera's Wi-Fi and update."))
        }
        if local.storageState == .noStorage {
            return (false, WLCopy.sdcardNotDetected)
        } else if local.storageState != .ready {
            return (false, WLCopy.sdcardError)
        } else if local.freeMB < 100 {
            return (false, NSLocalizedString("SD card is full, not enough free space for update.", comment: "SD card is full, not enough free space for update."))
        }
        return (true, NSLocalizedString("Keep camera's power on while updating", comment: "Keep camera's power on while updating"))
    }
}

extension HNCSFirmwareViewController: WLFirmwareUpgradeManagerDelegate {

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, firmwareCheckDone done: Bool) {
        let newState = checkState()
        if done && newState == .infoNotFetched {
            state = .upToDate
        } else {
            state = newState
        }
    }

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, firmwareDownloading process: Int32, downloaded size: Int, forHardware hw: String!) {
        if (hw == firmwareInfo?.getHardwareVersion() ||
            (isExternal && hw == "external")) {
            if process == 200 {
                let (ready, _) = isReadyToUpdate()
                if ready {
                    onUpgrade(self)
                } else {
                    state = .downloaded
                }
            } else {
                downloadProgress = Double(process) * 0.01
                infoLabel.text = "\(process)%"
                state = .downloading
            }
        }
    }

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, firmwareServerCannotAccessforHardware hw: String!) {
        state = .downloadFailed
        upgradeButton.setTitle(NSLocalizedString("Download failed", comment: "Download failed"), for: .normal)
    }

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, firmwareDownloadErrorForHardware hw: String!) {
        state = .downloadFailed
        upgradeButton.setTitle(NSLocalizedString("Download failed", comment: "Download failed"), for: .normal)
    }

    func firmwareUpgradeManagerTooManyTasks(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!) {
        state = .sentFailed
        upgradeButton.setTitle(NSLocalizedString("Update failed(too many tasks)", comment: "Update failed(too many tasks)"), for: .normal)
    }

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, sendFirmwareToCamera camera: WLCameraDevice!, process: Int32) {
        if camera.isEqual(self.camera?.local) {
            downloadProgress = Double(process)*0.01
        }
    }

    func firmwareUpgradeManager(_ firmwareUpgradeManager: WLFirmwareUpgradeManager!, sendFirmwareToCamera camera: WLCameraDevice!, finish finished: Bool) {
        Log.info("Firmware Sent \(finished ? "Successfully": "Failed")")
        state = finished ? .sent : .sentFailed
        WLFirmwareUpgradeManager.shared().removeCamera(camera)
        if finished {
            let alert = UIAlertController(
                title: NSLocalizedString("Camera Updating", comment: "Camera Updating"),
                message: NSLocalizedString("Camera may reboot several times during the update process. Standy by.", comment: "Camera may reboot several times during the update process. Standy by."),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler:{ (_)  in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }

}
