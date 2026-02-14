//
//  WaylensKetChainManager.swift
//  Acht
//
//  Created by gliu on 8/24/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation
import KeychainAccess

let waylensKeychainKeyToken       = "token"
let waylensKeychainKeyUserName    = "userName"
let waylensKeychainKeyWaylensID   = "id"
let waylensKeychainKeyEmail       = "email"
let waylensKeychainKeyAvatar      = "avatar"
let waylensKeychainKeyDisplayName = "displayName"


extension WaylensKeyChainManager {
    
    
    func onLogInMK(_ result : Dictionary<String, Any>) {
        
        if let userProfileJsonData = try? JSONSerialization.data(withJSONObject: result, options: []) {
            do {
                       // process data
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: userProfileJsonData)
                UserSetting.current.userProfile = userProfile
                keychain[waylensKeychainKeyToken] = userProfile.token
                keychain[waylensKeychainKeyUserName] = userProfile.userName
                UserSetting.shared.isLoggedIn = true
                UserSetting.current.fleetTimeZone = TimeZone.current
                   } catch  {
                      print(error)
               }
           
        }
        }
            
        
    }


class WaylensKeyChainManager {
    //
    let keychain = Keychain(service: "com.waylens.Acht-token")

    //API
    var token : String? {
        get {
            let token = ((try? keychain.get(waylensKeychainKeyToken)) as String??)

            #if FLEET
            if token != nil {
                return token!
            }
            #else
            if token != nil,
                let expired = self.expiredTime,
                expired.timeIntervalSinceNow > 0 {
                return token!
            }
            #endif

            return nil
        }
    }
    
    var expiredTime: Date? {
        get {
            if let timeString = ((try? keychain.get("expiredTime")) as String??), timeString != nil, let ts = Double(timeString!) {
                return Date(timeIntervalSince1970: ts)
            }
            return nil
        }
    }
    var userID : String? {
        get {
            let userID = ((try? keychain.get(waylensKeychainKeyWaylensID)) as String??)
            if (userID != nil) {
                return userID!
            }
            return nil
        }
    }
    var userName : String! {
        get {
            let userName = ((try? keychain.get(waylensKeychainKeyUserName)) as String??)
            if (userName != nil) {
                return userName!
            }
            return ""
        } 
    }
    var displayName: String! {
        get {
            if let name = ((try? keychain.get(waylensKeychainKeyDisplayName)) as String??) {
                if name != nil && name != "" {
                    return name!
                }
            }
            return userName
        }
        set {
            keychain[waylensKeychainKeyDisplayName] = newValue
        }
    }
    var email : String! {
        get {
            let email = ((try? keychain.get(waylensKeychainKeyEmail)) as String??)
            if (email != nil) {
                return email!
            }
            return""
        }
    }
    var avatarUrl : String? {
        get {
            let url = ((try? keychain.get(waylensKeychainKeyAvatar)) as String??)
            if (url != nil) {
                return url!
            }
            return nil
        }
    }

    var largeAvatarUrl: String?
//    var isAuthed : Bool {
//        get {
//            return token != nil
//        }
//    }
    
