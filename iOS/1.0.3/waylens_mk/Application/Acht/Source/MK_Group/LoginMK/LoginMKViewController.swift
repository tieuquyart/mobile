//
//  LoginMKViewController.swift
//  Fleet
//
//  Created by TranHoangThanh on 11/22/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK
private extension LoginMKViewController {
    
    func add(viewController : UIViewController , asChildViewController childController : UIViewController , direction : UIView.AnimationOptions) -> Void {
        viewController.addChild(childController)
        UIView.transition(with: viewController.view, duration: 0.3, options: direction, animations: {
            [viewController] in
            viewController.view.addSubview(childController.view)
        }, completion: nil)
        childController.view.frame = viewController.view.bounds
        childController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childController.didMove(toParent: viewController)
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}

class AccountMKPageViewController: UIViewController {
    weak var container: LoginMKViewController?
}
class LoginMKViewController: BaseViewController  {
    
    @IBOutlet weak var btnConnectCamera: UIButton!
    @IBOutlet weak var rememberMeLbl: UILabel!
    @IBOutlet weak var viewCheckBox: UIView!
    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var useMOCSW: UISwitch!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var haveAccountLabel: UILabel!
    @IBOutlet weak var viewContainerCheckBox: UIView!
    @IBOutlet weak var viewUserNAme: UIView!
    @IBOutlet weak var viewPass: UIView!
    @IBOutlet weak var btnShowPass: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    var isCheckRemoveAccount: Bool = false
    var notRefresh: Bool = false
    var isChecked = false
    var isConnectCamera : Bool = false
    var isSetting : Bool = false
    let cameraObserver = ObserverForCurrentConnectedCamera()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnConnectCamera.layer.cornerRadius = 8
        btnConnectCamera.layer.borderWidth = 1
        btnConnectCamera.layer.borderColor = UIColor.color(fromHex: "#133D7A").cgColor
        cameraObserver.eventResponder = self
        cameraObserver.startObserving()
        applyTheme()
        
        if self.isCheckRemoveAccount {
            self.txtUserName.text = ""
            self.txtPass.text = ""
            UserSetting.shared.lastEmail = ""
            UserSetting.shared.savePwd = ""
            self.isChecked = false
            UserSetting.shared.isChecked = false
            
        } else {
            self.txtUserName.text = UserSetting.shared.lastEmail
            self.txtPass.text = UserSetting.shared.savePwd
            self.isChecked = UserSetting.shared.isChecked ?? false
        }
        
        self.loadCheckBox()
        viewContainerCheckBox.addTapGesture {
            self.isChecked.toggle()
            self.loadCheckBox()
        }
        
        viewUserNAme.layer.cornerRadius = 8.0
        viewUserNAme.addShadow(offset: CGSize.init(width: 3, height: 4))
        viewPass.layer.cornerRadius = 8.0
        viewPass.addShadow(offset: CGSize.init(width: 3, height: 4))
        txtPass.isSecureTextEntry = true
    }
    
    func loadCheckBox() {
        if !isChecked {
            self.viewCheckBox.backgroundColor = UIColor.white
            self.viewCheckBox.layer.borderColor = UIColor.gray.cgColor
            self.viewCheckBox.layer.borderWidth = 1
            self.viewCheckBox.layer.cornerRadius = 5
            self.imgChecked.isHidden = true
        } else {
            self.imgChecked.isHidden = false
            self.viewCheckBox.layer.borderColor = UIColor.color(fromHex: "0B2C5A").cgColor
            self.viewCheckBox.layer.borderWidth = 1
            self.viewCheckBox.layer.cornerRadius = 5
            self.viewCheckBox.backgroundColor = UIColor.color(fromHex: "0B2C5A")
        }
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch!){
        if(sender.isOn == true){
            ConstantMK.isUseMOC = true
        }else{
            ConstantMK.isUseMOC = false
        }
        print("switchMOC: \(sender.isOn)")
    }
    
