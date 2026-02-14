//
//  DriverHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/7/22.
//  Copyright © 2022 waylens. All rights reserved.
//



struct ParamDriver : Convertable {

    let birthDate: String?
    let drivingYears: String
    let employeeId: String
    let gender: Int
    let idNumber: String
    let license: String
    let licenseType: String
    let name: String
    let phoneNo: String

    func getGender() -> String {
        if gender == 0 {
            return "Nữ"
        } else {
            return "Nam"
        }
    }
    
    func getTimeDrivingYear() -> String {
        let drivingYearsArr : [String] = drivingYears.components(separatedBy: "T")
        return drivingYearsArr[0]
    }
    
    func getTimeBirthDateYear() -> String {
        let birthDates : [String] = birthDate?.components(separatedBy: "T") ?? []
        return birthDates[0]
    }
    
//    let nameDriver : String
//    let idNumber : String
//    let phoneNumber : String
//    let employeeId : String
//    let driverLicense : String
//    let licenseType : String
//    let drivingYears : String
    
}

import Foundation
import Moya


enum DriverHttpRouter {
    case driver_by_page(pr : JSON)
    case add_driver(_param : ParamDriver)
    case delete( id : Int)
    case modify_driver(id : Int , _param : ParamDriver)
    case list
    
}


extension DriverHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .list :
            return "/api/admin/driver/list"
        case .driver_by_page( _):
            return "/api/admin/driver/page"
        case .add_driver:
            return "/api/admin/driver"
        case .delete(id: let id):
            return "/api/admin/driver/\(id)"
        case .modify_driver(id: let id ,  _):
            return "/api/admin/driver/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .driver_by_page,.list:
            return .get
        case .add_driver:
            return.post
        case .delete:
            return .delete
        case .modify_driver:
            return .put
        }
        
    }
    
    var task: Moya.Task {
        switch self {
        case .driver_by_page(let pr):
            
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)
        case .delete :
            return .requestPlain
        case .modify_driver(id: _, _param: let _param):
            let parameters = _param.convertToDict()
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .add_driver(_param: let _param):
            let parameters = _param.convertToDict()
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .list:
            return .requestPlain
        }
    }
    
    
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
        return headers
    }
    
}

