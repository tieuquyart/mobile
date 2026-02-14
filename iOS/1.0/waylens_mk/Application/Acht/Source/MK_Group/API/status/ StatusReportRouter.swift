//
//  Status_Report_API.swift
//  test_alamofire
//
//  Created by TranHoangThanh on 12/21/21.
//

import Foundation
import Moya




struct StatusReportHttpModel : Codable {
    let startTime: String
    let endTime : String
    let pageSize : Int
    let currentPage : Int
}


enum StatusReportRouter {
    case vehicle_status_report(_ value : StatusReportHttpModel)
    case driver_status_report(_ value : StatusReportHttpModel)
    case one_driver_status_report(_ value : StatusReportHttpModel, driverId : Int)
    case one_vehicle_status_report(_ value : StatusReportHttpModel, plateNo : String)
}

extension StatusReportRouter : TargetType {
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string:  UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .vehicle_status_report:
            return "/api/admin/report/vehicle-status-report"
        case .driver_status_report:
            return "/api/admin/report/driver-status-report"
        case .one_driver_status_report(_ , let driverId):
            return "/api/admin/report/driver-status-report/\(driverId)"
        case .one_vehicle_status_report(_, let plateNo):
            return "/api/admin/report/vehicle-status-report/\(plateNo)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .vehicle_status_report(let value), .driver_status_report(let value), .one_driver_status_report(let value, _),.one_vehicle_status_report(let value, _):
            var params : [String : Any] = [:]
            params["startTime"] = value.startTime
            params["endTime"] = value.endTime
            params["pageSize"] = value.pageSize
            params["currentPage"] = value.currentPage
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
        return headers
    }
    
    
}





extension StatusReportRouter {

    var shouldLogResponse: Bool {
        return true
    }

}
