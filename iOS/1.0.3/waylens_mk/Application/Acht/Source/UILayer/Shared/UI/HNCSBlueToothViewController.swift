//
//  HNCSBlueToothViewController.swift
//  Acht
//
//  Created by gliu on 7/4/20.
//  Copyright © 2020 waylens. All rights reserved.
//
import UIKit
import WaylensCameraSDK

protocol MyBTEnableDelegate {
    func onBTenable(enable: Bool)
}
class MyBTEnable : UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EnableSwith: UISwitch!
    @IBOutlet weak var busy: UIActivityIndicatorView!

    var dele: MyBTEnableDelegate!

    @IBAction func onSwitchChanged(_ sender: Any) {
        if (dele != nil) {
            dele.onBTenable(enable: EnableSwith.isOn)
        }
    }
}

class MyBTCell : UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var MacLabel: UILabel!

}

class HNCSBlueToothViewController: BaseTableViewController, CameraRelated, MyBTEnableDelegate {

    func onBTenable(enable: Bool) {
        camera?.local?.doBluetoothOpen(enable)
        let cell : MyBTEnable = self.tableView.cellForRow(at: [0, 0]) as! MyBTEnable
        cell.busy.startAnimating()
    }

    let enableOBD = true


    private enum BTSection: Int {
        case enable = 0
        case HID    = 1
        case OBD    = 2
        case scan   = 3
        case foundHID = 4
        case foundOBD = 5
        case foundOther = 6
    }

    private var unbinding = false
    private var bindAfterUnbound = false
    private var toDoBindMac : String?
    private var toDoBindType : BTSection?

    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded && isBeingPresented {
                self.tableView.reloadData()
            }
        }
    }

//    init(camera: UnifiedCamera) {
//        self.camera = camera
//    }

