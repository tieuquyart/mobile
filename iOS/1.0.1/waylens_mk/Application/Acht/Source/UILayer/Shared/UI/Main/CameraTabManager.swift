//
//  CameraTabManager.swift
//  Acht
//
//  Created by forkon on 2020/1/8.
//  Copyright © 2020 waylens. All rights reserved.
//

class CameraTabManager: NSObject {

    weak var tabBarController: TabBarController?

    var cameraTabViewController: UINavigationController! {
        didSet {
            if oldValue != nil {
                cameraTabViewController.tabBarItem = oldValue.tabBarItem
            }
        }
    }

    override init() {
        super.init()
        
        cameraTabViewController = makeCameraTabViewController(camera: preferredCameraAutoPicked)

        NotificationCenter.default.addObserver(self, selector: #selector(cameraListDidUpdate), name: Notification.Name.WLCurrentCameraChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraListDidUpdate), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Private

private extension CameraTabManager {

    var preferredCameraAutoPicked: UnifiedCamera? {
        return UnifiedCameraManager.shared.local ?? UnifiedCameraManager.shared.cameras.first
    }

    @objc func cameraListDidUpdate() {
        var cameraAutoPicked: UnifiedCamera? = UnifiedCameraManager.shared.current

        if cameraAutoPicked == nil {
            cameraAutoPicked = preferredCameraAutoPicked
        }

        func commonFunc() {
            if let currentCamera = cameraAutoPicked {
                if let cameraDetailViewController = cameraTabViewController.viewControllers.first as? HNCameraDetailViewController {
                    cameraDetailViewController.camera = currentCamera
                } else {
                    let oldCameraTabViewControllerIndex: Int? = tabBarController?.viewControllers?.firstIndex(of: cameraTabViewController)

                    cameraTabViewController = makeCameraTabViewController(camera: currentCamera)

                    replaceCameraTabViewController(at: oldCameraTabViewControllerIndex)
                }
            } else {
                if !(cameraTabViewController.viewControllers.first is HNHomeViewController) {
                    let oldCameraTabViewControllerIndex: Int? = tabBarController?.viewControllers?.firstIndex(of: cameraTabViewController)

                    cameraTabViewController = makeCameraTabViewController(camera: nil)

                    replaceCameraTabViewController(at: oldCameraTabViewControllerIndex)
                }
            }
        }

        #if FLEET
        if
//            (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                ||
                !AccountControlManager.shared.isLogin
        {
            if let cameraDetailViewController = cameraTabViewController.viewControllers.first as? HNCameraDetailViewController {
                cameraDetailViewController.camera = cameraAutoPicked
            }
        }
        else {
            commonFunc()
        }
        #else
        commonFunc()
        #endif

        UnifiedCameraManager.shared.current?.messageManager.delegate = self

        if let camera = UnifiedCameraManager.shared.current {
            showFirstUnreadMessage(of: camera)
        }
    }

    func makeCameraTabViewController(camera: UnifiedCamera?) -> UINavigationController {
        var vc: UINavigationController!

        func commonFunc() {
            if let camera = camera {
                #if FLEET
                let isCameraPickerEnabled = false
                #else
                let isCameraPickerEnabled = true
                #endif

                vc =  HNCameraDetailViewController.createViewController(camera: camera, isCameraPickerEnabled: isCameraPickerEnabled).embedInNavigationController()
                vc.view.backgroundColor = UIColor.semanticColor(.background(.primary))
                vc.view.usingDynamicBackgroundColor = true
            } else {
                #if FLEET
                vc = UIStoryboard(name: "Home-Fleet", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
                #else
                vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()!.embedInNavigationController()
                #endif
            }
        }

        #if FLEET
        if
//            (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                ||
                !AccountControlManager.shared.isLogin
        {
            vc = HNCameraDetailViewController.createViewController(camera: camera, isCameraPickerEnabled: false).embedInNavigationController()
            vc.view.backgroundColor = UIColor.semanticColor(.background(.primary))
            vc.view.usingDynamicBackgroundColor = true
        }
        else {
            commonFunc()
        }
        #else
        commonFunc()
        #endif

        return vc
    }

    func replaceCameraTabViewController(at tabIndex: Int?) {
        if let tabBarController = tabBarController {
            var viewControllers: [UIViewController] = tabBarController.viewControllers ?? []

            if let cameraDetailNavigationVC = viewControllers.first(where: {($0 as? UINavigationController)?.viewControllers.first is HNCameraDetailViewController}) {
                cameraDetailNavigationVC.dismiss(animated: false, completion: nil)
            }

            if let tabIndex = tabIndex {
                viewControllers.insert(cameraTabViewController, at: tabIndex)
                viewControllers.remove(at: tabIndex + 1)
            } else {
                viewControllers.insert(cameraTabViewController, at: 0)
            }

            tabBarController.setViewControllers(viewControllers, animated: false)
        }
    }

    func show(_ message: HNCameraMessage?) {
        guard let message = message, !message.isRead else {
            return
        }

        HNMessage.showWhisper(for: message, in: cameraTabViewController.viewControllers.first, completion: { _ in
            UnifiedCameraManager.shared.current?.messageManager.read(message)
        })
    }

    func showFirstUnreadMessage(of camera: UnifiedCamera) {
        let firstUnreadMessage = camera.messageManager.messages.first(where: {!$0.isRead})
        show(firstUnreadMessage)
    }
}

extension CameraTabManager: HNMessageManagerDelegate {

    func onCameraTopMessageUpdated(camera: UnifiedCamera) {
        HNMessage.hideWhisper()
        showFirstUnreadMessage(of: camera)
    }

}


extension TabBarController {

    private struct AssociatedKeys {
        static var cameraTabManager: UInt8 = 8
    }

    var cameraTabManager: CameraTabManager? {
        set {
            newValue?.tabBarController = self
            objc_setAssociatedObject(self, &AssociatedKeys.cameraTabManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let cameraTabManager = objc_getAssociatedObject(self, &AssociatedKeys.cameraTabManager) as? CameraTabManager
            return cameraTabManager
        }
    }

}
