//
//  VehicleHttpRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation

//struct ParamDriver : Convertable {
//    let birthDate: String
//    let drivingYears: Int
//    let employeeId: String
//    let gender: Int
//    let idNumber: String
//    let license: String
//    let licenseType: String
//    let name: String
//    let phoneNo: String
//}

import Foundation
import Moya
import SwiftyJSON

let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    
}

enum VehicleHttpRouter {
    case vehicle_by_page(pr : JSON)
    case getVehicleByCamera(id : Int)
    case add_vehicle(_param : ParamVehicle)
    case modify_vehicle(id : Int , _param : ParamVehicle)
    case excelVehicle(_param : ParamExcel)
    case excelDrivingTime(_param : ParamExcelDrivingTime)
    case excelVehicleSpeed(_param : ParamExcel)
    case excelStopVehicle(_param : ParamExcel)
    case delete( id : Int)
    case changeCamera(id : Int , cameraId : Int)
    case assignOneDriver(id : Int , driverId : Int)
    case listVehicle

    
}


extension VehicleHttpRouter : TargetType {
    
    
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        URL(string: UserSetting.shared.server.rawValue)!
    }
    
    var path: String {
        switch self {
        case .getVehicleByCamera(let id):
            return "/api/admin/vehicle/getVehicleByCameraId/\(id)"
        case .vehicle_by_page( _):
            return "/api/admin/vehicle/page"
        case .add_vehicle:
            return "/api/admin/vehicle"
        case  .modify_vehicle(let id , _):
            return "/api/admin/vehicle/\(id)"
        case .delete(id: let id):
            return "/api/admin/vehicle/\(id)"
        case .changeCamera(id: let id ,  _):
            return "/api/admin/vehicle/associated-camera/\(id)"
        case .assignOneDriver(id: let id ,  _):
            return "/api/admin/vehicle/assign-driver/\(id)"
        case .listVehicle:
            return "/api/admin/vehicle/list"
        case .excelVehicle:
            return "/api/admin/excel/vehicleFleet"
        case .excelDrivingTime:
            return "/api/admin/excel/drivingTime"
        case .excelVehicleSpeed:
            return "/api/admin/excel/vehicleSpeed"
        case .excelStopVehicle:
            return "api/admin/excel/stopVehicle"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .vehicle_by_page , .getVehicleByCamera , .listVehicle:
            return .get
        case .add_vehicle,.changeCamera,.assignOneDriver,.excelVehicle,.excelDrivingTime,.excelVehicleSpeed,.excelStopVehicle:
            return .post
        case  .modify_vehicle:
            return .put
        case .delete:
            return .delete
        }
        
    }
    
    var task: Moya.Task {
        switch self {
        
            
        case .vehicle_by_page(let pr):
//            let parameters: [String : Any] = [
//                "current" : 1,
//                "size" : 10,
//            ]
            return .requestParameters(parameters: pr, encoding: URLEncoding.queryString)
            
           case .add_vehicle(_param: let _param):
             let parameters = _param.convertToDict()
             return .requestCompositeParameters(
                 bodyParameters: parameters,
                 bodyEncoding: JSONEncoding.default,
                 urlParameters: [:]
             )
        case .modify_vehicle(id: _, _param: let _param):
            let parameters = _param.convertToDict()
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .changeCamera(_, let cameraId):
            
            let parameters: [String : Any] = [
                "cameraId": cameraId
            ]
            
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
            
        case .assignOneDriver(_,let  driverId):
            let parameters: [String : Any] = [
                "driverId": driverId
            ]
            
            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .delete :
            return .requestPlain
        case .getVehicleByCamera(id: _), .listVehicle:
            return .requestPlain
        case .excelVehicle(_param: let _param):
            let parameters = _param.convertToDict()
         //   URLEncoding.queryString
            return .downloadParameters(parameters: parameters, encoding: URLEncoding.httpBody, destination: DefaultDownloadDestination)
        case .excelDrivingTime(_param: let _param):
            let parameters = _param.convertToDict()
         //   URLEncoding.queryString
            return .downloadParameters(parameters: parameters, encoding: URLEncoding.httpBody, destination: DefaultDownloadDestination)
        case .excelVehicleSpeed(_param: let _param):
            let parameters = _param.convertToDict()
         //   URLEncoding.queryString
            return .downloadParameters(parameters: parameters, encoding: URLEncoding.httpBody, destination: DefaultDownloadDestination)
        case .excelStopVehicle(_param: let _param):
            let parameters = _param.convertToDict()
         //   URLEncoding.queryString
            return .downloadParameters(parameters: parameters, encoding: URLEncoding.httpBody, destination: DefaultDownloadDestination)
        }
    }
    
    
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
        return headers
    }
    
}




