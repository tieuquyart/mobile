//
//  CameraAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/7/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


protocol CameraAPI {
    func camera_by_page(pr : JSON , completion : completionBlock?)
    func pageInfo(pr : JSON , completion : completionBlock?)
    func camera_list(completion : completionBlock?)
    func delete(id : Int , completion : completionBlock?)
    func edit(id : Int , _param : ParamAddCamera , completion : completionBlock?)
    func register(id : Int , completion : completionBlock?)
    func add(_param : ParamAddCamera , completion : completionBlock?)
    func checkSerial(val : String ,  completion : completionBlock?)
}


class CameraService : CameraAPI  {
    
    
   
    static let shared : CameraService = CameraService()
    var statusReportProvider  = MoyaProvider<CameraHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func camera_by_page(pr : JSON , completion : completionBlock?) {
        statusReportProvider.request(.camera_by_page(pr : pr) , completionHandler: completion)
    }
    
    func camera_list(completion : completionBlock?) {
        statusReportProvider.request(.camera_list, completionHandler: completion)
    }

    func pageInfo(pr : JSON , completion: completionBlock?) {
        statusReportProvider.request(.pageInfo(pr: pr), completionHandler: completion)
    }
    
    func delete( id : Int , completion : completionBlock?) {
        statusReportProvider.request(.delete(id: id), completionHandler: completion)
    }
    
    func add(_param : ParamAddCamera , completion : completionBlock?) {
        statusReportProvider.request(.add(_param: _param), completionHandler: completion)
    }
    
    func register(id : Int , completion : completionBlock?) {
        statusReportProvider.request(.register(id: id) , completionHandler: completion)
    }
    
    func edit(id : Int , _param : ParamAddCamera , completion : completionBlock?) {
        statusReportProvider.request(.edit(id: id, _param: _param) , completionHandler: completion)
    }

    func checkSerial(val: String, completion: completionBlock?) {
        statusReportProvider.request(.checkSerial(val), completionHandler: completion)
    }
    
}


