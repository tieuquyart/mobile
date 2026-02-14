////
////  PictureHttpRouter.swift
////  Acht
////
////  Created by TranHoangThanh on 1/26/22.
////  Copyright © 2022 waylens. All rights reserved.
////
//
//
//
//
//import Foundation
//import Moya
//
//
//enum PictureHttpRouter {
//    case by_page
//   
//}
//
//
//extension VehicleHttpRouter : TargetType {
//    
//    var sampleData: Data {
//        return Data()
//    }
//    
//    var baseURL: URL {
//        URL(string: UserSetting.shared.server.rawValue)!
//    }
//    
//    var path: String {
//        switch self {
//        case .vehicle_by_page:
//            return "/api/admin/vehicle/page"
//        }
//    }
//    
//    var method: Moya.Method {
//        switch self {
//        case .by_page:
//            return .get
//    
//    
//            
//        }
//        
//    }
//    
//    var task: Moya.Task {
//        switch self {
//        case .by_page:
//            let parameters: [String : Any] = [
//                "current" : 1,
//                "size" : 10,
//            ]
//            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
//        }
//    }
//    
//    
//    
//    var headers: [String : String]? {
//        var headers: [String : String] = [:]
//        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
//        return headers
//    }
//    
//}
//
//
//
//
