//
//  HNCSNetworkViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/23/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class HNCSNetworkViewController: BaseTableViewController, CameraRelated {
    var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    var info = [(String, String?)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.register(UINib(nibName: HNInformationCell.cellID, bundle: nil), forCellReuseIdentifier: HNInformationCell.cellID)
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.sectionHeaderHeight = 12
        tableView.sectionFooterHeight = .leastNormalMagnitude
        tableView.separatorInset = .zero
        title = NSLocalizedString("Network", comment: "Network")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    func refreshUI() {
        if let status = camera?.local?.lteInfo as? [String: String] {
            refresh(status)
        } else if camera?.viaWiFi ?? false {
            camera?.local?.settingsDelegate = self
            camera?.local?.getLTEStatus()
        } else {
            info.removeAll()
            if let iccid = camera?.iccid {
                info.append((NSLocalizedString("ICCID", comment: "ICCID"), iccid))
            }
            if let signalInfo = camera?.cellSignalInfo {
                info.append((NSLocalizedString("Band", comment: "Band"), signalInfo.band))
                info.append((NSLocalizedString("Signal Strength", comment: "Signal Strength"), "\(Int(signalInfo.rsrp)) dBm"))
            }
            tableView.reloadData()
        }
    }
    
    func refresh(_ status: [String: String]) {
        info.removeAll()
        if status["sim"] == "READY", let iccid = camera?.local?.iccid, !iccid.isEmpty {
            info.append((NSLocalizedString("ICCID", comment: "ICCID"), iccid))
        } else {
            info.append((NSLocalizedString("ICCID", comment: "ICCID"), NSLocalizedString("No SIM card", comment: "No SIM card")))
        }
        if let ceregString = (status["cereg"])?.split(separator: ",").last, let cereg = Int(ceregString) {
            var s : String?
            switch cereg {
            case 0:
                s = NSLocalizedString("Idle", comment: "Idle")
            case 1:
                s = NSLocalizedString("Ready", comment: "Ready")
            case 2:
                s = NSLocalizedString("Searching", comment: "Searching")
            case 3:
                s = NSLocalizedString("Refused", comment: "Refused")
            case 4:
                s = NSLocalizedString("Unknown", comment: "Unknown")
            case 5:
                s = NSLocalizedString("Roaming", comment: "Roaming")
            default:
                break
            }
            info.append((NSLocalizedString("CEREG", comment: "CEREG"), s))
        }
        
        if let cellInfo = status["cellinfo"]?.split(separator: ",") {
            var band: Substring?
            if cellInfo.count > 3 {
                band = cellInfo[3]
            } else if cellInfo.count == 3 {
                band = cellInfo[2]
            }
            if let band = band {
                info.append((NSLocalizedString("Band", comment: "Band"), String(band)))
            }
        }
        
        if let signals = status["signal"]?.split(separator: ","),
            signals.count >= 3,
           let rsrp = Float(signals[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\"", with: "")) {
            info.append((NSLocalizedString("Signal Strength", comment: "Signal Strength"), "\(Int(rsrp)) dBm"))
        } else if let csq = status["csq"]?.split(separator: ","),
            csq.count >= 1,
            let rssi = Int(csq[0]) {
            let dbm = -113 + rssi * 2
            var s: String?
            if rssi == 0 {
                s = String(format: NSLocalizedString("%d dBm or less", comment: "%d dBm or less"), dbm)
            } else if rssi == 31 {
                s = String(format: NSLocalizedString("%d dBm or greater", comment: "%d dBm or greater"), dbm)
            } else {
                s = NSLocalizedString("No network", comment: "No network")
            }
            info.append((NSLocalizedString("Signal Strength", comment: "Signal Strength"), s))
        }
        if let ip = status["ip"]?.split(separator: ",").map( { $0.trimmingCharacters(in: .whitespaces) }),
            ip.count >= 2 {
            info.append((NSLocalizedString("IP Address", comment: "IP Address"), ip[1]))
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return info.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HNInformationCell.cellID, for: indexPath)
        let (title, value) = info[indexPath.row]
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value

        return cell
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == 4 {
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let (_, value) = info[indexPath.row]
            UIPasteboard.general.string = value
        }
    }

}

extension HNCSNetworkViewController: WLCameraSettingsDelegate {
    func onGetLTEStatus(_ status: [AnyHashable : Any]?) {
        if let status = status as? [String: String] {
            refresh(status)
        }
    }
}
