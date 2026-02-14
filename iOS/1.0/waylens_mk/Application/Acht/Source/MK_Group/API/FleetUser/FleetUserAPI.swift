//
//  FleetUserAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 11/29/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


protocol FleetUserAPI {
    func register(_param : ParamRegisterMK , completion : completionBlock?)
    func  createFleet(_param : ParamCreateFleetMK , completion : completionBlock?)
    func  resetPassword(_param :  ParamResetPasswordMK, completion : completionBlock?)
   
}


class FleetUserService : FleetUserAPI  {
    
    
   
    static let shared : FleetUserService = FleetUserService()
   // var statusReportProvider  = MoyaProvider<CameraHttpRouter>()
    var statusReportProvider  = MoyaProvider<FleetUserHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])

    
    func register(_param : ParamRegisterMK , completion : completionBlock?) {
        statusReportProvider.request(.register(_param: _param) , completionHandler: completion)
    }
    func createFleet(_param : ParamCreateFleetMK , completion : completionBlock?) {
        statusReportProvider.request(.createFleet(_param: _param) , completionHandler: completion)
    }
    func  resetPassword(_param :  ParamResetPasswordMK, completion : completionBlock?) {
        statusReportProvider.request(.resetPassword(_param: _param) , completionHandler: completion)
    }
    
  
    
}


