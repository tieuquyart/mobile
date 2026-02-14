//
//  SettingViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/15/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit


class SettingViewController: BaseTableViewController {
    let cameraItemCellId = "CameraItem"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Settings", comment: "Settings")
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "HNCameraItemCell", bundle: nil), forCellReuseIdentifier: cameraItemCellId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshUI() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2 + UnifiedCameraManager.shared.cameras.count
        case 1:
            return UserSetting.shared.debugEnabled ? 4 : 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row > 0  && indexPath.row <= UnifiedCameraManager.shared.cameras.count {
            return 90
        }

        #if FLEET
        if indexPath.section == 1 && indexPath.row == 2 { // Beta Firmware Tester
            return 0.0
        }
        #endif

        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Static", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("Cameras", comment: "Cameras")
                cell.selectionStyle = .none
                cell.accessoryType = .none

                return cell
            } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddNew", for: indexPath)
                return cell
            } else if indexPath.row > 0 {
                let camera = UnifiedCameraManager.shared.cameras[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: cameraItemCellId, for: indexPath) as! HNCameraItemCell
                cell.nameLabel.text = camera.name
                cell.avatar.image = camera.supports4g ? #imageLiteral(resourceName: "camera_4g") : #imageLiteral(resourceName: "camera_wifi")
                if camera.isOffline {
                    cell.detailLabel.text = NSLocalizedString("Offline", comment: "Offline")
                    cell.detailLabel.isHidden = false
                    cell.detailLabel.textColor = UIColor.semanticColor(.label(.primary))
                } else if camera.viaWiFi {
                    cell.detailLabel.text = NSLocalizedString("Wi-Fi connected", comment: "Wi-Fi connected")
                    cell.detailLabel.isHidden = false
                    cell.detailLabel.textColor = UIColor.semanticColor(.tint(.primary))
                } else {
                    cell.detailLabel.isHidden = true
                }
                
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case 1:
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("Beta Firmware Tester", comment: "Beta Firmware Tester")
                cell.detailTextLabel?.text = UserSetting.shared.beBetaFrimwareTester ? NSLocalizedString("Joined", comment: "Joined") : NSLocalizedString("Join now", comment: "Join now")

                cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Static", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = NSLocalizedString("About", comment: "About")
                case 1:
                    cell.textLabel?.text = NSLocalizedString("Clear Cache", comment: "Clear Cache")
                    cell.accessoryType = .none
                case 3:
                    cell.textLabel?.text = NSLocalizedString("Debug Options", comment: "Debug Options")
                default:
                    break
                }

                cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))

                return cell
            }
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "Static", for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        #if FLEET
        if indexPath.section == 0 || indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            (cell.viewWithTag(8) as? UILabel)?.text = NSLocalizedString("Setup Camera", comment: "Setup Camera")
        }
        #endif
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let lastRow = tableView.numberOfRows(inSection: 0) - 1
            if indexPath.row > 0 && indexPath.row < lastRow {
                // open camera settings
                let vc = HNCameraSettingViewController.createViewController()
                vc.camera = UnifiedCameraManager.shared.cameras[indexPath.row - 1]
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            switch indexPath.row {
            case 0:
                // about
                performSegue(withIdentifier: "About", sender: nil)
            case 1:
                // clean cache
                presentCleanCacheController()
            case 2:
                let vc = UIAlertController(title: "", message: "", preferredStyle: .actionSheetOrAlertOnPad)
                if UserSetting.shared.beBetaFrimwareTester {
                    vc.title = NSLocalizedString("Leave Beta Program?", comment: "Leave Beta Program?")
                    vc.message = NSLocalizedString("leave_beta_program_message", comment: "If you leave, you might want to reinstall the public firmware version.")
                    vc.addAction(UIAlertAction.init(title: NSLocalizedString("Leave", comment: "Leave"), style: .default, handler: { (action) in
                        UserSetting.shared.beBetaFrimwareTester = false
                        self.tableView.reloadData()
                    }))
                } else {
                    vc.title = NSLocalizedString("Join Beta Program?", comment: "Join Beta Program?")
                    vc.message = NSLocalizedString("join_beta_program_message", comment: "Because features are in development, beta firmwares may be unstable.\nPlease check firmware from \"Camera Settings\" -> \"Firmware\".")
                    vc.addAction(UIAlertAction.init(title: NSLocalizedString("Join", comment: "Join"), style: .default, handler: { (action) in
                        UserSetting.shared.beBetaFrimwareTester = true
                        self.tableView.reloadData()
                    }))
                }
                vc.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) in
                }))
                present(vc, animated: true)
            case 3:
                // debug options
                performSegue(withIdentifier: "DebugOptions", sender: nil)
            default:
                break
            }
        default:
            break
        }
    }
    
}
