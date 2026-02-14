//
//  RolesHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/26/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import Foundation
import Moya


enum RolesHttpRouter  {
    case get_all
    case updateUserRole(param : ParamUserRole)
}


extension RolesHttpRouter : TargetType {

    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }

    var path: String {
        switch self {
        case .get_all:
            return "/api/admin/roles"
        case .updateUserRole(param: let param):
            return "/api/admin/userroles/\(param.userId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .get_all:
            return .get
        case .updateUserRole(param: _):
            return .put
        }

    }

    var task: Moya.Task {
        switch self {
        case .get_all:
            return .requestPlain
        case .updateUserRole(param: let _param):
            let parameters = _param.convertToDict()
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
        return headers
    }

}




