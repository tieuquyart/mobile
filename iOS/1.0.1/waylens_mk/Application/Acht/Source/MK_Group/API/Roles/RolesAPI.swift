//
//  RolesAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/26/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import Foundation
import Moya

struct ParamUserRole: Convertable {
    let selectedRoles: [Int]
    let userId: Int

}


protocol RolesAPI {
    func getAll(completion : completionBlock?)
    func updateUserRole(param : ParamUserRole , completion : completionBlock?)
}


class RolesService : RolesAPI {
   
    
    
    static let shared : RolesService = RolesService()
    
    var statusReportProvider  = MoyaProvider<RolesHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    
    func getAll(completion : completionBlock?) {
        statusReportProvider.request(.get_all, completionHandler: completion)
    }

    func updateUserRole(param : ParamUserRole , completion : completionBlock?) {
        statusReportProvider.request(.updateUserRole(param: param), completionHandler: completion)
    }
    
}


