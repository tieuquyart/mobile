//
//  HNCSSDCardViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class HNCSSDCardViewController: BaseTableViewController, CameraRelated {
    enum HNCSSDCardSection : Int {
        case recordingStatus = 0
        case storageStatus = 1
        case maxEventSize = 2
        case formatButton = 3
    }
    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var maxMarkSize : Int32?
    var arrayMarkSize : NSArray?
    
    var capacityObservation: NSKeyValueObservation?
    var storageStateObservation: NSKeyValueObservation?
    var timer : WLTimer?
    var formatAfterRecordingStopped: Bool = false

    static func createViewController() -> HNCSSDCardViewController {
        let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "HNCSSDCardViewController")
        return vc as! HNCSSDCardViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("SD Card", comment: "SD Card")
        
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        storageStateObservation = observe(\.camera?.local?.storageState, options: [.initial], changeHandler: { (this, change) in
            if let state = this.camera?.local?.storageState {
                Log.debug("Observed storage state change \(state)")
                this.tableView.reloadData()
                if state == .ready {
                    this.camera?.local?.getMarkStorageOptions()
                }
            }
        })
        capacityObservation = observe(\.camera?.local?.freeMB) { (this, change) in
            Log.debug("Observed freeMB change \(this.camera?.local?.freeMB ?? -1)")
            this.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.local?.settingsDelegate = self
        timer = WLTimer(reference: self, interval: 8, repeat: true, block: {
            self.camera?.local?.updateStorageSpaceInfo()
        })
        timer?.start()
        camera?.local?.getMarkStorageOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordStateChanged), name: Notification.Name.Local.recordState, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        formatAfterRecordingStopped = false
//        camera?.local?.settingsDelegate = nil
        HNMessage.dismiss()
        timer?.stop()
    }

    func isFormatAvailable() -> (Bool, String?) {
        guard let _ = camera?.local else {
            return (false, NSLocalizedString("Formatting is only available via direct Wi-Fi connection", comment: "Formatting is only available via direct Wi-Fi connection"))
        }
//        if local.monitoring {
//            return (false, "You need to stop monitoring first before formatting")
//        }
        return (true, nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        if HNCSSDCardSection(rawValue: section) == .formatButton {
//            let (_, footer) = isFormatAvailable()
//            return footer
//        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    private func sdcardMessage() -> String? {
        if let state = camera?.local?.storageState {
            switch state {
            case .error:
                return WLCopy.sdcardError
            case .noStorage:
                return WLCopy.sdcardNotDetected
            case .ready:
                if camera?.local?.shouldFormat == true {
                    return WLCopy.sdcardFormatRecommended
                }
                return WLCopy.sdcardReady
            default:
                return nil
            }
        } else {
            return WLCopy.sdcardStateUnknown
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
        switch HNCSSDCardSection(rawValue: indexPath.section)! {
        case .recordingStatus:
            cell.textLabel?.text = sdcardMessage()
        case .storageStatus:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = displayedBytes(camera?.sdcardUsageTotal)
            case 1:
                cell.detailTextLabel?.text = displayedBytes(camera?.sdcardUsageFree)
            case 2:
                cell.detailTextLabel?.text = displayedBytes(camera?.sdcardUsageMarked)
            case 3:
                cell.detailTextLabel?.text = displayedBytes(camera?.sdcardUsageBuffered)
            case 4:
                var other: Int64?
                if let total = camera?.sdcardUsageTotal, let free = camera?.sdcardUsageFree, let marked = camera?.sdcardUsageMarked, let buffered = camera?.sdcardUsageBuffered {
                    other = total - free - marked - buffered
                }
                cell.detailTextLabel?.text = displayedBytes(other)
            default:
                break
            }
        case .maxEventSize:
            cell.accessoryType = .none
            if let maxMarkSize = maxMarkSize {
                cell.detailTextLabel?.text = "\(maxMarkSize)GB"
                if camera?.featureAvailability.isMarkSpaceSettingsAvailable == true {
                    cell.accessoryType = .disclosureIndicator
                }
            } else if let total = camera?.sdcardUsageTotal {
                cell.detailTextLabel?.text = displayedBytes(total / 2)
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Unknown", comment: "Unknown")
            }
        case .formatButton:
            let (enable, _) = isFormatAvailable()
            cell.textLabel?.textColor = enable ? UIColor.semanticColor(.label(.tertiary)) : UIColor.semanticColor(.label(.primary))
            cell.selectionStyle = enable ? .default : .none
        }
    }
    
    func prepareFormat() {
        guard let local = camera?.local else { return }
        if local.monitoring {
            formatAfterRecordingStopped = true
            HNMessage.show(message: NSLocalizedString("Stop recording...", comment: "Stop recording..."))
            local.stopRecord()
        } else {
            doFormat()
        }
    }
    
    func doFormat() {
        guard let local = camera?.local else { return }
        local.formatTFCard()
        HNMessage.show(message: NSLocalizedString("Format...", comment: "Format..."))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.usingDynamicTextColor = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if HNCSSDCardSection(rawValue: indexPath.section) == .formatButton && indexPath.row == 0 {
            let (enable, _) = isFormatAvailable()
            if !enable { return }
            let alert = UIAlertController(
                title: NSLocalizedString("Format SD Card", comment: "Format SD Card"),
                message: NSLocalizedString("all_data_will_be_erased_from_sd_card", comment: "All data will be erased from SD card.\nAre you sure?"),
                preferredStyle: .actionSheetOrAlertOnPad
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (_) in
                self?.prepareFormat()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        if HNCSSDCardSection(rawValue: indexPath.section) == .maxEventSize && indexPath.row == 0 {
            if camera?.featureAvailability.isMarkSpaceSettingsAvailable == true,
                camera?.sdcardUsageTotal != nil {
                self.performSegue(withIdentifier: "markSpace", sender: self)
            }
        }
    }
    
    func displayedBytes(_ bytes: Int64?) -> String {
        if let bytes = bytes {
            return String.fromBytes(bytes, countStyle: .decimal)
        }
        return NSLocalizedString("Unknown", comment: "Unknown")
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CameraRelated {
            var dest = vc
            dest.camera = camera
        }
    }
    
    @objc func onRecordStateChanged(_ notification: Notification) {
        if let local = notification.object as? WLCameraDevice, local == camera?.local, local.recState == .stopped && formatAfterRecordingStopped {
            formatAfterRecordingStopped = false
            doFormat()
        }
    }
}

extension HNCSSDCardViewController: WLCameraSettingsDelegate {
    func onFormatTFCard(_ success: Bool) {
        if success {
            camera?.local?.clipsAgent.refreshVdbState()
            HNMessage.showSuccess(message: NSLocalizedString("Format Succeeded", comment: "Format Succeeded"))
//            self.tableView.reloadData()
        } else {
            HNMessage.showError(message: NSLocalizedString("Format Failed", comment: "Format Failed"))
        }
    }
    func onGetMarkStorageOptions(_ levels: [Any]?, current currentInGB: Int32) {
        maxMarkSize = currentInGB
        arrayMarkSize = NSArray.init(array: levels ?? [])
        self.tableView.reloadData()
    }
}
