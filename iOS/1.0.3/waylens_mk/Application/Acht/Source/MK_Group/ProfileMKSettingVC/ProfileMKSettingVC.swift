//
//  ProfileMKSettingVC.swift
//  Acht
//
//  Created by TranHoangThanh on 12/26/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class ProfileMKSettingVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var viewAccount: ButtonCustomMK!
    @IBOutlet weak var viewChangePassword: ButtonCustomMK!
    @IBOutlet weak var viewSetting: ButtonCustomMK!
    @IBOutlet weak var viewUpradeAccount: ButtonCustomMK!
    @IBOutlet weak var viewLogout: ButtonCustomMK!
    
    @IBOutlet weak var viewContainerAlert: UIView!
    
    @IBOutlet weak var removeAccout: ButtonCustomMK!
    var tapCloruse : (()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        configUI()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeViewButton(_ sender: Any) {
        self.tapCloruse?()
        //        remove(asChildViewController: self)
    }
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    func configUI() {
        
        viewAccount.setTitle(str: "Thông tin tài khoản", imageStr: "usergray")
        viewAccount.addTapGesture {
            if let user = UserSetting.current.userProfile {
                let userInterface = MyFleetUserProfileRootView()
                let vc = MyFleetUserProfileViewController(userProfile: user, userInterface: userInterface)
                userInterface.ixResponder = vc
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        viewChangePassword.setTitle(str: "Đổi mật khẩu", imageStr: "keygray")
        viewChangePassword.addTapGesture {
            let vc = ChangePasswordMKViewController(nibName: "ChangePasswordMKViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        viewSetting.setTitle(str: "Cài đặt", imageStr: "settinggrayprofile")
        viewSetting.addTapGesture {
            let vc =  MyFleetSettingsDependencyContainer().makeMyFleetSettingsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        viewUpradeAccount.setTitle(str: "Nâng cấp tài khoản", imageStr: "crown")
        viewUpradeAccount.addTapGesture {
            self.showToast(message: "Comming Soon", seconds: 1)
        }
        viewLogout.setTitle(str: "Đăng xuất", imageStr: "logoutgray")
        viewLogout.setTitleColorAndImageColor(color: UIColor.red)
        
        viewLogout.addTapGesture {
            self.presentLogOutConfirmation()
        }
        removeAccout.setTitle(str: "Xoá tài khoản", imageStr: "delete account")
        removeAccout.setTitleColorAndImageColor(color: UIColor.red)
        
        removeAccout.addTapGesture {
            self.presentRemoveAccountConfirmation()
        }
        if let user = UserSetting.current.userProfile {
            self.nameLabel.text = user.userName
            self.roleLabel.text = user.get_role()
        }
    }
}
