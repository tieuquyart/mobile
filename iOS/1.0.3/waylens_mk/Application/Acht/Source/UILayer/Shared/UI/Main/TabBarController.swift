//
//  TabBarController.swift
//  Acht
//
//  Created by forkon on 2019/3/7.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    let normalTabBarAttributes: [NSAttributedString.Key : Any] = [
        .font: UIFont(name: "BeVietnamPro-Medium", size: 12.0)!,
        .foregroundColor: UIColor.blue
    ]
    
    let selectedTabBarAttributes: [NSAttributedString.Key : Any] = [
        .font: UIFont(name: "BeVietnamPro-Medium", size: 12.0)!,
        .foregroundColor: UIColor.red
    ]
    
    override open var shouldAutorotate: Bool {
        if let topMostViewController = selectedViewController?.topMostViewController {
            if (topMostViewController is BaseViewController) || (topMostViewController is BaseTableViewController) {
                return topMostViewController.shouldAutorotate
            }
        }
        
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topMostViewController = selectedViewController?.topMostViewController {
            if (topMostViewController is BaseViewController) || (topMostViewController is BaseTableViewController) {
                if topMostViewController.supportedInterfaceOrientations == .landscapeRight { // for LibraryDetailViewController
                    return .portrait
                }
                else {
                    return topMostViewController.supportedInterfaceOrientations
                }
            }
        }
        
        return .portrait
    }
    
    
    var rootViewControllerOfSelectedTab: UIViewController? {
        return (selectedViewController as? UINavigationController)?.viewControllers.first
    }
    
    var albumTabIndex: Int? {
        if let viewControllers = viewControllers {
            for i in 0..<viewControllers.count {
                if rootViewControllerOfTab(at: i) is HNAlbumViewController {
                    return i
                }
            }
        }
        return nil
    }
    
    var cameraTabIndex: Int? {
        if let viewControllers = viewControllers {
            for i in 0..<viewControllers.count {
                if (rootViewControllerOfTab(at: i) is HNCameraDetailViewController) ||
                    (rootViewControllerOfTab(at: i) is HNHomeViewController) {
                    return i
                }
            }
        }
        return nil
    }
    
#if FLEET
    
    var overviewTabIndex: Int? {
        if let viewControllers = viewControllers {
            for i in 0..<viewControllers.count {
                if rootViewControllerOfTab(at: i) is OverviewViewController {
                    return i
                }
            }
        }
        return nil
    }
    
#else
    
    var alertListTabIndex: Int? {
        if let viewControllers = viewControllers {
            for i in 0..<viewControllers.count {
                if rootViewControllerOfTab(at: i) is AlertListViewController {
                    return i
                }
            }
        }
        return nil
    }
    
