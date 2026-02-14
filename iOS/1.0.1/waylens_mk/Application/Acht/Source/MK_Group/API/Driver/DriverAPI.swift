//
//  DriverAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/7/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya

///
protocol DriverAPI {
    func list_driver(completion : completionBlock?)
    func driver_by_page(pr : JSON , completion : completionBlock?)
    func add_driver(_param: ParamDriver , completion: completionBlock?)
    func modify( id : Int , _param : ParamDriver , completion : completionBlock?)
    func delete( id : Int , completion : completionBlock?)
    
}


class DriverService : DriverAPI  {
  

    
    static let shared : DriverService = DriverService()
    
    var statusReportProvider  = MoyaProvider<DriverHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func list_driver(completion : completionBlock?) {
        statusReportProvider.request(.list, completionHandler: completion)
    }
    
    func driver_by_page(pr : JSON , completion : completionBlock?) {
        statusReportProvider.request(.driver_by_page(pr : pr) , completionHandler: completion)
    }
    
    func add_driver(_param: ParamDriver , completion: completionBlock?) {
        statusReportProvider.request(.add_driver(_param: _param), completionHandler: completion)
    }
    
    func modify(id : Int , _param: ParamDriver, completion: completionBlock?) {
        statusReportProvider.request(.modify_driver(id: id, _param: _param), completionHandler: completion)
    }
    
    func delete( id : Int , completion : completionBlock?) {
        statusReportProvider.request(.delete(id: id), completionHandler: completion)
    }
    
}



