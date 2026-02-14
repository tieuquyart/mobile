//
//  NotificationsManager.swift
//  Acht
//
//  Created by forkon on 2021/1/8.
//  Copyright © 2021 waylens. All rights reserved.
//

import Foundation

final class NotificationsManager {

    func scheduleReturnToAppNotification() {
        let content = UNMutableNotificationContent()
        let message: String
        
        #if FLEET
        message = NSLocalizedString("Connect camera's Wi-Fi, then return to app.", comment: "Connect camera's Wi-Fi, then return to app.")
        #else
        message = NSLocalizedString("Connect Waylens-XXXXX, then return to app.", comment: "Connect Waylens-XXXXX, then return to app.")
        #endif
        
        content.body = message

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "returnToApp", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleContinueExportingNotification() {
        let content = UNMutableNotificationContent()
        content.body = NSLocalizedString("Return to app to continue exporting.", comment: "Return to app to continue exporting.")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(identifier: "continueExporting", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
