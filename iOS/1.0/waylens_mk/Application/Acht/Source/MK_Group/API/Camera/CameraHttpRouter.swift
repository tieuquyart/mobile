//
//  CameraHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/7/22.
//  Copyright © 2022 waylens. All rights reserved.
//




import Foundation
import Moya


struct ParamAddCamera: Convertable {
    let sn: String
    let password: String
  //  let cameraType: String
    let phone: String
    let installationDate: String
}

enum CameraHttpRouter {
    case checkSerial(_ val : String)
    case camera_by_page(pr : JSON)
    case camera_list
    case pageInfo(pr : JSON)
    case delete( id : Int)
    case register(id : Int)
    case edit(id : Int , _param : ParamAddCamera)
    case add(_param : ParamAddCamera)
}


extension CameraHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .checkSerial(_):
            return "/api/admin/camera/checkserial"
        case .add:
            return "/api/admin/camera"
        case .camera_by_page:
            return "/api/admin/camera/list"
        case .camera_list:
            return "/api/admin/camera/list"
        case .pageInfo( _):
            return "/api/admin/camera/pageInfo"
        case .delete(id: let id) , .edit(id: let id ,  _):
            return "/api/admin/camera/\(id)"
        case .register(id: let id):
            return "/api/admin/camera/register/\(id)"

        }
    }
    
    var method: Moya.Method {
        switch self {
        case .add, .register , .checkSerial:
            return .post
        case .pageInfo, .camera_by_page,.camera_list:
            return .get
        case .delete:
            return .delete
        case .edit:
            return .put
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .checkSerial(let serial):
            let parameters: [String : Any] = [
                "serial" : serial,
            ]
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .pageInfo(let pr):
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)
        case .camera_by_page(let pr):
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)
        case .camera_list:
            return .requestPlain
        case .add(_param: let _param) , .edit(id: _, _param: let _param):
          let parameters = _param.convertToDict()
          return .requestCompositeParameters(
              bodyParameters: parameters,
              bodyEncoding: JSONEncoding.default,
              urlParameters: [:]
          )
        case .delete , .register :
            return .requestPlain
        }
      
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
  
        
        return headers
    }
    
}

