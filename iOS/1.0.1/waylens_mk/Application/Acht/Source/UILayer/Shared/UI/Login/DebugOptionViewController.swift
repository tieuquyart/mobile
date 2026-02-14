//
//  DebugOptionViewController.swift
//  Acht
//
//  Created by gliu on 9/22/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class DebugOptionViewController: BaseTableViewController {

    @IBOutlet weak var notificationTokenText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Debug Options"
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return AppConfig.Server.allCases.count;
        case 1:
            return WebServer.all.count;
        case 2:
            return 1;
        case 3:
            return 1;
        case 4:
            return 3;
        case 5:
            return 1;
        default:
            break;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selected = AppConfig.Server.allCases.firstIndex(of: UserSetting.shared.server) ?? 0
            cell.accessoryType = indexPath.row == selected ? .checkmark : .none
            cell.textLabel?.text = AppConfig.Server.allCases[indexPath.row].displayName
        } else if indexPath.section == 1 {
            let selected = WebServer.all.firstIndex(of: UserSetting.shared.webServer) ?? 0
            cell.accessoryType = indexPath.row == selected ? .checkmark : .none
            cell.textLabel?.text = WebServer.all[indexPath.row].displayName
        } else if indexPath.section == 2 {
            notificationTokenText.text = RemoteNotificationController.shared.remoteNotificationToken
        } else if indexPath.section == 4 {
            let languges = UserDefaults.standard.object(forKey: "AppleLanguages") as? Array<String>
            var isCurrentOption = false
            switch indexPath.row {
            case 0:
                if languges==nil || languges!.count != 1 {
                    isCurrentOption = true
                }
            case 1:
                if (languges != nil) && languges!.count == 1 && !languges![0].hasPrefix("zh-Hans") {
                    isCurrentOption = true
                }
            case 2:
                if (languges != nil) && languges!.count == 1 && languges![0].hasPrefix("zh-Hans") {
                    isCurrentOption = true
                }
            default: break
            }
            cell.accessoryType = isCurrentOption ? .checkmark : .none
        } else if indexPath.section == 5 {
            #if FLEET
            cell.textLabel?.text = "Access 2C Camera"
            cell.accessoryType = UserSetting.shared.access2CCamera ? .checkmark : .none
            #else
            cell.textLabel?.text = "Access 2B Camera"
            cell.accessoryType = UserSetting.shared.access2BCamera ? .checkmark : .none
            #endif
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let selected = AppConfig.Server.allCases.firstIndex(of: UserSetting.shared.server) ?? 0
            if indexPath.row != selected {
                let alert = UIAlertController.init(title: "Change Server", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "Change", style: .default, handler: { (action) in
                    if AccountControlManager.shared.isLogin {
                        WaylensClientS.shared.logout(completion: nil)
                    }
                    UserSetting.shared.server = AppConfig.Server.allCases[indexPath.row]
                    WLFirmwareUpgradeManager.shared().server = UserSetting.shared.server.rawValue
                    self.tableView.reloadData()

                    AppViewControllerManager.gotoLogin()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            break
        case 1:
            UserSetting.shared.webServer = WebServer.all[indexPath.row]
            tableView.reloadData()
        case 3:
            if indexPath.row == 0 {
                // will crash
                let a:Int? = nil
                print(a!)
            }
        case 4:
            if indexPath.row == 0 {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                self.tableView.reloadData()
            } else if indexPath.row == 1 {
                UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                self.tableView.reloadData()
            } else if indexPath.row == 2 {
                UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                self.tableView.reloadData()
            }
        case 5:
            if indexPath.row == 0 {
                #if FLEET
                UserSetting.shared.access2CCamera = !UserSetting.shared.access2CCamera
                #else
                UserSetting.shared.access2BCamera = !UserSetting.shared.access2BCamera
                #endif

                self.tableView.reloadData()
            }
        default:
            break
        }
    }
}
