//
//  EventAPI.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import Moya


protocol EventAPI {
    func video(id : Int , completion : completionBlock?)
  
}


class EventService : EventAPI  {
    
    static let shared : EventAPI = EventService()
    
    var statusReportProvider  = MoyaProvider<EventHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    func video(id: Int, completion: completionBlock?) {
        statusReportProvider.request(.video(id) , completionHandler: completion)
    }

}
