//
//  FleetViewRouter.swift
//  Acht
//
//  Created by TranHoangThanh on 12/28/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import Foundation
import Moya


struct FleetViewHttpRouterPageHttpModel : Codable {
    let searchDate : String
    let orderRule : Int32
    let pageSize : Int32
    let currentPage : Int32
}


struct FleetViewHttpRouterEventsHttpModel : Codable {
    let cameraSn  : String
    let eventGroup : Int32
    let searchStartDate : String
    let searchEndDate : String
}

enum FleetViewHttpRouter {
    case getPage(_ param : FleetViewHttpRouterPageHttpModel)
    case events(cameraSn : String , eventGroup : Int32 , searchEndDate : String , searchStartDate  : String)
    case eventsOneTrip(tripId : String)
    case trips(cameraSn : String , searchDate : String)
    case track(cameraSn : String , tripId : String)
    case start_live(cameraSn : String)
    case live_status(cameraSn : String)
    case upload_status(cameraSn: String)
    case snapToRoad(param : String)
}

extension FleetViewHttpRouter : TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        
        switch self {
        case .snapToRoad:
           
          return  URL(string: "https://roads.googleapis.com/v1/snapToRoads")!
        default:
           return URL(string:  UserSetting.shared.server.rawValue)!
        }
       
    }
    
    var path: String {
        switch self {
      
        
        case .getPage:
            return "/api/admin/fleet-view/page"
        case .events(let cameraSn,_,_,_):
            return "/api/admin/fleet-view/\(cameraSn)/events"
        case .trips(let cameraSn , _):
            return "/api/admin/fleet-view/\(cameraSn)/trips"
        case .track(let cameraSn, let tripId):
            return "/api/admin/fleet-view/\(cameraSn)/\(tripId)/track"
        case .eventsOneTrip(let tripId):
            return "/api/admin/fleet-view/trip/\(tripId)/events"
        case .start_live(cameraSn: let cameraSn):
            return "/api/admin/fleet-view/\(cameraSn)/start-live"
        case .live_status(cameraSn: let cameraSn):
            return "/api/admin/fleet-view/\(cameraSn)/live-status"
        case .upload_status(cameraSn: let cameraSn):
            return "/api/admin/fleet-view/\(cameraSn)/live/upload-status"
        case .snapToRoad(param: let param):
          //  ?interpolate=true&key=%s&path=%s
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getPage(let value):
            var params : [String : Any] = [:]
            params["orderRule"] = value.orderRule
            params["pageSize"] = value.pageSize
            params["currentPage"] = value.currentPage
            params["searchDate"] = value.searchDate
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .events(_ , _, let searchEndDate , let searchStartDate):
            var params : [String : Any] = [:]
          //  params["eventGroup"] = eventGroup
            params["searchStartDate"] = searchStartDate
            params["searchEndDate"] = searchEndDate
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .trips(_, let searchDate):
            var params : [String : Any] = [:]
            params["searchDate"] = searchDate
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .track,.eventsOneTrip:
            return .requestPlain
        case .start_live(cameraSn: _), .live_status, .upload_status:
            return .requestPlain
        case .snapToRoad(let param):
            var params : [String : Any] = [:]
            params["path"] = param
            params["interpolate"] = true
            params["key"] = "AIzaSyBYarY6_L9Oy_hO1bjSkbeW1Ss5VTj_PR4"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .snapToRoad(_):
            return nil
        default:
            var headers: [String : String] = [:]
            headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
            return headers
        }
        
    }
    
}
