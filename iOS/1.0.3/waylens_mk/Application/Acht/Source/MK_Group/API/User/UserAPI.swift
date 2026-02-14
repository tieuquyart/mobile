//
//  UserAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/5/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya

protocol UserAPI {
    func all_Users(completion : completionBlock?)
    func add_Users( realName : String ,userName : String , completion: completionBlock?)
    func update_Users(id : Int , realName : String ,userName : String , completion: completionBlock?)
    func remove_Users(id : Int , completion: completionBlock?)
    func reset_UserPassword(id : Int , completion: completionBlock?)
}


class UserService : UserAPI  {
   
    
    
    static let shared : UserAPI = UserService()
    
    var statusReportProvider  = MoyaProvider<UserHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func all_Users(completion : completionBlock?) {
        statusReportProvider.request(.all_Users , completionHandler: completion)
    }
    
    func add_Users( realName : String ,userName : String , completion: completionBlock?) {
        statusReportProvider.request(.add_Users(realName: realName, userName: userName), completionHandler: completion)
    }
    
    func update_Users(id : Int , realName : String ,userName : String , completion: completionBlock?) {
        statusReportProvider.request(.update_Users(id: id, realName: realName, userName: userName), completionHandler: completion)
    }

    func remove_Users(id : Int , completion: completionBlock?) {
        statusReportProvider.request(.remove_Users(id: id), completionHandler: completion)
    }
    
    func reset_UserPassword(id : Int , completion: completionBlock?) {
        statusReportProvider.request(.reset_UserPassword(id: id), completionHandler: completion)
    }
}
