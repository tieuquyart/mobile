//
//  RegisterDeviceViewController.swift
//  Acht
//
//  Created by Đoàn Vũ on 15/02/2023.
//  Copyright © 2023 waylens. All rights reserved.
//

//
//  RegisterDeviceViewController.swift
//  Acht
//
//  Created by Đoàn Vũ on 15/02/2023.
//  Copyright © 2023 waylens. All rights reserved.
//

import UIKit

class RegisterDeviceViewController: BaseViewController {
    
    var andCustomerId = ""
    var andProviderId = "0"
    var andBranchId = "4"
    var deviceName = ""
    var deviceId = ""
    
    
    
    @IBOutlet weak var customerIdTf: UITextField!
    @IBOutlet weak var providerCodeTf: UITextField!
    @IBOutlet weak var appIdTf: UITextField!
    @IBOutlet weak var  activeButton: UIButton!
   
    func setBorderView(view : UIButton) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getDeviceName()
        getDeviceId()
        self.setBorderView(view: activeButton)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
        
        self.initHeader(text: "Đăng ký thiết bị", leftButton: false)
        
        showNavigationBar(animated: animated)
        
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        AccountControlManager.shared.keyChainMgr.onLogOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func activeButton(_ sender: Any) {
        submitAction()
    }
    
    func showAlert (_ errorStr : String) {
        self.hideProgress()
        let alert = UIAlertController(title: "", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //b3 present
        present(alert, animated: true, completion: nil)
    }


    func activate() {
        self.showProgress()
        DispatchQueue.global().async {
            
            ConstantMK.helperMK.doActivate(url: "https://dev.mk.com.vn:35503/api/", andCustomerId: self.customerIdTf.text ?? "", andProviderId: self.providerCodeTf.text ?? "00001" , andBranchId: "4") {
                DispatchQueue.main.async {
                    self.hideProgress()
                    let vc = FaceVerifiedViewController(nibName: "FaceVerifiedViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } andFailureHandler: { (err) in
                DispatchQueue.main.async {
                    self.showAlert(err.localizedDescription)
                }
            } errorHandler: { (err) in
                DispatchQueue.main.async {
                    self.showAlert("Lỗi license")
                }
            }
        }
    }
    
   func getDeviceName() {
       ConstantMK.helperMK.getDeviceName { value in
           self.deviceName = value
           print("deviceName",value)
       } errorHandler: { err in
           self.showAlert("\(err.rawValue)")
       }
   }
    
    func getDeviceId() {
        ConstantMK.helperMK.getDeviceId { id in
            self.deviceId  = id
            print("deviceId",id)
        } errorHandler: { err in
            self.showAlert("\(err.rawValue)")
        }
    }
    
    var timer: Timer?

    @objc func submitAction() {
  //      self.activate()
        //call postRequest with username and password parameters
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            self.activate()
        })
        
        
    }
    
}


extension RegisterDeviceViewController : URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

}
