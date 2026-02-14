//
//  NotificationHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 2/24/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
 
enum NotificationHttpRouter {
    case bindPushDevice(device : String, registrationId : String)
    case user_notification_list(fromTime : String , toTime : String)
    case user_notification_page(index : Int , size : Int)
    case user_notification_page_category(category: String, index : Int , size : Int)
    case user_notification_unread_total(fromTime : String , toTime : String)
    case user_notification_info(notificationId  : String)
    case user_notification_read(notificationId  : String)
    case user_notification_by_page(pr : JSON)
    case updateMobile(pr : JSON)
    case infoApp
}


extension NotificationHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .bindPushDevice:
            return "/api/sessions/bindPushDevice"
        case .user_notification_list:
            return "/api/admin/user-notification/list"
        case .user_notification_page:
            return "/api/admin/user-notification/page"
        case .user_notification_page_category(let category, _, _):
            return "/api/admin/user-notification/page/\(category)"
        case .user_notification_unread_total:
            return "/api/admin/user-notification/unread-total"
        case .user_notification_info(let id):
            return "/api/admin/user-notification/info/\(id)"
        case .user_notification_read(let id):
            return "/api/admin/user-notification/read/\(id)"
        case .user_notification_by_page:
            return "api/admin/notification/page"
        case .updateMobile(pr: _):
            return "api/admin/camera/updateMobile"
        case .infoApp:
            return "api/admin/user-notification/infoApp/ios"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .user_notification_list,.user_notification_unread_total,.user_notification_info,.infoApp,.user_notification_page, .user_notification_page_category:
            return .get
        default:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .user_notification_list, .user_notification_info,.user_notification_read,.infoApp:
            return .requestPlain
        case .user_notification_by_page(let pr):
            
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)
        case .bindPushDevice(let deviceType , let registrationId):
            let params: [String : Any] = [
                "deviceType" : deviceType,
                "registrationId" : registrationId,
                
            ]
            return .requestCompositeParameters(
                bodyParameters: params,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .user_notification_page(let index, let size):
            let params: [String : Any] = [
                "page" : index,
                "size" : size,
            ]
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .user_notification_page_category(_, let index, let size):
            let pr:[String : Any] = [
                "page" : index,
                "size": size
            ]
            
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)

        case .user_notification_unread_total(let fromTime, let toTime):
            let params: [String : Any] = [:
//                "fromTime" : fromTime,
//                "toTime" : toTime,
                
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .updateMobile(pr: let pr):
            return .requestCompositeParameters(
                bodyParameters: pr,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
                

        }
        
    }
    
    var headers: [String : String]? {
        switch self {
        case .infoApp :
            return nil
        default:
            var headers: [String : String] = [:]
            headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
            return headers
            
        }
        
    }
    
}