//    func makeBlueToothViewController() -> HNCSBlueToothViewController {
//        return viewController = HNCSBlueToothViewController()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("BlueTooth", comment: "BlueTooth")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ((camera?.local) != nil) {
            camera?.local?.settingsDelegate = self
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if camera?.local?.isBluetoothOpen ?? false {
            return 7
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch BTSection(rawValue: section) {
        case .enable:
            return 1
        case .HID:
            return 1
        case .OBD:
            return enableOBD ? 1 : 0
        case .scan:
            return 1
        case .foundHID:
            return camera?.local?.hidHostList?.count ?? 0
        case .foundOBD:
            return enableOBD ? camera?.local?.obdHostList?.count ?? 0 : 0
        case .foundOther:
            return camera?.local?.otherBluetoothList?.count ?? 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch BTSection(rawValue: indexPath.section) {
        case .enable:
            let identifier = "MyBTEnable"
            let cell : MyBTEnable = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTEnable
            if camera?.local?.isSupportBluetooth ?? false == false {
                cell.EnableSwith.isOn = false
                cell.EnableSwith.isHidden = false
                cell.EnableSwith.isEnabled = false
                cell.NameLabel.text = NSLocalizedString("Supported", comment: "Supported")
                cell.busy.stopAnimating()
            } else {
                cell.NameLabel.text = NSLocalizedString("Enable", comment: "Enable")
                cell.EnableSwith.isHidden = false
                cell.EnableSwith.isOn = camera?.local?.isBluetoothOpen ?? false
                cell.EnableSwith.isEnabled = true
                cell.busy.stopAnimating()
                cell.dele = self
            }
            return cell
        case .HID:
            let identifier = "MyBTCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTCell
            switch camera?.local?.hidConnectState {
            case BTStatus_ON:
                cell.StatusLabel.text = NSLocalizedString("Connected", comment: "")
            case BTStatus_Wait:
                cell.StatusLabel.text = NSLocalizedString("Not Connected", comment: "")
            case BTStatus_Busy:
                cell.StatusLabel.text = NSLocalizedString("Connecting", comment: "")
            default:
                cell.StatusLabel.text = NSLocalizedString("Not Added", comment: "")
            }
            if camera?.local?.hidConnectState ?? BTStatus_OFF != BTStatus_OFF {
                cell.NameLabel.text = camera?.local?.hidBindDeviceName ?? ""
                cell.MacLabel.text = camera?.local?.hidBindDeviceMac ?? ""
            } else {
                cell.NameLabel.text = ""
                cell.MacLabel.text = ""
            }
            return cell
        case .OBD:
            let identifier = "MyBTCell"
            let cell : MyBTCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTCell
            switch camera?.local?.obdConnectState {
            case BTStatus_ON:
                cell.StatusLabel.text = NSLocalizedString("Connected", comment: "")
            case BTStatus_Wait:
                cell.StatusLabel.text = NSLocalizedString("Not Connected", comment: "")
            case BTStatus_Busy:
                cell.StatusLabel.text = NSLocalizedString("Connecting", comment: "")
            default:
                cell.StatusLabel.text = NSLocalizedString("Not Added", comment: "")
            }
            if camera?.local?.obdConnectState ?? BTStatus_OFF != BTStatus_OFF {
                cell.NameLabel.text = camera?.local?.obdBindDeviceName ?? ""
                cell.MacLabel.text = camera?.local?.obdBindDeviceMac ?? ""
            } else {
                cell.NameLabel.text = ""
                cell.MacLabel.text = ""
            }
            return cell
        case .scan:
            let identifier = "MyBTEnable"
            let cell : MyBTEnable = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTEnable
            cell.EnableSwith.isHidden = true
            cell.NameLabel.text = NSLocalizedString("Scan BlueTooth devices", comment: "")
            if camera?.local?.bluetoothScanState == 1 {
                cell.busy.startAnimating()
            } else {
                cell.busy.stopAnimating()
            }
            return cell
        case .foundHID:
            let identifier = "MyBTCell"
            let cell : MyBTCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTCell
            cell.NameLabel.text = ((camera?.local?.hidHostList![indexPath.row])! as! Dictionary<String, Any>)["BTNameKey"] as? String
            cell.MacLabel.text = ((camera?.local?.hidHostList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String
            cell.StatusLabel.text = ""
            return cell
        case .foundOBD:
            let identifier = "MyBTCell"
            let cell : MyBTCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTCell
            cell.NameLabel.text = ((camera?.local?.obdHostList![indexPath.row])! as! Dictionary<String, Any>)["BTNameKey"] as? String
            cell.MacLabel.text = ((camera?.local?.obdHostList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String
            cell.StatusLabel.text = ""
            return cell
        case .foundOther:
            let identifier = "MyBTCell"
            let cell : MyBTCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MyBTCell
            cell.NameLabel.text = ((camera?.local?.otherBluetoothList![indexPath.row])! as! Dictionary<String, Any>)["BTNameKey"] as? String
            cell.MacLabel.text = ((camera?.local?.otherBluetoothList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String
            cell.StatusLabel.text = ""
            return cell
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch BTSection(rawValue: section) {
        case .enable:
            return ""
        case .HID:
            return "Added Remote Control:"
        case .OBD:
            return enableOBD ? "Added OBD Dongle:" : ""
        case .scan:
            return ""
        case .foundHID:
            return camera?.local?.hidHostList?.count ?? 0 > 0 ? "Found Remote Control:" : ""
        case .foundOBD:
            return (enableOBD && camera?.local?.obdHostList?.count ?? 0 > 0) ? "Found OBD Dongle:" : ""
        case .foundOther:
            return camera?.local?.otherBluetoothList?.count ?? 0 > 0 ? "Found Other BlueTooth Devices:" : ""
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch BTSection(rawValue: section) {
        case .enable:
            return ""
        case .HID:
            return "Click to unbind Remote Control."
        case .OBD:
            return enableOBD ? "Click to unbind OBD Dongle." : ""
        case .scan:
            return ""
        case .foundHID:
            return camera?.local?.hidHostList?.count ?? 0 > 0 ? "Click to bind Remote Control." : ""
        case .foundOBD:
            return (enableOBD && camera?.local?.obdHostList?.count ?? 0 > 0) ? "Click to bind OBD Dongle." : ""
        case .foundOther:
            return camera?.local?.otherBluetoothList?.count ?? 0 > 0 ? "Other Bluetooth Devies can not be added." : ""
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch BTSection(rawValue: section) {
        case .enable, .HID:
            return 44
        case .scan:
            return 16
        case .OBD:
            return enableOBD ? 32 : 1
        case .foundHID:
            return camera?.local?.hidHostList?.count ?? 0 > 0 ? 32 : 1
        case .foundOBD:
            return (enableOBD && camera?.local?.obdHostList?.count ?? 0 > 0) ? 32 : 1
        case .foundOther:
            return camera?.local?.otherBluetoothList?.count ?? 0 > 0 ? 32 : 1
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch BTSection(rawValue: section) {
        case .enable, .scan:
            return 16
        case .HID:
            return 24
        case .OBD:
            return enableOBD ? 24 : 1
        case .foundHID:
            return camera?.local?.hidHostList?.count ?? 0 > 0 ? 24 : 1
        case .foundOBD:
            return (enableOBD && camera?.local?.obdHostList?.count ?? 0 > 0) ? 24 : 1
        case .foundOther:
            return camera?.local?.otherBluetoothList?.count ?? 0 > 0 ? 24 : 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch BTSection(rawValue: indexPath.section) {
        case .enable:
            return
        case .HID: do {
            if camera?.local?.hidBindDeviceMac != nil {
                let alert = UIAlertController.init(title: NSLocalizedString("Unbind Remote Control?", comment: ""),
                                                   message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Unbind", comment: ""), style: .destructive, handler: { (action) in
                    self.unbinding = true
                    self.camera?.local?.doHIDUnBind()
                }))
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
            return
        case .OBD: do {
            if camera?.local?.obdBindDeviceMac != nil {
                let alert = UIAlertController.init(title: NSLocalizedString("Unbind OBD Dongle?", comment: ""),
                                                   message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Unbind", comment: ""), style: .destructive, handler: { (action) in
                    self.unbinding = true
                    self.camera?.local?.doOBDUnBind()
                }))
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
            return
        case .scan:
            camera?.local?.doBluetoothScan()
            return
        case .foundHID:
            if !bindAfterUnbound && !unbinding {
                if camera?.local?.hidBindDeviceMac != nil {
                    let alert = UIAlertController.init(title: NSLocalizedString("Unbind Current Remote Control firstly", comment: ""),
                                                       message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Unbind", comment: ""), style: .destructive, handler: { (action) in
                        self.unbinding = true
                        self.bindAfterUnbound = true
                        self.toDoBindType = .HID
                        self.toDoBindMac = ((self.camera?.local?.hidHostList?[indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String
                        self.camera?.local?.doHIDUnBind()
                    }))
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.init(title: NSLocalizedString("Bind Remote Control?", comment: ""),
                                                       message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Bind", comment: ""), style: .destructive, handler: { (action) in
                        self.camera?.local?.doHIDBind(((self.camera?.local?.hidHostList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String)
                    }))
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            return
        case .foundOBD:
            if !bindAfterUnbound && !unbinding {
                if camera?.local?.obdBindDeviceMac != nil {
                    let alert = UIAlertController.init(title: NSLocalizedString("Unbind Current OBD Dongle firstly", comment: ""),
                                                       message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Unbind", comment: ""), style: .destructive, handler: { (action) in
                        self.unbinding = true
                        self.bindAfterUnbound = true
                        self.toDoBindType = .OBD
                        self.toDoBindMac = ((self.camera?.local?.obdHostList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String
                        self.camera?.local?.doOBDUnBind()
                    }))
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.init(title: NSLocalizedString("Bind OBD Dongle?", comment: ""),
                                                       message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Bind", comment: ""), style: .destructive, handler: { (action) in
                        self.camera?.local?.doOBDBind((((self.camera?.local?.obdHostList![indexPath.row])! as! Dictionary<String, Any>)["BTMacKey"] as? String)!)
                    }))
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            return
        case .foundOther:
            return
        default:
            return
        }
    }
}

extension HNCSBlueToothViewController: WLCameraSettingsDelegate {

    func ongetBTInfo(withSupported bSupported: Bool,
                     enabled bEnabled: Bool,
                     scanning isScanning: Bool,
                     obdStatus: WLBluetoothStatus,
                     obdName: String,
                     obdMac: String,
                     hidStatus: WLBluetoothStatus,
                     hidName: String,
                     hidMac: String,
                     hidBatLev: Int32) {
        if unbinding && bindAfterUnbound {
            if (toDoBindMac != nil) {
                if toDoBindType == .HID && camera?.local?.hidConnectState == BTStatus_OFF {
                    camera?.local?.doHIDBind(toDoBindMac!)
                    unbinding = false
                    bindAfterUnbound = false
                    toDoBindMac = nil
                    toDoBindType = nil
                }
                if toDoBindType == .OBD && camera?.local?.obdConnectState == BTStatus_OFF {
                    camera?.local?.doHIDBind(toDoBindMac!)
                    unbinding = false
                    bindAfterUnbound = false
                    toDoBindMac = nil
                    toDoBindType = nil
                }
            }
        } else {
            unbinding = false
            bindAfterUnbound = false
            toDoBindMac = nil
            toDoBindType = nil
        }
        self.tableView.reloadData()
    }

}
