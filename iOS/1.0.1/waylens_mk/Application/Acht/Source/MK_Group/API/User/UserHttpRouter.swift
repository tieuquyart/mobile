//
//  UserHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/5/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


enum UserHttpRouter {
    case all_Users
    case add_Users(realName : String , userName : String)
    case update_Users(id : Int , realName : String , userName : String)
    case remove_Users(id : Int)
    case reset_UserPassword(id : Int)
}


extension UserHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .all_Users,.add_Users:
            return "/api/admin/users"
        case .update_Users(id: let id,_,_),.remove_Users(id: let id):
            return "/api/admin/users/\(id)"
        case .reset_UserPassword(id: let id):
            return "/api/admin/users/\(id)/passwordreset"
            
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .all_Users:
            return .get
        case .add_Users, .reset_UserPassword:
            return .post
        case .update_Users:
            return .put
        case .remove_Users:
            return .delete
        
        }
        
    }
    
    var task: Moya.Task {
        switch self {
        case .all_Users,.remove_Users,.reset_UserPassword:
            return .requestPlain
        case .add_Users(let realName , let userName):
            let parameters: [String : Any] = [
                "realName" : realName,
                "userName" : userName,
                
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
            
        case .update_Users( _ , let realName , let userName):
            let parameters: [String : Any] = [
                "realName" : realName,
                "userName" : userName,
                
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
      
        }
      
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
      //  headers["x-access-token"] = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0aGFuaF9tb2JpbGUiLCJpYXQiOjE2NDEyNjc2Nzh9.9aAAPz0HdeZX0LKJYUeqf8z29KIej5IeMsGPriHw9fY"
        
        return headers
    }
    
}