#endif
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneTabBarItemsImagePosition()
        if #available(iOS 15.0, *) {
            setTabBarAttributes()
            updateTabBarAppearance()
        } else {
            // Fallback on earlier versions
        }
        //
    }
    
    func setFontItembar(){
        if let viewControllers = viewControllers {
            for i in 0..<viewControllers.count {
                let vc = viewControllers[i]
                let tabBarItem = vc.tabBarItem
                let title = tabBarItem?.title
                let attTitle = [NSAttributedString.Key.font: UIFont(name: "BeVietnamPro-Medium", size: 12)!]
                let attstringTitle = NSAttributedString(string: title ?? "", attributes: attTitle as [NSAttributedString.Key : Any])
                tabBarItem?.setBadgeTextAttributes(attTitle, for: .normal)
            }
        }
        if #available(iOS 15.0, *) {
            setTabBarAttributes()
        }
    }
    
    @available(iOS 15.0, *)
    private func setTabBarAttributes(){
        guard let tabBarController = tabBarController as? TabBarController else {
            return
        }
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = tabBarController.normalTabBarAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = tabBarController.selectedTabBarAttributes
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
    }
    
    
    
    @available(iOS 15.0, *)
    private func updateTabBarAppearance() {
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        
        tabBarAppearance.backgroundColor = UIColor.color(fromHex: ConstantMK.bgTabar)
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    @available(iOS 13.0, *)
    private func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
        let tintColor: UIColor = .red
        let unselectedItemTintColor: UIColor = .green
        
        appearance.selected.iconColor = tintColor
        appearance.normal.iconColor = unselectedItemTintColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // avoid the layout of tab bar disorder after dismissing a rotateable view controller.
        if presentedViewController != nil {
            view.setNeedsLayout()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
#if !FLEET
        appDelegate.guideHelper.startGuideIfNeeded()
#endif
    }
    
    func moveToAlbumTab() {
        if let index = viewControllers?.firstIndex(where: {($0 as? UINavigationController)?.viewControllers.first is HNAlbumViewController}) {
            selectedIndex = index
        }
    }
    
    func moveToCameraTab() {
        if let cameraTabIndex = cameraTabIndex {
            selectedIndex = cameraTabIndex
        }
    }
    
#if FLEET
    
    func moveToOverviewTab() {
        if let index = viewControllers?.firstIndex(where: {($0 as? UINavigationController)?.viewControllers.first is OverviewViewController}) {
            selectedIndex = index
        }
    }
    
#else
    
    func moveToAlertTab() {
        if let index = viewControllers?.firstIndex(where: {($0 as? UINavigationController)?.viewControllers.first is AlertListViewController}) {
            selectedIndex = index
        }
    }
    
#endif
    
    func rootViewControllerOfTab(at index: Int) -> UIViewController? {
        if let viewControllers = viewControllers, !viewControllers.isEmpty {
            if index >= 0 && index < viewControllers.count {
                let viewController = viewControllers[index]
                if viewController.isKind(of: UINavigationController.self) {
                    return (viewController as? UINavigationController)?.viewControllers.first
                } else {
                    return viewController
                }
            }
        }
        return nil
    }
    
}

private extension TabBarController {
    
    func tuneTabBarItemsImagePosition() {
        tabBar.items?.forEach({ (item) in
            item.imageInsets = UIEdgeInsets(top: -1.0, left: 0.0, bottom: 1.0, right: 0.0)
            let att = [NSAttributedString.Key.font: UIFont(name: "BeVietnamPro-Medium", size: 12)!]
            item.setTitleTextAttributes(att, for: .normal)
        })
    }
    
}

#if FLEET

extension TabBarController: UserProfileObserver {}

//MARK: - UserProfileObserver

private struct AssociatedKeys {
    static var disposeBagKey: UInt8 = 0
    static var isPresentingResetDialogKey: UInt8 = 8
}

protocol UserProfileObserver: UIViewController {
    func startObservingUserProfile()
}

extension UserProfileObserver {
    
    private var disposeBag: DisposeBag {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var value = objc_getAssociatedObject(self, &AssociatedKeys.disposeBagKey) as? DisposeBag
            
            if value == nil {
                value = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBagKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return value!
        }
    }
    
    private var isPresentingResetDialog: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPresentingResetDialogKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            var value = objc_getAssociatedObject(self, &AssociatedKeys.isPresentingResetDialogKey) as? Bool
            
            if value == nil {
                value = false
                objc_setAssociatedObject(self, &AssociatedKeys.isPresentingResetDialogKey, value, .OBJC_ASSOCIATION_ASSIGN)
            }
            
            return value!
        }
    }
    
    func startObservingUserProfile() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UserSetting.userProfileChange, object: nil, queue: nil) { [weak self] _ in
            self?.alertResetInitialPasswordIfNeeded()
        }
        
        rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:))).subscribe { [weak self] (event) in
            self?.alertResetInitialPasswordIfNeeded()
        }.disposed(by: disposeBag)
    }
    
    private func alertResetInitialPasswordIfNeeded() {
        if
            AccountControlManager.shared.isLogin,
            let userProfile = UserSetting.current.userProfile,
            !userProfile.isVerified,
            !isPresentingResetDialog
        {
            isPresentingResetDialog = true
            
            AppViewControllerManager.topViewController?.alert(message: NSLocalizedString("You have not reset the initial password, please reset your password to continue using Waylens Service.", comment: "You have not reset the initial password, please reset your password to continue using Waylens Service."), action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Continue", comment: "Continue"), style: .default) { _ in
                    AppViewControllerManager.showChangePasswordViewController(canSkip: false)
                }
            })
        }
    }
    
}

#endif
