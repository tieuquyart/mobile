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
    
    
    //    private let observer: Observer
    private let viewControllerFactory: MyFleetSettingsViewControllerFactory
    
    init(
        viewControllerFactory: MyFleetSettingsViewControllerFactory
    ) {
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: "MyFleetSettingsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var cleanCacheView: UIView!
    @IBOutlet weak var settingAlertView: UIView!
    @IBOutlet weak var reportErrView: UIView!
    
    @IBOutlet weak var aboutLb: UILabel!
    @IBOutlet weak var cleanCacheLb: UILabel!
    @IBOutlet weak var settingAlertLb: UILabel!
    @IBOutlet weak var reportErrLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        let title = NSLocalizedString("Settings", comment: "Settings")
        initHeader(text: title, leftButton: false)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.tintColor = .black
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI(){
        aboutLb.text = NSLocalizedString("About", comment: "About")
        cleanCacheLb.text = NSLocalizedString("Clear Cache", comment: "Clear Cache")
        settingAlertLb.text = NSLocalizedString("Alert Settings", comment: "Alert Settings")
        reportErrLb.text = NSLocalizedString("Report an Issue", comment: "Report an Issue")
        
        //onclickView
        aboutView.addTapGesture {
            self.navigateTo(viewController: AboutViewController.self)
        }
        
        cleanCacheView.addTapGesture {
            self.presentCleanCacheController()
        }
        
        settingAlertView.addTapGesture {
            self.navigateTo(viewController: AlertSettingsViewController.self)
        }
        
        reportErrView.addTapGesture {
            self.navigateTo(viewController: FeedbackController.self)
        }
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
    }
    
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
}

extension MyFleetSettingsViewController: ObserverForMyFleetSettingsEventResponder {
    
    func transitionToNew(state: MyFleetSettingsViewControllerState) {
    }
    
}

protocol MyFleetSettingsViewControllerFactory {
    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController
}
