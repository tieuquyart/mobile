//
//  AppViewControllerManager.swift
//  Acht
//
//  Created by forkon on 2019/6/5.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import WaylensCameraSDK

class AppViewControllerManager {
    static var tabBarController: TabBarController? {
        return appDelegate.window?.rootViewController as? TabBarController
    }
    
    static var homeViewController: UIViewController? {
        return (tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first
    }
    
    static var topViewController: UIViewController? {
        var topViewController: UIViewController? = appDelegate.window?.rootViewController
        
        var possibleTopViewController = topViewController
        while possibleTopViewController != nil {
            if let tabBarController = possibleTopViewController as? TabBarController {
                possibleTopViewController = tabBarController.selectedViewController
            } else {
                if let navController = possibleTopViewController as? UINavigationController {
                    possibleTopViewController = navController.visibleViewController
                } else {
                    if let splitViewController = topViewController as? UISplitViewController {
                        possibleTopViewController = splitViewController.viewControllers.last
                    } else {
                        possibleTopViewController = possibleTopViewController?.presentedViewController
                    }
                }
            }
            
            if possibleTopViewController != nil {
                topViewController = possibleTopViewController
            }
        }
        
        return topViewController
    }
    
    static var currentViewController: UIViewController? {
        return topViewController
    }
    
    static var currentNavigationController: UINavigationController? {
        return tabBarController?.selectedViewController as? UINavigationController
    }
    
#if FLEET
    
    static var overviewViewController: OverviewViewController? {
        guard let overviewTabIndex = tabBarController?.overviewTabIndex else {
            return nil
        }
        
        return tabBarController?.rootViewControllerOfTab(at: overviewTabIndex) as? OverviewViewController
    }
    
#else
    
    static var alertListViewController: AlertListViewController? {
        guard let alertListTabIndex = tabBarController?.alertListTabIndex else {
            return nil
        }
        
        return tabBarController?.rootViewControllerOfTab(at: alertListTabIndex) as? AlertListViewController
    }
    
#endif
    
    static var isInSignInContainerViewController: Bool {
        return UIApplication.shared.keyWindow?.rootViewController is SignInContainerViewController
    }
    
    static func createRootViewController() -> UIViewController {
#if FLEET
        if !AccountControlManager.shared.isLogin {
            let viewController = SignInContainerViewController.createViewController()
            return viewController
        } else {
            return AppViewControllerManager.createTabBarController()
        }
#else
        if AccountControlManager.shared.isAuthed {
            return AppViewControllerManager.createTabBarController()
        } else {
            return SignInContainerViewController.createViewController()
        }
#endif
    }
    
    static func createLoginEidViewController() -> LoginEidViewController {
        let vc = LoginEidViewController(nibName: "LoginEidViewController", bundle: nil) as LoginEidViewController
        return vc
    }
    
    static func createTabBarController() -> TabBarController {
        let tabBarController = TabBarController()
        
        var viewControllers: [UIViewController]? = nil
        
#if FLEET
        let overviewVC = UIStoryboard(name: "Overview", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
        overviewVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Overview", comment: "Overview"), image: UIImage(named: "map"), tag: 0)
        
       // let dashboardVC = DashboardViewController().embedInNavigationController()
        let dashboardVC  = DashboardMKViewcontroller(nibName: "DashboardMKViewcontroller", bundle: nil).embedInNavigationController()
        dashboardVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Dashboard", comment: "Dashboard"), image: UIImage(named: "fatrows"),tag: 1)
        
//        let profileVC = MyFleetDependencyContainer().makeMyFleetViewController().embedInNavigationController()
//        profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("My Fleet", comment: "My Fleet"), image: UIImage(named: "setting-2"), tag: 2)
////
        let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil).embedInNavigationController()
        deviceVC.tabBarItem = UITabBarItem(title: NSLocalizedString("My Fleet", comment: "My Fleet"), image: UIImage(named: "setting-2"), tag: 2)
        
       //viewControllers = [overviewVC, dashboardVC, profileVC]
        viewControllers = [overviewVC, dashboardVC,deviceVC]
        //        if
        //            AccountControlManager.shared.isLogin
        ////          UserSetting.current.userProfile?.roles.contains(.fleetManager) == true
        //        {
        //            let overviewVC = UIStoryboard(name: "Overview", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
        //            overviewVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Overview", comment: "Overview"), image: UIImage(named: "Camera_grey"), tag: 0)
        //
        //            let dashboardVC = DashboardViewController().embedInNavigationController()
        //            dashboardVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Dashboard", comment: "Dashboard"), image: UIImage(named: "main tab_dashboard_grey"), tag: 1)
        //
        //            let profileVC = MyFleetDependencyContainer().makeMyFleetViewController().embedInNavigationController()
        //            profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("My Fleet", comment: "My Fleet"), image: UIImage(named: "Profile_grey"), tag: 2)
        //
        //
        //
        //            viewControllers = [overviewVC, dashboardVC, profileVC]
        //        }
        //        /* else if AccountControlManager.shared.isLogin, UserSetting.current.userProfile?.roles.contains(.installer) == true { */
        //        else {
        //            let installationVC = InstallationDependencyContainer().makeInstallationViewController().embedInNavigationController()
        //            installationVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Installation", comment: "Installation"), image: UIImage(named: "Installation"), tag: 0)
        //
        //            let cameraTabManager = CameraTabManager()
        //            tabBarController.cameraTabManager = cameraTabManager
        //
        //            let cameraVC = cameraTabManager.cameraTabViewController!
        //            cameraVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Camera", comment: "Camera"), image: UIImage(named: "Camera_grey"), tag: 1)
        //
        //            let maintenanceVC = MaintenanceDependencyContainer().makeMaintenanceViewController().embedInNavigationController()
        //            maintenanceVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Maintenance", comment: "Maintenance"), image: UIImage(named: "Maintenance"), tag: 2)
        //
        //
        //
        //            viewControllers = [installationVC, cameraVC, maintenanceVC]
        //        }
        /*
         else { // driver or not login
         let cameraTabManager = CameraTabManager()
         tabBarController.cameraTabManager = cameraTabManager
         
         let cameraVC = cameraTabManager.cameraTabViewController!
         cameraVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Camera", comment: "Camera"), image: UIImage(named: "Camera_grey"), tag: 0)
         
         let albumVC = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
         albumVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Album", comment: ""), image: UIImage(named: "Album_grey"), tag: 1)
         
         let profileVC = UIStoryboard(name: "Profile-Fleet", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
         profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: "Profile"), image: UIImage(named: "Profile_grey"), tag: 2)
         
         viewControllers = [cameraVC, albumVC, profileVC]
         }
         */
#else
        let cameraTabManager = CameraTabManager()
        tabBarController.cameraTabManager = cameraTabManager
        
        let cameraVC = cameraTabManager.cameraTabViewController!
        cameraVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Camera", comment: "Camera"), image: UIImage(named: "Camera_grey"), tag: 0)
        
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
        alertVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Events", comment: "Events"), image: UIImage(named: "navbar_notice _n"), tag: 1)
        
        let albumVC = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
        albumVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Album", comment: "Album"), image: UIImage(named: "Album_grey"), tag: 2)
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
        profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: "Profile"), image: UIImage(named: "Profile_grey"), tag: 3)
        
