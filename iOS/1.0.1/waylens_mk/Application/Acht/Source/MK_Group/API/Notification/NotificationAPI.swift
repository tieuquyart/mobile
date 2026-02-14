//
//  NotificationAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 2/24/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya



protocol NotificationAPI {
    func bindPushDevice(device : String, registrationId : String, completion : completionBlock?)
    func user_notification_list( fromTime : String , toTime : String, completion : completionBlock?)
    func user_notification_page( index : Int , size : Int, completion : completionBlock?)
    func user_notification_page_category(category:String, index : Int , size : Int, completion : completionBlock?)
    func user_notification_unread_total(fromTime : String , toTime : String, completion : completionBlock?)
    func user_notification_info(notificationId  : String, completion : completionBlock?)
    func user_notification_read(notificationId  : String , completion : completionBlock?)
    func user_notification_by_page(pr : JSON , completion : completionBlock?)
    func updateMobile(pr : JSON , completion : completionBlock?)
    func infoApp(completion : completionBlock?)
    
}

class NotificationServiceMK : NotificationAPI  {
    
    
    func updateMobile(pr: JSON, completion: completionBlock?) {
        statusReportProvider.request(.updateMobile(pr: pr), completionHandler: completion)
    }
    
    static let shared : NotificationAPI = NotificationServiceMK()
    
    var statusReportProvider  = MoyaProvider<NotificationHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    
    func user_notification_by_page(pr : JSON , completion : completionBlock?) {
        statusReportProvider.request(.user_notification_by_page(pr: pr), completionHandler: completion)
    }
    
    
    func bindPushDevice(device : String, registrationId : String, completion : completionBlock?) {
        statusReportProvider.request(.bindPushDevice(device: device, registrationId: registrationId) , completionHandler: completion)
    }
    
    
    func user_notification_list( fromTime : String , toTime : String, completion : completionBlock?) {
        statusReportProvider.request(.user_notification_list( fromTime: fromTime, toTime: toTime), completionHandler: completion)
    }
    
    
    func user_notification_page(index: Int, size: Int, completion: completionBlock?) {
        statusReportProvider.request(.user_notification_page(index: index, size: size), completionHandler:completion)
    }
    
    func user_notification_page_category(category:String,index: Int, size: Int, completion: completionBlock?) {
        statusReportProvider.request(.user_notification_page_category(category: category, index: index, size: size), completionHandler:completion)
    }
    
    func user_notification_unread_total(fromTime : String , toTime : String, completion : completionBlock?) {
        statusReportProvider.request(.user_notification_unread_total(fromTime: fromTime, toTime: toTime), completionHandler: completion)
    }
    
    func user_notification_info(notificationId  : String , completion : completionBlock?) {
        statusReportProvider.request(.user_notification_info(notificationId: notificationId), completionHandler: completion)
    }
    
    func user_notification_read(notificationId  : String, completion : completionBlock?) {
        statusReportProvider.request(.user_notification_read(notificationId: notificationId), completionHandler: completion)
    }
    
    func infoApp(completion : completionBlock?) {
        statusReportProvider.request(.infoApp, completionHandler: completion)
    }
}
