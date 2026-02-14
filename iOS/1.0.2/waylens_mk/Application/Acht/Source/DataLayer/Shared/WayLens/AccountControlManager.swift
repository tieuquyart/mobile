//
//  AccountControlManager.swift
//  Acht
//
//  Created by forkon on 2019/9/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AccountControlManager {
    static let shared: AccountControlManager  = AccountControlManager()

    let keyChainMgr: WaylensKeyChainManager = WaylensKeyChainManager()

    var isLogin: Bool {
      //  return keyChainMgr.token != nil
        return keyChainMgr.token != nil && UserSetting.shared.isLoggedIn
    }

    var isAuthed:Bool {
        return isLogin && isVerified
    }

    var isVerified: Bool {
        return UserSetting.current.isVerified
    }

//    func skipLogin() {
//        UserSetting.shared.hasSkippedLogin = true
//    }
//
//    func reverseSkippingLogin() {
//        UserSetting.shared.hasSkippedLogin = false
//    }

    func fetchUserProfile() {
        WaylensClientS.shared.fetchProfile(completion: nil)
    }

}

class LoginInfo {
    var token : String?
    var expiredTime: Date?
    var userInfo: LoginUserInfo = LoginUserInfo()
}

struct LoginUserInfo {
    var displayName: String = NSLocalizedString("Waylens User", comment: "Waylens User")
    var roles: [String] = []
    var email: String = ""
    var avatarUrl : String? = nil
    var largeAvatarUrl: String? = nil
    var createTime: Date?
}
