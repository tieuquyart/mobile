//
//  LoginHttpRouter.swift
//  test_alamofire
//
//  Created by TranHoangThanh on 12/17/21.
//



import Moya


enum SessionHttpRouter {
    case login(name: String, password: String)
    case logout
    case changePassword(newPassword : String , oldPassword : String)
}

extension SessionHttpRouter : TargetType {
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string:  UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/sessions/login"
        case .logout:
            return "/api/sessions/logout"
        case .changePassword:
            return "/api/sessions/passwordchange"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login,.logout, .changePassword:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let name , let  password):
            let parameters: [String : Any] = [
                "username" : name,
                "password" : password,
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .changePassword(let newPassword, let oldPassword):
            let parameters: [String : Any] = [
                "newPassword" : newPassword,
                "oldPassword" : oldPassword,
                
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .logout:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login:
            return nil
        case .logout,.changePassword:
            var headers: [String : String] = [:]
            headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
            return headers
        }
    }
    
    
}




