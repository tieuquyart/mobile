//
//  HNMenuViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/6/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK
import WaylensFoundation

class ProfileViewController: BaseTableViewController {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dataUsageLabel: UILabel!

    #if FLEET
    private lazy var observerForCurrentConnectedCamera: ObserverForCurrentConnectedCamera = { [weak self] in
        $0.eventResponder = self
        return $0
    }(ObserverForCurrentConnectedCamera())
    #endif

    override func awakeFromNib() {
        super.awakeFromNib()
        
        title = NSLocalizedString("Profile", comment: "Profile")
        navigationController?.tabBarItem.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.layer.cornerRadius = avatar.frame.size.width * 0.5
        avatar.clipsToBounds = true

        #if FLEET
        observerForCurrentConnectedCamera.startObserving()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if FLEET
        if AccountControlManager.shared.isLogin {
            usernameLabel.text = AccountControlManager.shared.keyChainMgr.displayName
            if let avatarUrl = AccountControlManager.shared.keyChainMgr.avatarUrl, let url = URL(string: avatarUrl) {
                avatar.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "user_avatar_placeholder"))
            } else {
                avatar.image = #imageLiteral(resourceName: "Driver")
            }
        } else {
            usernameLabel.text = NSLocalizedString("Log in", comment: "Log in")
            avatar.image = #imageLiteral(resourceName: "user_avatar_placeholder")
        }
        #else
        if AccountControlManager.shared.isAuthed {
            usernameLabel.text = AccountControlManager.shared.keyChainMgr.displayName
            if let avatarUrl = AccountControlManager.shared.keyChainMgr.avatarUrl, let url = URL(string: avatarUrl) {
                avatar.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "user_avatar_placeholder"))
            } else {
                avatar.image = #imageLiteral(resourceName: "user_avatar_placeholder")
            }
        } else {
            usernameLabel.text = NSLocalizedString("Log in", comment: "Log in")
            avatar.image = #imageLiteral(resourceName: "user_avatar_placeholder")
        }
        #endif

        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        } else {
            return 20.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if FLEET
        switch (indexPath.section, indexPath.row) {
        case (1, 0): // Start Tour
            return 0.0
        case (1, 4): // OBD Work Mode
            if
                AccountControlManager.shared.isLogin,
                WLBonjourCameraListManager.shared.currentCamera?.obdWorkModeConfig != nil
            {
                break
            }
            else {
                return 0.0
            }
        case (1, 5): // Calib the Driving Facing Camera
            if WLBonjourCameraListManager.shared.currentCamera?.hasDmsCamera == true {
                break
            }
            else {
                return 0.0
            }
        case (3, 2): // Debug Options
            if !UserSetting.shared.debugEnabled {
                return 0.0
            }
        default:
            break
        }
        #else
        switch (indexPath.section, indexPath.row) {
        case (1, 1): // Data Usage
            return 0.0
        case (3, 0): // Continue tour
            if GuideHelper.isGuideFlowFinished {
                return 0.0
            }
        case (4, 0): // Videos Shared by Users
            if !UserSetting.shared.debugEnabled {
                return 0.0
            }
            if (!AccountControlManager.shared.isAuthed || !AccountControlManager.shared.keyChainMgr.email.hasSuffix("waylens.com")) {
                return 0.0
            }
        default:
            break
        }
        #endif
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        #if FLEET
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            (cell.viewWithTag(8) as? UILabel)?.text = NSLocalizedString("Setup Camera", comment: "Setup Camera")
        case (1, 4): // OBD Work Mode
            if let obdWorkMode = WLBonjourCameraListManager.shared.currentCamera?.obdWorkModeConfig?.mode {
                (cell.viewWithTag(8) as? UILabel)?.text = NSLocalizedString(obdWorkMode.name, comment: "")
            }
        default:
            break
        }
        #endif
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #if FLEET
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if AccountControlManager.shared.isLogin {
                let userInterface = MyFleetUserProfileRootView()
                let vc = MyFleetUserProfileViewController(userProfile: UserSetting.current.userProfile!, userInterface: userInterface)
              //  let vc = MyFleetUserProfileViewController(userProfile: UserSetting.current.userProfile!, userInterface: userInterface)
                userInterface.ixResponder = vc
                navigationController?.pushViewController(vc, animated: true)
            } else {
                AppViewControllerManager.gotoLogin()
            }
        case (1, 1): // Network
            let vc = CameraTypeSelectionDependencyContainer(scene: .network).makeCameraTypeSelectionViewController()
            navigationController?.pushViewController(vc, animated: true)
        case (1, 2): // Power Cord
            let success = showPowerCordTestIfPossible()
            if !success {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case (1, 3): // Vehicle Power Information
            let vc = PowerInfoDependencyContainer().makePowerInfoViewController()
            navigationController?.pushViewController(vc, animated: true)
        case (1, 4): // OBD Work Mode
            let vc = ObdWorkModeDependencyContainer().makeObdWorkModeViewController()
            navigationController?.pushViewController(vc, animated: true)
        case (1, 5): // Calib the Driving Facing Camera
            CalibrationGuide(presenter: CalibrationGuidePresenter()).start()
        case (2, 0): // Report an Issue
            let vc = FeedbackController.createViewController()
            navigationController?.pushViewController(vc, animated: true)
        case (3, 1): // Clean Cache
            presentCleanCacheController()
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
        #else
        switch (indexPath.section, indexPath.row) {
        case (2, 1): // Store
            openBrowser(withURLString: UserSetting.shared.webServer.shopUrl)
        case (3, 0): // Continue tour
            GuideHelper.continueGuide()
        default:
            break
        }
        #endif
    }
    
}

#if FLEET
extension ProfileViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        camera?.wl.observe(\.obdWorkModeConfig, options: [], changeHandler: { [weak self] (camera, change) in
            self?.tableView.reloadData()
        })

        camera?.wl.observe(\.hasDmsCamera, options: [], changeHandler: { [weak self] (camera, change) in
            self?.tableView.reloadData()
        })

        tableView.reloadData()
    }

}
#endif