        viewControllers = [cameraVC, alertVC, albumVC, profileVC]
#endif
        
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
    
    
    static func createTabBarControllerCamera() -> TabBarController {
        let tabBarController = TabBarController()
        var viewControllers: [UIViewController]? = nil
        let installationVC = InstallationDependencyContainer().makeInstallationViewController().embedInNavigationController()
        installationVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Installation", comment: "Installation"), image: UIImage(named: "Installation"), tag: 0)
        
        let cameraTabManager = CameraTabManager()
        tabBarController.cameraTabManager = cameraTabManager
        
        let cameraVC = cameraTabManager.cameraTabViewController!
        cameraVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Camera", comment: "Camera"), image: UIImage(named: "Camera_grey"), tag: 1)
        
        let maintenanceVC = MaintenanceDependencyContainer().makeMaintenanceViewController().embedInNavigationController()
        maintenanceVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Maintenance", comment: "Maintenance"), image: UIImage(named: "Maintenance"), tag: 2)
        
        
        
        viewControllers = [installationVC, cameraVC, maintenanceVC]
        
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
    
    static func goHome() {
        dismissToRootViewController()
        tabBarController?.selectedIndex = 0
        dismissToRootViewController()
    }
    
//    static func gotoLogin() {
//        //        AccountControlManager.shared.reverseSkippingLogin()
//        if let rootWindow = UIApplication.shared.delegate?.window {
//            let rootViewController = SignInContainerViewController.createViewController()
//            rootViewController.view.alpha = 0.0
//            rootWindow!.rootViewController = rootViewController
//
//            UIView.transition(with: rootWindow!, duration: Constants.Animation.defaultDuration, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
//                rootViewController.view.alpha = 1.0
//            }, completion: { (_) in
//            })
//
//            AppIconBadge.reset()
//        }
//    }
    
    static func gotoLogin() {
        //        AccountControlManager.shared.reverseSkippingLogin()
        let vc = LoginMKViewController(nibName: "LoginMKViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        appDelegate.setRootVC(vc: nav)
        
        
        AppIconBadge.reset()
    }
    
    static func gotoAlbum() {
        dismissToRootViewController()
        
#if FLEET
        if AccountControlManager.shared.isLogin {
            let vc = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController()!
            currentNavigationController?.pushViewController(vc, animated: true)
        } else {
            tabBarController?.moveToAlbumTab()
        }
#else
        tabBarController?.moveToAlbumTab()
#endif
    }
    
    static func gotoCameraTab() {
        dismissToRootViewController()
        tabBarController?.moveToCameraTab()
    }
    
#if FLEET
    
    static func showNotificationListViewController() {
        if !(topViewController is NotificationListViewController) {
            dismissToRootViewController()
            tabBarController?.moveToOverviewTab()
            dismissToRootViewController()
            
          //  let vc = NotificationListDependencyContainer().makeNotificationListViewController()
            let vc = NotiListViewController(nibName: "NotiListViewController", bundle: nil)
            (tabBarController?.selectedViewController as? UINavigationController)?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    static func showNotiDetaiViewController(item : NotiItem) {
        if !(topViewController is NotiDetailController) {
            dismissToRootViewController()
            tabBarController?.moveToOverviewTab()
            dismissToRootViewController()
            
          //  let vc = NotificationListDependencyContainer().makeNotificationListViewController()
            let vc = NotiDetailController(nibName: "NotiDetailController", bundle: nil)
            vc.model = item
            (tabBarController?.selectedViewController as? UINavigationController)?.pushViewController(vc, animated: true)
        }
    }
    
#else
    
    static func showAlertListViewController() {
        if tabBarController?.rootViewControllerOfSelectedTab is AlertListViewController {
            dismissToRootViewController()
        } else {
            dismissToRootViewController()
            tabBarController?.moveToAlertTab()
            dismissToRootViewController()
        }
    }
    
    static func showMessageDetailIfPossible(_ messageID: Int64) {
        func shouldLeaveCurrentViewController() -> Bool {
            if currentViewController?.isEditing == true ||
                currentViewController is SelectRangeViewController ||
                currentViewController is ExportSessionViewController ||
                currentViewController is ExportProgressViewController {
                return false
            } else {
                return true
            }
        }
        
        if shouldLeaveCurrentViewController() {
            showAlertListViewController()
            (tabBarController?.rootViewControllerOfSelectedTab as? AlertListViewController)?.showMessageViewController(messageID, animated: false)
        }
    }
    
#endif
    
    static func showChangePasswordViewController(canSkip: Bool = true) {
        let container = SignInContainerViewController.createViewController()
        container.notRefresh = true
        
        if #available(iOS 13.0, *) {
            container.modalPresentationStyle = .fullScreen
        }
        
        let vc = ForgotStepOneViewController.createViewController()
        vc.emailText = AccountControlManager.shared.keyChainMgr.email
        vc.emailFixed = true
        container.setRoot(vc)
        
        vc.backButton.isHidden = !canSkip
        
        topViewController?.present(container, animated: true, completion: nil)
    }
    
    static func showChangePassword() {
        let container = SignInContainerViewController.createViewController()
        container.notRefresh = true
        
        if #available(iOS 13.0, *) {
            container.modalPresentationStyle = .fullScreen
        }
        
        let vc = ForgotPassViewController.createViewController()
        
        container.setRoot(vc)
        topViewController?.present(container, animated: true, completion: nil)
    }
    
    static func dismissToRootViewController() {
        if let selectedIndex = tabBarController?.selectedIndex {
            dismissToRootViewController(forIndex: selectedIndex)
        }
    }
    
    static func dismissToRootViewController(forIndex index: Int) {
        guard let tabNavigationController = tabBarController?.selectedViewController as? UINavigationController else {
            return
        }
        
        var index = tabNavigationController.viewControllers.count - 1
        while index >= 0 {
            let currentVC = tabNavigationController.viewControllers.last
            (currentVC?.presentedViewController as? UINavigationController)?.popToRootViewController(animated: false)
            currentVC?.dismiss(animated: false, completion: nil)
            currentVC?.dismissMyself(animated: false)
            index -= 1
        }
    }
    
}

extension UIViewController {
    
    func backTwo() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    var topMostViewController: UIViewController {
        if let vc = presentedViewController {
            return vc.topMostViewController
        } else if let vc = self as? UINavigationController {
            if let topVC = vc.topViewController {
                return topVC.topMostViewController
            } else {
                return self
            }
        } else if let vc = navigationController?.topViewController {
            if vc == self {
                return self
            } else {
                return vc.topMostViewController
            }
        } else {
            return self
        }
    }
    
    func backToSelf(animated: Bool = false, completion: (() -> Void)? = nil) {
        if let vc = presentedViewController {
            vc.dismiss(animated: animated, completion: { [weak self] in
                self?.backToSelf(animated: animated, completion: completion)
            })
        } else {
            self.navigationController?.popToViewController(self, animated: animated)
            completion?()
        }
    }
    
    func openBrowser(withURL url: URL) {
        let safariViewController = SafariViewController(url: url)
        if #available(iOS 11.0, *) {
            safariViewController.dismissButtonStyle = .close
        }
        
        if #available(iOS 13.0, *) {
            safariViewController.modalPresentationStyle = .fullScreen
        }
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    func openBrowser(withURLString urlString: String) {
        if let url = URL(string: urlString) {
            openBrowser(withURL: url)
        }
    }
    
    func dismissMyself(animated: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)
        if let viewControllersCount = navigationController?.viewControllers.count, viewControllersCount > 1 {
            navigationController?.popViewController(animated: animated)
            completion?()
        } else {
            presentingViewController?.dismiss(animated: animated, completion: completion)
        }
    }
}

