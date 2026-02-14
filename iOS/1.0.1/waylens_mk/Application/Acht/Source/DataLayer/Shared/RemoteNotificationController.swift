//
//  RemoteNotificationController.swift
//  Acht
//
//  Created by forkon on 2019/6/3.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import Whisper
import UserNotifications

class RemoteNotificationController {
    static let shared = RemoteNotificationController()

    var remoteNotificationToken : String? = nil

    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .badge, .sound, .alert
        ]) { granted, _ in
            guard granted else {
                #if FLEET

//                guard UserSetting.current.userProfile?.roles.contains(.fleetManager) == true else {
//                    return
//                }

                #else

                guard UnifiedCameraManager.shared.has4gCamera else {
                    return
                }

                #endif

                DispatchQueue.main.async {
                    appDelegate.window?.rootViewController?.alertPushNoitificationSettingsMessage()
                }

                return
            }

            DispatchQueue.main.async {
                sharedApplication.registerForRemoteNotifications()
            }
        }
    }

    func sendPushNotificationDetails(using deviceToken: Data) {
        remoteNotificationToken = deviceToken.hexString()

        #if FLEET
       // let shouldReceivePushNotifications = AccountControlManager.shared.isAuthed && UserSetting.current.userProfile?.roles.contains(.fleetManager) == true
        #else
        let shouldReceivePushNotifications = AccountControlManager.shared.isAuthed
        #endif

//        if let remoteNotificationToken = remoteNotificationToken, shouldReceivePushNotifications {
//            WaylensClientS.shared.refreshPushNotificationToken(remoteNotificationToken, completion: nil)
//        }
        
        if let remoteNotificationToken = remoteNotificationToken {
            WaylensClientS.shared.refreshPushNotificationToken(remoteNotificationToken, completion: nil)
        }
    }

    func handleNotificationDictionary(_ notificationDictionary: [AnyHashable: Any]) {
        #if FLEET

        if appDelegate.isActive {
            var title: String? = nil

            if let key = alertKey(in: notificationDictionary), let args = alertArgs(in: notificationDictionary) {
                title = String(format: NSLocalizedString(key, comment: "remote notification"), arguments: args)
            } else {
                title = alertBody(in: notificationDictionary)
            }

            if let title = title, !title.isEmpty {
                let announcement = Announcement(title: title, subtitle: nil, image: #imageLiteral(resourceName: "icon_settings_camera picture"), duration: 5)
                show(shout: announcement, to: appDelegate.window!.rootViewController!, completion: {

                })
            }
        }

        AppViewControllerManager.overviewViewController?.noteNewMessage()

        #else

        let sn = notificationDictionary["sn"] as? String
        let type = notificationDictionary["type"] as? String
        if type == "CAMERA_UPDATED" {
            NotificationCenter.default.post(name: Notification.Name.Remote.settingsUpdated, object: sn)
        }

        if appDelegate.isActive {
            var title = ""

            let alertKey = self.alertKey(in: notificationDictionary)
            if let key = alertKey {
                let args = alertArgs(in: notificationDictionary) ?? []
                title = String(format: NSLocalizedString(key, comment: "push notification title"), arguments: args)
            }

            if title.isEmpty {
                title = alertTitle(in: notificationDictionary) ?? ""
            }

            if !title.isEmpty {
                // TODO: set camera avatar
                let announcement = Announcement(title: title, subtitle: nil, image: #imageLiteral(resourceName: "icon_settings_camera picture"), duration: 5)
                show(shout: announcement, to: appDelegate.window!.rootViewController!, completion: {
                    print("The shout was silent.")
                })
            }

            switch alertKey {
            case "PARKING_MOTION",
                 "PARKING_HIT",
                 "PARKING_HEAVY_HIT",
                 "DRIVING_HEAVY_HIT",
                 "DRIVING_HIT":
                NotificationCenter.default.post(name: Notification.Name.Remote.alert, object: sn)
            case "CAMERA_ONLINE_FORMAT",
                 "CAMERA_OFFLINE_FORMAT":
                NotificationCenter.default.post(name: Notification.Name.Remote.stateChanged, object: sn)
            case "LEFT_DATA",
                 "DATA_WARNING",
                 "PLAN_WILL_EXPIRE",
                 "PLAN_EXPIRED",
                 "CAM_ONLINE",
                 "CAM_OFFLINE",
                 "NEW_FIRMWARE",
                 "NEW_APP_VERSION",
                 "OUT_OF_DATA":
                AppViewControllerManager.alertListViewController?.noteNewMessage()
            default:
                break
            }

        } else {
            if let alertKey = alertKey(in: notificationDictionary) {
                switch alertKey {
                case "LEFT_DATA",
                     "DATA_WARNING",
                     "PLAN_WILL_EXPIRE",
                     "PLAN_EXPIRED",
                     "CAM_ONLINE",
                     "CAM_OFFLINE",
                     "NEW_FIRMWARE",
                     "NEW_APP_VERSION",
                     "OUT_OF_DATA":
                    AppViewControllerManager.alertListViewController?.noteNewMessage()
                default:
                    break
                }
            }
        }

        #endif
    }
    
    func handleNotificationDictionary(in val: [AnyHashable : Any]) {
        
        print("handleNotificationDictionary")
    
        AppViewControllerManager.showNotificationListViewController()

       
    }

//    func handleNotificationDictionary(in launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
//
//        print("handleNotificationDictionary")
//        guard let notificationDictionary = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] else {
//            return
//        }
//
//        #if FLEET
//
////        guard AccountControlManager.shared.isAuthed, UserSetting.current.userProfile?.roles.contains(UserRoles.fleetManager) == true else {
////            return
////        }
//
//        AppViewControllerManager.showNotificationListViewController()
//
//        #else
//
//        if let messageID = messageID(in: notificationDictionary) {
//              AppViewControllerManager.showMessageDetailIfPossible(messageID)
//        } else {
//            if let dict = notificationDictionary["aps"] as? [String : Any], let alert = dict["alert"] as? [String : Any], let titleKey = alert["loc-key"] as? String {
//
//                switch titleKey {
//                case "PARKING_MOTION",
//                     "PARKING_HIT",
//                     "PARKING_HEAVY_HIT",
//                     "DRIVING_HEAVY_HIT",
//                     "DRIVING_HIT":
//                    AppViewControllerManager.showAlertListViewController()
//                default:
//                    break
//                }
//            }
//        }
//
//        #endif
//    }

}

private extension RemoteNotificationController {

    func messageID(in notificationDictionary: [AnyHashable : Any]) -> Int64? {
        return ((notificationDictionary["aps"] as? [String : Any])?["userinfo"] as? [String: Any])?["msgID"] as? Int64
    }

    func alertKey(in notificationDictionary: [AnyHashable : Any]) -> String? {
        let apsDict = notificationDictionary["aps"] as? [String : Any]
        let alert = apsDict?["alert"] as? [String : Any]
        let alertKey = alert?["loc-key"] as? String
        return alertKey
    }

    func alertArgs(in notificationDictionary: [AnyHashable : Any]) -> [String]? {
        let apsDict = notificationDictionary["aps"] as? [String : Any]
        let alert = apsDict?["alert"] as? [String : Any]
        let alertArgs = alert?["loc-args"] as? [String]
        return alertArgs
    }

    func alertTitle(in notificationDictionary: [AnyHashable : Any]) -> String? {
        let apsDict = notificationDictionary["aps"] as? [String : Any]
        let alert = apsDict?["alert"] as? [String : Any]
        let alertTitle = alert?["title"] as? String
        return alertTitle
    }

    func alertBody(in notificationDictionary: [AnyHashable : Any]) -> String? {
        let apsDict = notificationDictionary["aps"] as? [String : Any]
        let alert = apsDict?["alert"] as? [String : Any]
        let alertBody = alert?["body"] as? String
        return alertBody
    }

}
