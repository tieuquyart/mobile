//
//  VehicleAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


struct ParamExcelDetailPicture: Convertable {
    
    let start_time : String
    let end_time : String
    let fleet_id : String
    
    
}


struct ParamExcelDrivingTime : Convertable {
    
    let continuous : Bool
    let fleet_id : String
    let start_time : String
    let end_time : String
    
}


struct ParamExcelList : Convertable {
    
    let list_plate_no : [String]
    let fleet_id : String
    let start_time : String
    let end_time : String
    
}

struct ParamExcel : Convertable {
    
    let plate_no : String
    let fleet_id : String
    let start_time : String
    let end_time : String
    
}

struct ParamDriverExcel : Convertable {
    
    let driver_id : [Int]
    let fleet_id : String
    let start_time : String
    let end_time : String
    
}


struct ParamVehicle : Convertable {
    let brand: String
  //  let capacity: String
    let plateNo: String?
    let type: String
    let vehicleNo: String?
    
    init(brand : String , plateNo : String ,type : String , vehicleNo : String) {
        self.brand = brand
      //  self.capacity = capacity
        self.type = type
        self.plateNo = plateNo
        self.vehicleNo = vehicleNo
    }
    
    init(brand : String ,type : String) {
        self.brand = brand
      //  self.capacity = capacity
        self.type = type
        self.plateNo = nil
        self.vehicleNo = nil
    }
    
}


protocol VehicleAPI {
    func excelVehicle(param : ParamExcel , completion : completionBlock?)
    func listVehicle(completion : completionBlock?)
    func vehicle_by_page(param : JSON , completion : completionBlock?)
    func getVehicleByCamera(id : Int , completion : completionBlock?)
    func add_vehicle(_param : ParamVehicle , completion : completionBlock?)
    func modify_vehicle( id : Int , _param : ParamVehicle , completion : completionBlock?)
    func delete( id : Int , completion : completionBlock?)
    func changeCamera(id : Int ,cameraId : Int , completion : completionBlock?)
    func assignOneDriver(id : Int , driverId : Int , completion : completionBlock?)
}


class VehicleService : VehicleAPI  {
    
   

    static let shared : VehicleService = VehicleService()
    
    var statusReportProvider  = MoyaProvider<VehicleHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func vehicle_by_page(param : JSON , completion : completionBlock?) {
        statusReportProvider.request(.vehicle_by_page(pr : param), completionHandler: completion)
    }
    func getVehicleByCamera(id : Int , completion : completionBlock?) {
        statusReportProvider.request(.getVehicleByCamera(id: id), completionHandler: completion)
    }
    func add_vehicle(_param: ParamVehicle , completion : completionBlock?) {
        statusReportProvider.request(.add_vehicle(_param: _param), completionHandler: completion)
    }
    
    func modify_vehicle( id : Int , _param: ParamVehicle, completion: completionBlock?) {
        statusReportProvider.request(.modify_vehicle(id: id, _param: _param), completionHandler: completion)
    }
    
    func excelVehicle(param : ParamExcel , completion : completionBlock?) {
        statusReportProvider.request(.excelVehicle(_param: param), completionHandler: completion)
    }
    
    
    func delete( id : Int , completion : completionBlock?) {
        statusReportProvider.request(.delete(id: id), completionHandler: completion)
    }
    
    func changeCamera(id : Int ,cameraId : Int , completion : completionBlock?) {
        statusReportProvider.request(.changeCamera(id: id, cameraId: cameraId), completionHandler: completion)
    }
    
    func assignOneDriver(id : Int , driverId : Int , completion : completionBlock?) {
        statusReportProvider.request(.assignOneDriver(id: id, driverId: driverId), completionHandler: completion)
    }
    
    
    func listVehicle(completion: completionBlock?) {
        statusReportProvider.request(.listVehicle, completionHandler: completion)
    }
    
}



