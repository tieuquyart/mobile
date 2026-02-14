//
//  EventHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya

enum EventHttpRouter {
    case video(_ id : Int)
}


extension EventHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .video(let id):
            return "/api/admin/events/video/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
      //  headers["x-access-token"] = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0aGFuaF9tb2JpbGUiLCJpYXQiOjE2NDEyNjc2Nzh9.9aAAPz0HdeZX0LKJYUeqf8z29KIej5IeMsGPriHw9fY"
        
        return headers
    }
    
}
