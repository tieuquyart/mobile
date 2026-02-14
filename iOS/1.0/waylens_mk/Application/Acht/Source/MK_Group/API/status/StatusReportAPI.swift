//
//  StatusReportAPI.swift
//  test_alamofire
//
//  Created by TranHoangThanh on 12/17/21.
//

import Foundation
import Moya
enum ReportStatus {
    case driver
    case vehicle
}



typealias JSON = Dictionary<String, Any>
typealias JSON_Cloruse = (JSON) -> (Void)

protocol StatusReportAPI {
    func status_report(status : ReportStatus , startTime: String, endTime: String , completion : completionBlock?)
    func one_driver_status_report(driver : Int, startTime: String, endTime: String , completion : completionBlock?)
    func one_vehicle_status_report(plateNo : String, startTime: String, endTime: String , completion : completionBlock?)
}



class StatusReport_Service : StatusReportAPI {
    
    
    static let shared : StatusReport_Service = StatusReport_Service()
    //let statusReportProvider = MoyaProvider<StatusReportRouter>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])
    var statusReportProvider  = MoyaProvider<StatusReportRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    //let statusReportProvider = MoyaProvider<StatusReportRouter>()
    
    func one_driver_status_report(driver : Int, startTime: String, endTime: String , completion : completionBlock?) {
        statusReportProvider.request(.one_driver_status_report(StatusReportHttpModel(startTime: startTime, endTime: endTime, pageSize: 10, currentPage: 1), driverId: driver), completionHandler: completion)
        
    }
    
    func one_vehicle_status_report(plateNo : String, startTime: String, endTime: String , completion : completionBlock?) {
        statusReportProvider.request(.one_vehicle_status_report(StatusReportHttpModel(startTime: startTime, endTime: endTime, pageSize: 10, currentPage: 1), plateNo: plateNo), completionHandler: completion)
    }
    
    func status_report(status : ReportStatus , startTime: String, endTime: String , completion : completionBlock?) {
        if status == .vehicle {
            statusReportProvider.request(.vehicle_status_report(StatusReportHttpModel(startTime: startTime, endTime: endTime, pageSize: 10, currentPage: 1)), completionHandler: completion)
        } else {
            statusReportProvider.request(.driver_status_report(StatusReportHttpModel(startTime: startTime, endTime: endTime, pageSize: 10, currentPage: 1)), completionHandler: completion)
        }
    
    }
}
