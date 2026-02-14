//
//  MyFleetSettingsViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class MyFleetSettingsViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: MyFleetSettingsUserInterfaceView
    private let viewControllerFactory: MyFleetSettingsViewControllerFactory

    init(
        observer: Observer,
        userInterface: MyFleetSettingsUserInterfaceView,
        viewControllerFactory: MyFleetSettingsViewControllerFactory
        ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = NSLocalizedString("Settings", comment: "Settings")

        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.tintColor = .black
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func applyTheme() {
        super.applyTheme()
        
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
    }
}

extension MyFleetSettingsViewController: MyFleetSettingsIxResponder {

    func navigateTo(viewController: UIViewController.Type) {
        if viewController == UIAlertController.self {
            if WLBonjourCameraListManager.shared.currentCamera != nil {
                showApnSetting()
            }
            else {
                alertCameraWiFiConnectionMessage()
            }
        }
        else {
            let toVC = viewControllerFactory.makeViewController(with: viewController)
            if let navVC = toVC as? UINavigationController {
                wl.present(navVC, animated: true, completion: nil)
            }
            else {
                navigationController?.pushViewController(toVC, animated: true)
            }
        }
    }

    func cleanCache() {
        presentCleanCacheController()
    }
}

extension MyFleetSettingsViewController: ObserverForMyFleetSettingsEventResponder {

    func transitionToNew(state: MyFleetSettingsViewControllerState) {
        userInterface.render(newState: state.viewState)
    }

}

protocol MyFleetSettingsViewControllerFactory {
    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController
}
