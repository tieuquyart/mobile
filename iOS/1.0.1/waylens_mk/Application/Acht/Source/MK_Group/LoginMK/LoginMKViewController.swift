//
//  LoginMKViewController.swift
//  Fleet
//
//  Created by TranHoangThanh on 11/22/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit


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
    @IBOutlet weak var viewCheckBox: UIView!
    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var passTfView: TextFieldMKCustom!
    @IBOutlet weak var emailTfView: TextFieldMKCustom!
    @IBOutlet weak var useMOCSW: UISwitch!
    
    @IBOutlet weak var haveAccountLabel: UILabel!
    var isChecked = false
    
    @IBOutlet weak var viewContainerCheckBox: UIView!
    
    
    var helper  = ConstantMK.helperMK
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        self.isChecked = UserSetting.shared.isChecked ?? false
        self.loadCheckBox()
        self.emailTfView.infoTextField.text = UserSetting.shared.lastEmail
        self.passTfView.infoTextField.text = UserSetting.shared.savePwd
        viewContainerCheckBox.addTapGesture {
            self.isChecked.toggle()
            self.loadCheckBox()
        }
        self.useMOCSW.isOn = false
        self.useMOCSW.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                    ConstantMK.parseJson(dict: value) { success,msg in
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
                            
                        }else{
                            if msg == "Invalid access token." {
                                self.presentInvalidAccessToken()
                            } else {
                                self.showAlert(title: "", message: msg)
                            }
                        }
                    }
                case .failure(let err):
                    self.showAlert(title: "", message: err?.localizedDescription)
                }
            })
        }
    }
    
    var notRefresh: Bool = false
    
    
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
        }else{
            setInfoApp()
        }
    }
    
    private func remove(_ vc: AccountMKPageViewController?) {
        vc?.view.removeFromSuperview()
        vc?.removeFromParent()
    }
    
    
    
    func config() {
        guard let usernameText = emailTfView.infoTextField.text , !usernameText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("K_input_account", comment: "K_input_account"), to: nil)
            return
        }
        guard let passwordText = passTfView.infoTextField.text, !passwordText.isEmpty else {
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
                            
                            if ConstantMK.isUseMOC {
                                UserSetting.shared.isMoc = false
                                UserSetting.shared.isLoggedIn = false
                                ConstantMK.helperMK.checkAppActivated(successHandler: { b in print("doanvt-hn: success = \(b)")
                                    self?.checkMOC(resultActive: b)
                                })
                            }else{
                                self?.refreshUI(animated:true)
                            }
                            
                            
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
    
    func checkMOC(resultActive: Bool){
        if resultActive {
            let vc = FaceVerifiedViewController(nibName: "FaceVerifiedViewController", bundle: nil)
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: false)
        }else{
//            getDeviceInfoForRegisterDevice(serverUrl: "https://192.168.0.195:15503/api/")
            let vc = LoginEidViewController(nibName: "LoginEidViewController", bundle: nil)
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: false)
//            self.postRequest { (result, error) in
//                if let result = result {
//                    print("success: \(result)")
//
//                    DispatchQueue.main.async {
//                        let vc = AppViewControllerManager.createLoginEidViewController()
//                        self.navigationController?.pushViewController(vc, animated: false)
//                    }
//
//                } else if let error = error {
//
//                    print("error: \(error.localizedDescription)")
//
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "NoticeRegister", message: error.localizedDescription)
//                    }
//
//                    return
//
//                }
//            }
        }
    }
    
    func getDeviceInfoForRegisterDevice(serverUrl: String) {
        self.showProgress()
        helper.getDeviceInfoForRegisterDevice(serverUrl: serverUrl) { res in
        print("res",res)
            do {

                guard let data = res.data(using: .utf8) else {return}
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let websiteDescription = try decoder.decode(DeviceInfo.self, from: data)
                self.postRequestRegisterDeviceV2(param: websiteDescription) { (result, error) in
                    if let result = result {
                        if let success = result["success"] as? Bool {
                            if success {
                          
                                 self.activate()
                        
                            }
                        }

                    } else if let error = error {

                        self.hideProgress()
                        print("error: \(error.localizedDescription)")

                        DispatchQueue.main.async {
                            self.showAlert(error.localizedDescription)
                        }

                        return

                    }
                }
            } catch let err {
                self.hideProgress()
                self.showAlert("\(err.localizedDescription)")

            }
            
            
        } errorHandlerSDK: { err1 in
            self.hideProgress()
            self.showAlert("\(err1.localizedDescription)")
        }

    }
    
    func activate() {

        helper.doActivate(url: "https://192.168.0.195:15503/api/", andCustomerId: "", andBranchId: "") {
            //print("thanh")
            self.hideProgress()
            self.showToast(message: "Kích hoạt thành công", seconds: 1.0, completion: {
                
                let vc = FaceVerifiedViewController(nibName: "FaceVerifiedViewController", bundle: nil)
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: false)
            })
        } andFailureHandler: { (err) in
            
            self.hideProgress()
            self.showAlert(err.localizedDescription)
        } errorHandler: { (err) in
            self.hideProgress()
            self.showAlert("\(err.rawValue)")
        }
        
    }
    
    func showAlert (_ errorStr : String) {
        let alert = UIAlertController(title: "", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //b3 present
        present(alert, animated: true, completion: nil)
    }
    
    
    func postRequestRegisterDeviceV2(param : DeviceInfo , completion: @escaping ([String: Any]?, Error?) -> Void) {


        //declare parameter as a dictionary which contains string as key and value combination.
        let parameters : [String : Any] = param.convertToDict()

        //create the url with NSURL
        
        // print("parameters",parameters)
        
        
        let username = "api"
        let password = "apipassword1"
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
    
        let url = URL(string: "https://192.168.0.195:15600/api/device-reg/registerDeviceV2")!
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
       // let session = URLSession.shared

        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil, error)
        }

        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }

            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })

        task.resume()
    }
    
    
    
    override func applyTheme() {
        self.loadCheckBox()
        self.titleLbl.textColor = UIColor.black
        self.titleLbl.font =  AppFont.regular.size(20)
        rememberMeLbl.font =  AppFont.regular.size(14)
        haveAccountLabel.font =  AppFont.regular.size(14)
        btnLogin.titleLabel?.font = AppFont.regular.size(14)
        btnForgotPassword.titleLabel?.font = AppFont.regular.size(14)
        btnRegister.titleLabel?.font = AppFont.regular.size(14)
        btnLogin.layer.cornerRadius = 12
        btnLogin.layer.masksToBounds = true
        emailTfView.setTitle(str: "Tài khoản")
        passTfView.setTitle(str: "Mật Khẩu")
        
        passTfView.infoTextField.isSecureTextEntry = true
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        
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
    
    
    func postRequest(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let username = "api"
        let password = "apipassword1"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
//        let base64LoginString = loginData.base64EncodedString()
//
//        var deviceName = ""
//        var deviceId = ""
        
//        ConstantMK.helperMK.getDeviceName(successHandler: {va in deviceName = va}, errorHandler: { err in print(err.rawValue)})
//        ConstantMK.helperMK.getDeviceId(successHandler: {va in deviceId = va}, errorHandler: { err in print(err.rawValue)})
//        ConstantMK.helperMK.getDeviceInfoForRegisterDevice(successHandler: { result in print("result: \(result)")}, errorHandler: { err in print("error: \(err.rawValue)")})
        
        //declare parameter as a dictionary which contains string as key and value combination.
        let parameters : [String : Any] = [ "providerCode" : "00001" , "deviceId": "deviceId", "deviceType": 4 , "deviceName" : "deviceName",  "appId": 3]
        
        //create the url with NSURL
        
        
        
        let url = URL(string: "https://dev.mk.com.vn:35503/api/common/registerDevice")!
        //create the session object
        
//        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let session = URLSession(configuration: .default)
        // let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: url)
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil, error)
        }
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
    
    
    
    
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBAction func btnRegister(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "", message: "Bạn có cần tạo fleet không?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        let ok = UIAlertAction(title: "Có", style: .default, handler: { action in
            
            let vc = CheckCameramMKViewController(nibName: "CheckCameramMKViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: "Không", style: .default, handler: { action in
            let vc = RegisterMKViewController(nibName: "RegisterMKViewController", bundle: nil)
            vc.titleTxt = "Tạo tài khoản"
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(cancel)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBOutlet weak var rememberMeLbl: UILabel!
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        let vc = RegisterMKViewController(nibName: "RegisterMKViewController", bundle: nil)
        
        vc.titleTxt = "Quên mật khẩu"
        vc.isRememberPassword = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        config()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension LoginMKViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