    func setInfoApp() {
        if !ConstantMK.isShowUpdate {
            NotificationServiceMK.shared.infoApp(completion: { (result) in
                switch result {
                case .success(let value):
                    ConstantMK.parseJson(dict: value) { success,msg, code  in
                        if success {
                            if let data = value["data"] as? JSON {
                                if let infoData = try? JSONSerialization.data(withJSONObject: data, options: []){
                                    do {
                                        let item = try JSONDecoder().decode(UpdateMK.self, from: infoData)
                                        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                                        if let buildNumber = Int(build) {
                                            if  item.versionCode ?? 1 > buildNumber{
                                                let controller =  AlertNotiCustomViewController(nibName: "AlertNotiCustomViewController", bundle: nil)
                                                controller.item = item
                                                self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
                                                ConstantMK.isShowUpdate =  true
                                            }
                                        }
                                    } catch let err {
                                        print("err get infoApp",err)
                                    }
                                }
                            }
                        } else {
                            self.showErrorResponse(code: code)
                        }
                    }
                case .failure(let err):
                    self.alert(title: "", message: err?.localizedDescription ?? "")
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        if notRefresh {
            notRefresh = false
        } else {
            refreshUI(animated: animated)
        }
    }
    
    func refreshUI(animated: Bool = false) {
        if AccountControlManager.shared.isLogin {
            UserSetting.shared.isMoc = true
            quit(animated: animated, completion: nil)
        } else {
            setInfoApp()
        }
    }
    
    private func remove(_ vc: AccountMKPageViewController?) {
        vc?.view.removeFromSuperview()
        vc?.removeFromParent()
    }
    func config() {
        guard let usernameText = txtUserName.text , !usernameText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("K_input_account", comment: "K_input_account"), to: nil)
            return
        }
        guard let passwordText = txtPass.text, !passwordText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your password", comment: "Input your password"), to: nil)
            return
        }
        HNMessage.show()
        SessionService.shared.login(name: usernameText, password: passwordText, completion: { [weak self] (_result) in
            switch _result {
            case .success(let dict):
                if let data = dict["data"] as? JSON {
                    if  let role = data["roleNames"] as? [String] {
                        if (role[0] == "FLEETADMIN" || role[0] == "FLEET_USER") {
                            if self!.isChecked {
                                UserSetting.shared.lastEmail = usernameText
                                UserSetting.shared.savePwd = passwordText
                            }else{
                                UserSetting.shared.lastEmail = ""
                                UserSetting.shared.savePwd = ""
                            }
                            UserSetting.shared.isChecked = self?.isChecked
                            HNMessage.dismiss()
                            AccountControlManager.shared.keyChainMgr.onLogInMK(data)
                            self?.refreshUI(animated:true)
                        } else {
                            HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed Roles", comment: "Login Failed Roles"), to: self?.navigationController)
                        }
                    }
                } else {
                    if let message = dict["message"] as? String{
                        HNMessage.showError(message: message , to: self?.navigationController)
                    }else{
                        HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                    }
                }
                break
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                break
            }
        })
    }
    
    @IBAction func skipLogin(_ sender: Any) {
        if !self.isSetting {
            if self.isConnectCamera {
                let vc = HNCameraDetailViewController.createViewController(camera: UnifiedCameraManager.shared.local,isCameraPickerEnabled: false, isCheckLoginCamera: true)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.isSetting = true
                self.showProgress()
                UIApplication.shared.open(URL(string: "App-prefs:WIFI")!)
            }
        }
    }
    
    func showAlert (_ errorStr : String) {
        let alert = UIAlertController(title: "", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func applyTheme() {
        self.loadCheckBox()
        btnLogin.layer.cornerRadius = 8
        btnLogin.layer.masksToBounds = true
        btnLogin.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
    }
    @objc func quit(animated: Bool, completion: (() -> Void)?) {
        view.resignFirstResponder()
        if let _ = presentingViewController {
            dismiss(animated: animated, completion: completion)
        } else {
            if let rootWindow = appDelegate.window {
                let rootViewController = AppViewControllerManager.createTabBarController()
                rootWindow.rootViewController = rootViewController
                
                UIView.transition(with: rootWindow, duration: Constants.Animation.defaultDuration, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                    rootWindow.rootViewController = rootViewController
                }, completion: { (_) in
                    completion?()
                })
            }
        }
    }
    
    
    @IBAction func btnRegister(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let msg = "Bạn có cần tạo Fleet không?"
        let att = [NSAttributedString.Key.font: UIFont(name: "BeVietnamPro-Regular", size: 14)]
        let attstring = NSAttributedString(string: msg, attributes: att as [NSAttributedString.Key : Any])
        
        alert.setValue(attstring, forKey: "attributedMessage")
        
        // add the actions (buttons)
        let ok = UIAlertAction(title: "Có", style: .default, handler: { action in
            
            let vc = CheckCameramMKViewController(nibName: "CheckCameramMKViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: "Không", style: .default, handler: { action in
            let vc = RegisterMKViewController(nibName: "RegisterMKViewController", bundle: nil)
            vc.titleTxt = "Đăng ký tài khoản"
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        let vc = RegisterMKViewController(nibName: "RegisterMKViewController", bundle: nil)
        vc.titleTxt = "Quên mật khẩu"
        vc.isRememberPassword = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        config()
    }
    @IBAction func onShowPass(_ sender: Any) {
        btnShowPass.isSelected = !btnShowPass.isSelected
        if btnShowPass.isSelected == true {
            txtPass.isSecureTextEntry = false
        } else {
            txtPass.isSecureTextEntry = true
        }
    }
}

extension LoginMKViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
extension LoginMKViewController : ObserverForCurrentConnectedCameraEventResponder {
    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        self.isSetting = false
        if let newCameraConnected = camera, newCameraConnected.productSerie != .unknown {
            self.isConnectCamera = true
            self.hideProgress()
            self.btnConnectCamera.setTitle("Xem camera trực tiếp", for: .normal)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.hideProgress()
            })
            self.isConnectCamera = false
            self.btnConnectCamera.setTitle("Kết nối camera", for: .normal)
          }
    }
}
