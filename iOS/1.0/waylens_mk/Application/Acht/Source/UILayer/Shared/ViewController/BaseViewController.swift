//
//  BaseViewController.swift
//  Acht
//
//  Created by Chester Shen on 6/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import Photos
import WaylensCameraSDK


import Foundation

struct UpdateMK: Codable {

    let versionCode: Int?
    let versionName: String?
    let forceUpdate: Bool?
    let storeUrl: String?

    private enum CodingKeys: String, CodingKey {
        case versionCode = "versionCode"
        case versionName = "versionName"
        case forceUpdate = "forceUpdate"
        case storeUrl = "storeUrl"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        versionCode = try values.decodeIfPresent(Int.self, forKey: .versionCode)
        versionName = try values.decodeIfPresent(String.self, forKey: .versionName)
        forceUpdate = try values.decodeIfPresent(Bool.self, forKey: .forceUpdate)
        storeUrl = try values.decodeIfPresent(String.self, forKey: .storeUrl)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(versionCode, forKey: .versionCode)
        try container.encodeIfPresent(versionName, forKey: .versionName)
        try container.encodeIfPresent(forceUpdate, forKey: .forceUpdate)
        try container.encodeIfPresent(storeUrl, forKey: .storeUrl)
    }

}

open class BaseViewController: UIViewController {
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    
    func initHeader(text: String, leftButton: Bool){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.title = ""
        if text == ""{
            
        }else{
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            self.navigationItem.title = text
        }
        self.navigationItem.hidesBackButton = !leftButton
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
        self.view.layoutIfNeeded()
    }

    
    
    func setUI() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func presentInvalidAccessToken() {
        let alert = UIAlertController.init(title: NSLocalizedString("Invalid access token", comment: "Invalid access token"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Ok", comment: "Ok"), style: .default, handler: { (UIAlertAction) in
            SessionService.shared.logout(completion:nil)
            AccountControlManager.shared.keyChainMgr.onLogOut()
            AppViewControllerManager.gotoLogin()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorResponse(msg: String){
        if msg == "Invalid access token." {
            self.presentInvalidAccessToken()
        } else {
            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg.localizeMk()), preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(ok)
            
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func showProgress(){
        SVProgressHUD.show()
    }
    
    func hideProgress(){
        if SVProgressHUD.isVisible(){
            SVProgressHUD.dismiss()
        }
    }
  

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    open func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
}

extension BaseViewController: Themed {

    @objc open func applyTheme() {
    }

}

open class BlankBaseViewController: BaseViewController {
    var shadowImageView: UIImageView?
    var shadowWasHidden: Bool = false
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shadowImageView == nil, let navBar = navigationController?.navigationBar {
            shadowImageView = findShadowImage(under: navBar)
        }
        if let shadowImageView = shadowImageView {
            shadowWasHidden = shadowImageView.isHidden
            shadowImageView.isHidden = true
        } else {
            shadowWasHidden = true
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let shadowImageView = shadowImageView {
            shadowImageView.isHidden = shadowWasHidden
        }
    }
}

extension UIViewController {

    func hideNavigationBar(animated: Bool){
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    func showNavigationBar(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
    }

    var isTopViewController: Bool {
        if let topVC = navigationController?.topViewController {
            return (topVC == self && presentedViewController == nil)
        } else {
            return presentedViewController == nil
        }
    }
    
    func showAlertforceUpdate(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String,
                   btnRight: String, action: @escaping (() -> ())) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Check title left is availabel
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel, handler: nil))
        
        // Check title right is availabel
        alert.addAction(UIAlertAction(title: btnRight, style: .default, handler: { (_) in
            //ta sẽ thoát firebase ở đây
            action()
            
        }))
        
        
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
        
    }

    func showNoConnectionAlert() {
        let message: String
        #if FLEET
        message = NSLocalizedString("Your phone is not connected to camera's Wi-Fi. Please try again.", comment: "Your phone is not connected to camera's Wi-Fi. Please try again.")
        #else
        message = NSLocalizedString("Your phone is not connected to \"Waylens-XXXXX\". Please try again.", comment: "Your phone is not connected to \"Waylens-XXXXX\". Please try again.")
        #endif
        
        showAlert(
            title: NSLocalizedString("Not Connected", comment: "Not Connected"),
            message: message
        )
    }

    func checkPhotoAuth(authed:@escaping (()->Void), status: PHAuthorizationStatus = .notDetermined) {
        var authStatus = status

                if authStatus == .notDetermined {
                    if #available(iOS 14, *) {
                        authStatus = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.addOnly)
                    } else {
                        authStatus = PHPhotoLibrary.authorizationStatus()
                    }
                }

                switch authStatus {
                case .notDetermined:
                    let handler: (PHAuthorizationStatus) -> Void = { [weak self] (authorizationStatus) in
                        guard let self = self else {
                            return
                        }

                        DispatchQueue.main.async {
                            self.checkPhotoAuth(authed: authed, status: authorizationStatus)
                        }
                    }

                    if #available(iOS 14, *) {
                        PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.addOnly, handler: handler)
                    } else {
                        PHPhotoLibrary.requestAuthorization(handler)
                    }
                case .authorized:
                    authed()
                case .restricted, .denied:
                    let alert = UIAlertController(
                        title: NSLocalizedString("Not Authorized", comment: "Not Authorized"),
                        message: NSLocalizedString("Please enable photo access in system settings", comment: "Please enable photo access in system settings"),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (_) in
                        sharedApplication.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    present(alert, animated: true, completion: nil)
                case .limited:
                    let alert = UIAlertController(
                        title: nil,
                        message: NSLocalizedString("To export video, please allow this app to access your full photo library.", comment: "To export video, please allow this app to access your full photo library."),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (_) in
                        sharedApplication.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    present(alert, animated: true, completion: nil)
                @unknown default:
                    break
                }
    }
    
}