    func onLogInDone(_ result : Dictionary<String, Any>, email:String) {
        
        if (result[waylensKeychainKeyToken] != nil) {
            keychain[waylensKeychainKeyToken] = result[waylensKeychainKeyToken] as? String

            #if FLEET
            if let ts = result["expire"] as? Double {
                keychain["expiredTime"] = String(ts / 1000)
            }
            #else
            if let ts = result["expiredTime"] as? Double {
                keychain["expiredTime"] = String(ts / 1000)
            }
            #endif

            UserSetting.shared.isLoggedIn = true
        }

        #if !FLEET
        if (result["user"] != nil) {
            let user = result["user"] as! Dictionary<String, Any>
            if (user[waylensKeychainKeyUserName] != nil) {
                keychain[waylensKeychainKeyUserName] = user[waylensKeychainKeyUserName] as? String
            }
            if let name = user[waylensKeychainKeyDisplayName] as? String {
                displayName = name
            }
            if let userId = user[waylensKeychainKeyWaylensID] as? String {
                keychain[waylensKeychainKeyWaylensID] = userId
                UserSetting.current = UserSetting(userId)
            }
            keychain[waylensKeychainKeyEmail] = email
            UserSetting.shared.lastEmail = email
            if (user[waylensKeychainKeyAvatar] != nil) {
                keychain[waylensKeychainKeyAvatar] = user[waylensKeychainKeyAvatar] as? String
            }
            if let verified = user["isVerified"] as? Bool {
                UserSetting.current.isVerified = verified
            }
        }

        UnifiedCameraManager.shared.updateRemote()
        #endif
        
        if UserSetting.shared.isLoggedIn && UserSetting.current.isVerified {
            NotificationCenter.default.post(name: Notification.Name.App.loggedIn, object: nil)
        }
    }
    
    
    func updateProfileMK(_ result: [String: Any]) {
        #if FLEET
        
        let user = result["data"] as! Dictionary<String, Any>
        //keychain[waylensKeychainKeyAvatar] = result["logoUrl"] as? String
        keychain[waylensKeychainKeyUserName] = user["userName"] as? String
     //   keychain[waylensKeychainKeyEmail] = result["email"] as? String
        displayName = keychain[waylensKeychainKeyUserName]
      //  largeAvatarUrl = keychain[waylensKeychainKeyAvatar]

        if let userProfileJsonData = try? JSONSerialization.data(withJSONObject: user , options: []),
            let userMK = try? JSONDecoder().decode(UserMK.self, from: userProfileJsonData) {
           // UserSetting.current.isVerified = userProfile.isVerified
            UserSetting.current.userMK =  userMK
            keychain[waylensKeychainKeyWaylensID] = "\(userMK.id)"
            UserSetting.current = UserSetting("\(userMK.id)")
        }
    
//        if let timeZoneString = result["tzDatabase"] as? String {
//            UserSetting.current.fleetTimeZone = TimeZone(identifier: timeZoneString) ?? TimeZone.current
//        }
       #endif
    }
    
    func updateProfile(_ result: [String: Any]) {
        #if FLEET
        keychain[waylensKeychainKeyAvatar] = result["logoUrl"] as? String
        keychain[waylensKeychainKeyUserName] = result["userName"] as? String
        keychain[waylensKeychainKeyEmail] = result["email"] as? String
        displayName = keychain[waylensKeychainKeyUserName]
        largeAvatarUrl = keychain[waylensKeychainKeyAvatar]

        if let userProfileJsonData = try? JSONSerialization.data(withJSONObject: result, options: []),
            let userProfile = try? JSONDecoder().decode(UserProfile.self, from: userProfileJsonData) {
//            UserSetting.current.isVerified = userProfile.isVerified
               UserSetting.current.userProfile = userProfile
//            keychain[waylensKeychainKeyWaylensID] = userProfile.userID
//            UserSetting.current = UserSetting(userProfile.userID)
        }

        if let timeZoneString = result["tzDatabase"] as? String {
            UserSetting.current.fleetTimeZone = TimeZone(identifier: timeZoneString) ?? TimeZone.current
        }
        #else
        UserSetting.current.isVerified = result["isVerified"] as? Bool ?? false
        keychain[waylensKeychainKeyAvatar] = result["avatarThumbnailUrl"] as? String
        keychain[waylensKeychainKeyUserName] = result[waylensKeychainKeyUserName] as? String
        displayName = result[waylensKeychainKeyDisplayName] as? String
        largeAvatarUrl = result["avatarUrl"] as? String
        #endif
    }
    
    func onLogOut() {
        UserSetting.shared.isLoggedIn = false
        UserSetting.shared.isMoc = false
        NotificationServiceMK.shared.bindPushDevice(device: "ios", registrationId: "doanvt", completion: { (result) in
            print("result",result)
        })
        #if FLEET
        UserSetting.current.userProfile = nil
        #endif
        keychain[waylensKeychainKeyToken] = nil
        keychain[waylensKeychainKeyUserName] = nil
        keychain[waylensKeychainKeyWaylensID] = nil
        keychain[waylensKeychainKeyEmail] = nil
        keychain[waylensKeychainKeyAvatar] = nil
        keychain["expiredTime"] = nil
        largeAvatarUrl = nil
        UnifiedCameraManager.shared.removeAll()
        UnifiedCameraManager.shared.reload()
    }
}
