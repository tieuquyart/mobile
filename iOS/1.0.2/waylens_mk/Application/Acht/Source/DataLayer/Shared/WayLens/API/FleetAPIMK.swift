//
//  FleetAPINew.swift
//  Acht
//
//  Created by TranHoangThanh on 12/9/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import Moya
import WaylensFoundation


enum FleetAPIMK {
case loginNew(email: String, password: String)
case getListUser
}


extension FleetAPIMK: TargetType {
    var baseURL: URL {
        return URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .loginNew:
            return "/api/sessions/login"
        case .getListUser:
            return "/api/admin/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loginNew,.getListUser:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Moya.Task {
        
        //let encoding = URLEncoding.default  //JSONEncoding.default

        switch self {
        case .loginNew(let email, let password):
            let parameters: [String : Any] = [
                "username" : email,
                "password" : password,
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .getListUser:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]

        switch self {
        case .loginNew:
            break
        default:
            if let token = AccountControlManager.shared.keyChainMgr.token {
                headers["Authorization"] = "Bearer \(token)"
            }
        }

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let userAgent = "FleetApp/\(version)/\(build);\(deviceModelName());\(UIDevice.current.systemName + UIDevice.current.systemVersion);\(UIDevice.current.name)"
        headers["User-Agent"] = userAgent

        return headers
    }
}



extension FleetAPIMK {

    var shouldLogResponse: Bool {
        #if DEBUG
        return true
        #else
        switch self {
        case .loginNew:
    
            return false
        default:
            return true
        }
        #endif
    }

}
