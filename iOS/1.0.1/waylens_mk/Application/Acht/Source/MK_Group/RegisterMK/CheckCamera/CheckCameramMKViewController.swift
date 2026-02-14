//
//  CheckCameramMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 11/28/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import SwiftyJSON




class CheckCameramMKViewController: BaseViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var serialCameraTextField: TextFieldMKCustom!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var haveAccountLabel: UILabel!
    var isRegister = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme()
    }
    func config() {

     
        
        guard let serialCamera = serialCameraTextField.infoTextField.text, !serialCamera.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your serialCamera", comment: "Input your serialCamera"), to: nil)
            return
        }
        
        CameraService.shared.checkSerial(val: serialCamera.uppercased(), completion: { [weak self] (_result) in
                        switch _result {
                        case .success(let dict):
                            if let success = dict["success"] as? Bool {
            
                                if success {
                                    let vc = RegisterMKViewController(nibName: "RegisterMKViewController", bundle: nil)
                                    vc.titleTxt = "Tạo tài khoản"
                                    vc.isFleet = true
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                    
                                    
                                } else {
                                    if let mess = dict["message"] as? String {
                                        self?.showAlert(title: ConstantMK.language(str: "Alert"), message: ConstantMK.language(str: mess))
                                    }
                                   
                                }
                            } else {
                                HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                            }
                            break
                        case .failure(let err):
                            HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                            break
                        }
                    })

      
    }
    
    
    override func applyTheme() {
        self.titleLbl.textColor = UIColor.black
        self.titleLbl.font =  AppFont.regular.size(20)
        self.haveAccountLabel.textColor = UIColor.black
        self.haveAccountLabel.font =  AppFont.regular.size(14)
        self.loginButton.titleLabel?.font = AppFont.regular.size(14)
        checkButton.titleLabel?.font = AppFont.regular.size(14)
      
        checkButton.layer.cornerRadius = 12
        checkButton.layer.masksToBounds = true
        
        
        serialCameraTextField.setTitle(str: "Camera S/N")
       
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
   }
    
    
    @IBAction func checkButon(_ sender: Any) {
        
      config()
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if isRegister {
            self.backTwo()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
}