extension UIViewController {
    
    func showViewController(_ viewControllerToShow: UIViewController) {
        if let nc = self.navigationController {
            nc.pushViewController(viewControllerToShow, animated: true)
        } else {
            let nc = BaseNavigationController(rootViewController: viewControllerToShow)
            
            if #available(iOS 13.0, *) {
                nc.modalPresentationStyle = .fullScreen
            }
            
            present(nc, animated: true, completion: nil)
        }
    }
    
    func alert(title: String? = nil, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func alert(title: String? = nil, message: String, cancelHandler: (() -> Void)? = nil, okHandler: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in
            cancelHandler?()
        })
        alertVC.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
            okHandler?()
        })
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    @discardableResult
    func alert(title: String? = nil, message: String, action1: (() -> UIAlertAction), action2: (() -> UIAlertAction)? = nil) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertVC.addAction(action1())
        
        if let action2 = action2 {
            alertVC.addAction(action2())
        }
        
        present(alertVC, animated: true, completion: nil)
        
        return alertVC
    }
    
    func alertPushNoitificationSettingsMessage() {
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? "Secure360"
        
        let alertVC = UIAlertController(
            title: title,
            message: String(format: NSLocalizedString("enable_notifications_alert_message", comment: "Enable %@ notifications via your device menu:\n\"Settings\"->\"Notifications\"->\"%@\""), appName, appName),
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        let goAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertVC.addAction(goAction)
        topMostViewController.present(alertVC, animated: true, completion: nil)
    }
    
    func alertLocalNetworkPermissionMessage() {
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? "This app"
        
        let alertVC = UIAlertController(
            title: title,
            message: String(format: NSLocalizedString("enable_local_network_alert_message", comment: "Local network is currently disabled, to discover your camera, please enable %@ local network in your device\n\"Settings\"->\"Privacy\"->\"Local Network\"->\"%@\""), appName, appName),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        
        let goAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertVC.addAction(goAction)
        
        topMostViewController.present(alertVC, animated: true, completion: nil)
    }
    
    func alertCameraWiFiConnectionMessage() {
        alert(message: NSLocalizedString("Please connect to your camera's Wi-Fi.", comment: "Please connect to your camera's Wi-Fi."))
    }
    
    func alertJumpingToSystemSettingsMessage(_ message: String) {
        alert(title: nil, message: message, cancelHandler: nil) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(
                    URL.init(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            } else {
                UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
    
    func presentExportClipSheet(with accessoryView: UIView? = nil, dismissClosure: @escaping (ExportDestination?) -> ()) {
        var actions: [ActionSheetAction] = []
        
        if self is HNAlbumViewController {
            actions.append(ActionSheetAction(title: NSLocalizedString("Export to Photo Library", comment: "Export to Photo Library"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_photo_library")], handler: { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
                dismissClosure(.photoLibrary)
            }))
            
#if !FLEET
            actions.append(ActionSheetAction(title: NSLocalizedString("Share to Waylens", comment: "Share to Waylens"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_waylens")], handler: { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
                dismissClosure(.waylens)
            }))
#endif
        } else {
            func commonFunc() {
                actions.append(ActionSheetAction(title: NSLocalizedString("Save to Album Only", comment: "Save to Album Only"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_album")], handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                    dismissClosure(.albumInApp)
                }))
                
                actions.append(ActionSheetAction(title: NSLocalizedString("Export to Photo Library", comment: "Export to Photo Library"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_album"), #imageLiteral(resourceName: "icon_action_sheet_export_to_photo_library")], handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                    dismissClosure(.photoLibrary)
                }))
            }
            
#if FLEET
//            if UserSetting.current.userProfile?.roles.contains(.installer) == true {
//                actions.append(ActionSheetAction(title: NSLocalizedString("Export to Photo Library", comment: "Export to Photo Library"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_photo_library")], handler: { [weak self] (action) in
//                    self?.dismiss(animated: true, completion: nil)
//                    dismissClosure(.photoLibrary)
//                }))
//            }
//            else {
//                commonFunc()
//            }
            commonFunc()
#else
            commonFunc()
            
            actions.append(ActionSheetAction(title: NSLocalizedString("Share to Waylens", comment: "Share to Waylens"), images: [#imageLiteral(resourceName: "icon_action_sheet_export_to_album"), #imageLiteral(resourceName: "icon_action_sheet_export_to_waylens")], handler: { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
                dismissClosure(.waylens)
            }))
#endif
        }
        
        actions.append(ActionSheetAction.cancelAction(handler: { _ in
            dismissClosure(nil)
        }))
        
        let sheet = ActionSheetController(title: nil, actions: actions)
        sheet.accessoryView = accessoryView
        present(sheet, animated: true, completion: nil)
    }
    
    func presentExportClipSheet(_ clip: EditableClip, camera: UnifiedCamera?, streamIndex: Int32, dismissClosure: (() -> ())? = nil) {
        func didSelect(_ exportDestination: ExportDestination) {
            let vc = ExportSessionViewController.createViewController(
                clip: clip,
                camera: camera,
                streamIndex: clip.needDewarp ? 0 : streamIndex,
                exportDestination: exportDestination
            )
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        presentExportClipSheet { (exportDestination) in
            if let exportDestination = exportDestination {
                didSelect(exportDestination)
            } else {
                dismissClosure?()
            }
        }
    }
    
    func presentDeleteClipSheet(title: String, deleteHandler: @escaping () -> (), cancelHandler: (() -> ())? = nil) {
        var actions: [ActionSheetAction] = []
        
        actions.append(ActionSheetAction.deleteAction(handler: { _ in
            deleteHandler()
        }))
        actions.append(ActionSheetAction.cancelAction(handler: { _ in
            cancelHandler?()
        }))
        
        let sheet = ActionSheetController(title: title, actions: actions)
        present(sheet, animated: true, completion: nil)
    }
    
    func presentSwitchStreamSheet(items: [HNVideoResolution], selectHandler: @escaping (HNVideoResolution) -> ()) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheetOrAlertOnPad)
            
            items.forEach { resolution in
                sheet.addAction(UIAlertAction(title: resolution.longDescription, style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                    selectHandler(resolution)
                }))
            }
            
            sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }))
            
            present(sheet, animated: true, completion: nil)
        }
        else {
            let menuItems = items.map { item in
                LandscapeMenuItem(title: item.description, action: {
                    selectHandler(item)
                })
            }
            let vc = LandscapeMenuViewController(items: menuItems)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func showAgreementViewController() {
        let vc = BaseWebViewController()
        vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/license/raw.html")
        vc.title = NSLocalizedString("License Agreement", comment: "License Agreement")
        showViewController(vc)
    }
    
    func showSharingVideoAgreementViewController() {
        let vc = BaseWebViewController()
        vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/terms-share/raw.html")
        vc.title = NSLocalizedString("License Agreement", comment: "License Agreement")
        showViewController(vc)
    }
    
    func showCameraDetailViewController(for camera: UnifiedCamera, scrollTo date: Date? = nil) {
        let detailVC = HNCameraDetailViewController.createViewController(camera: camera, dateScrollTo: date)
        showViewController(detailVC)
    }
    
    func presentDataPlanViewController(forCamera cameraSN: String) {
        let planVC = PlanWebViewController.createViewController()
        planVC.camera = UnifiedCameraManager.shared.cameraForSN(cameraSN)
        
        if #available(iOS 13.0, *) {
            planVC.modalPresentationStyle = .fullScreen
        }
        
        present(planVC, animated: true, completion: nil)
    }
    
    func showFirmwareViewController(for camera: UnifiedCamera) {
        let firmwareVC = HNCSFirmwareViewController.createViewController()
        firmwareVC.camera = camera
        showViewController(firmwareVC)
    }
    
    func showPowerCordTestIfPossible() -> Bool {
        var success = false
        if let camera = UnifiedCameraManager.shared.local, camera.viaWiFi {
            if camera.featureAvailability.isUntrustACCWireSupportAvailable == true {
                
                let vc = PCTCableTypeViewController.createViewController()
                vc.camera = camera
                navigationController?.pushViewController(vc, animated: true)
                
            } else {
                
                let vc = WireDiagnosisPrepareViewController.createViewController()
                vc.camera = camera
                navigationController?.pushViewController(vc, animated: true)
                
            }
            success = true
        } else {
            alert(message: NSLocalizedString("Please connect to your camera's Wi-Fi.", comment: "Please connect to your camera's Wi-Fi."))
        }
        return success
    }
    
    func presentCleanCacheController() {
        let alert = UIAlertController(
            title: NSLocalizedString("Clear Cache", comment: "Clear Cache"),
            message: NSLocalizedString("clear_cache_message", comment: "total cache size: calculating..."),
            preferredStyle: .actionSheetOrAlertOnPad
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        let size = String.fromBytes(TSCacheManager.cacheSize(), countStyle: .file)
        alert.message = String(format: NSLocalizedString("Total cache size: %@", comment: "Total cache size: %@"), size)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear", comment: "Clear"), style: .destructive, handler: { (_) in
            CacheManager.shared.clear()
            TSCacheManager.clearCache({
                HNMessage.showSuccess(message: NSLocalizedString("Cache cleared", comment: "Cache cleared"))
            })
        }))
    }
    
    func presentLogOutConfirmation() {
        let alert = UIAlertController.init(title: NSLocalizedString("Log Out?", comment: "Log Out?"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Log Out", comment: "Log Out"), style: .default, handler: { (UIAlertAction) in
            SessionService.shared.logout(completion:nil)
            AccountControlManager.shared.keyChainMgr.onLogOut()
            AppViewControllerManager.gotoLogin()
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showApnSetting(masked: Bool = true) {
        let alert = UIAlertController(
            title: NSLocalizedString("APN Setting", comment: "APN Setting"),
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { (textField) in
            textField.clearButtonMode = .always
            
            if let apn = WLBonjourCameraListManager.shared.currentCamera?.apn, !apn.isEmpty {
                textField.placeholder = masked ? apn.maskedApnString() : apn
            }
            else {
                textField.placeholder = NSLocalizedString("Unconfigured", comment: "Unconfigured")
            }
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Save"), style: .default, handler: { (_) in
            let apn = alert.textFields?.first?.text ?? ""
            if let currentCamera = WLBonjourCameraListManager.shared.currentCamera {
                currentCamera.doSetAPN(apn)
                currentCamera.doGetAPN()
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
