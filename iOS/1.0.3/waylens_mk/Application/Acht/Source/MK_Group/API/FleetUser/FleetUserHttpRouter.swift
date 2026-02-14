//
//  FleetUserHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 11/29/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


struct ParamResetPasswordMK: Convertable {
    let email: String
    let mobile: String
    let userName:String
}

struct ParamRegisterMK: Convertable {
    let email: String
    let fleetId: String
    let fleetName: String
    let id: String
    let mobile: String
    let password:String
    let realName:String
    let userName:String
}

struct ParamCreateFleetMK: Convertable {
    let contactEmail: String
    let contactMobile:String
    let contactName: String
    let fleetId: String
    let id:String
    let name:String
}



enum FleetUserHttpRouter {
    case resetPassword(_param :  ParamResetPasswordMK)
    case register(_param : ParamRegisterMK)
    case createFleet(_param : ParamCreateFleetMK)
}

extension FleetUserHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string:  UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .resetPassword:
            return "/api/admin/fleet-user/resetpassword"
        case .register:
            return "/api/admin/fleet-user/register"
        case .createFleet:
            return "/api/admin/fleet/createFleet"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        switch self {
        case .createFleet(_param: let _param):
          let parameters = _param.convertToDict()
          return .requestCompositeParameters(
              bodyParameters: parameters,
              bodyEncoding: JSONEncoding.default,
              urlParameters: [:]
          )
        case .register(_param: let _param) :
          let parameters = _param.convertToDict()
          return .requestCompositeParameters(
              bodyParameters: parameters,
              bodyEncoding: JSONEncoding.default,
              urlParameters: [:]
          )
            
        case .resetPassword(_param: let _param) :
          let parameters = _param.convertToDict()
          return .requestCompositeParameters(
              bodyParameters: parameters,
              bodyEncoding: JSONEncoding.default,
              urlParameters: [:]
          )
        }
    }
    
    var headers: [String : String]? {
           return nil
//        var headers: [String : String] = [:]
//        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
//
//
//        return headers
    }
    
}
