//
//  AccountVC.swift
//  Fleet
//
//  Created by DevOps MKVision on 18/12/2023.
//  Copyright © 2023 waylens. All rights reserved.
//

import UIKit

class AccountVC: BaseViewController {
    @IBOutlet weak var viewAvatar: UIImageView!
    @IBOutlet weak var accountLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var roleLb: UILabel!
    @IBOutlet weak var galleryLb: UILabel!
    @IBOutlet weak var settingLb: UILabel!
    @IBOutlet weak var changePwdLb: UILabel!
    @IBOutlet weak var logoutLb: UILabel!
    @IBOutlet weak var removeAccLb: UILabel!
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var changePwdView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var removeAccView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initHeader(text: NSLocalizedString("My Fleet", comment: "My Fleet"), leftButton: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setBorderCircleView(view: self.viewAvatar)
        
        setUI()
    }
    
    override func setUI() {
        
        galleryLb.text = NSLocalizedString("Album", comment: "Album")
        settingLb.text = NSLocalizedString("Settings", comment: "Settings")
        changePwdLb.text = NSLocalizedString("Change Password", comment: "Change Password")
        logoutLb.text = NSLocalizedString("Log Out", comment: "Log Out")
        removeAccLb.text = "Xóa tài khoản"
        
        if let user = UserSetting.current.userProfile {
            if let img = user.avatar, !img.isEmpty{
                if let user = UserSetting.current.userProfile?.isVip() {
                    if user {
                        self.viewAvatar.image = UIImage(named: "Avatar")!
                    } else {
                        self.viewAvatar.image = UIImage(named: "AvatarNoVip")!
                    }
                } else {
                    self.viewAvatar.image = UIImage(named: "AvatarNoVip")!
                }
            }else{
                if let user = UserSetting.current.userProfile?.isVip() {
                    if user {
                        self.viewAvatar.image = UIImage(named: "Avatar")!
                    } else {
                        self.viewAvatar.image = UIImage(named: "AvatarNoVip")!
                    }
                } else {
                    self.viewAvatar.image = UIImage(named: "AvatarNoVip")!
                }
            }
            self.accountLb.text = user.userName
            self.nameLb.text = user.realName
            self.roleLb.text = user.get_role()
        }
        
        galleryView.addTapGesture {
            let storyboard = UIStoryboard(name: "Library", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HNAlbumViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        settingView.addTapGesture {
            let vc =  MyFleetSettingsDependencyContainer().makeMyFleetSettingsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        changePwdView.addTapGesture {
            let vc = ChangePasswordMKViewController(nibName: "ChangePasswordMKViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        logoutView.addTapGesture {
            self.presentLogOutConfirmation()
        }
        
        removeAccView.addTapGesture {
            self.presentRemoveAccountConfirmation()
        }
        
    }


    func setBorderCircleView(view : UIView) {
        view.layer.cornerRadius = view.bounds.width/2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        
    }
}
