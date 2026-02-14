//
//  Fleet ViewAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 12/28/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import Foundation
import Moya

protocol FleetViewAPI {
    
    func fleetview_page(completion : completionBlock?)
    func fleetview_page(index: Int32, pageSize: Int32, completion : completionBlock?)
    func events(cameraSn : String , eventGroup : Int32 , startTime : String , endTime : String ,  completion : completionBlock?)
    func eventsOneTrip(tripId : String , completion : completionBlock?)
    func trips(cameraSn : String , searchDate : String , completion : completionBlock?)
    func track(cameraSn : String , tripId : String , completion : completionBlock?)
    func start_live(cameraSn : String , completion : completionBlock?)
    func live_status(cameraSn : String , completion : completionBlock?)
    func upload_status(cameraSn: String, completion: completionBlock?)
    func snapToRoad(param : String , completion: completionBlock?)
}



class FleetViewService : FleetViewAPI {
   
    
    
    
    
    static let shared : FleetViewAPI = FleetViewService()
    var statusReportProvider  = MoyaProvider<FleetViewHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
 //   let date = Date().toString(format: .isoDate)
  //  UserSetting.current.userProfile?.get_role()
    
    func fleetview_page(completion: completionBlock?) {
        
        let model = FleetViewHttpRouterPageHttpModel(searchDate: Date().toString(format: .isoDate), orderRule: 1, pageSize: 10, currentPage: 1)
        statusReportProvider.request(.getPage(model), completionHandler: completion)
    }
    
    func fleetview_page(index: Int32, pageSize: Int32, completion: completionBlock?) {
        
        let model = FleetViewHttpRouterPageHttpModel(searchDate: Date().toString(format: .isoDate), orderRule: 1, pageSize: pageSize, currentPage: index)
        statusReportProvider.request(.getPage(model), completionHandler: completion)
    }
    
    func events(cameraSn : String , eventGroup : Int32  , startTime : String , endTime : String ,  completion : completionBlock?) {
        statusReportProvider.request(.events(cameraSn: cameraSn, eventGroup: eventGroup, searchEndDate: endTime, searchStartDate: startTime), completionHandler: completion)
    }
    
    func trips(cameraSn: String, searchDate: String, completion: completionBlock?) {
        statusReportProvider.request(.trips(cameraSn: cameraSn, searchDate: searchDate), completionHandler: completion)
    }
    
    func track(cameraSn: String, tripId: String, completion: completionBlock?) {
        statusReportProvider.request(.track(cameraSn: cameraSn, tripId: tripId), completionHandler: completion)
    }
    
    func eventsOneTrip(tripId: String, completion: completionBlock?) {
        statusReportProvider.request(.eventsOneTrip(tripId: tripId), completionHandler: completion)
    }
    
    func start_live(cameraSn : String , completion : completionBlock?) {
        statusReportProvider.request(.start_live(cameraSn: cameraSn), completionHandler: completion)
    }
    
    
    func live_status(cameraSn: String, completion: completionBlock?) {
        statusReportProvider.request(.live_status(cameraSn: cameraSn), completionHandler: completion)
    }
    
    func upload_status(cameraSn: String, completion: completionBlock?){
        statusReportProvider.request(.upload_status(cameraSn: cameraSn), completionHandler: completion)
    }
    
    func snapToRoad(param : String , completion: completionBlock?) {
        statusReportProvider.request(.snapToRoad(param: param), completionHandler: completion)
    }
}
