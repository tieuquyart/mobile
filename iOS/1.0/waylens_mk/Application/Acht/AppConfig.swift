//
//  AppConfig.swift
//  Fleet
//
//  Created by forkon on 2020/7/21.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

enum AppConfig {
    enum AccessKeys {
        #if FLEET
        static let appCenterSecret: String = "93355fd3-6eff-4d80-b7c2-c5887f1fb736"
        static let wowzaLicenseKey: String = "GOSK-0847-010C-6EF2-8819-C057"
//        static let mixpanelToken: String = "af0cd530d22169f9a451dfc885c20dd5"
//        static let mixpanelTokenForAppStore: String = "af0cd530d22169f9a451dfc885c20dd5"
//        static let firAppID: String = "5d23148bf94548110a51a2e0"
//        static let hockeyAppIDForLive: String = "93355fd36eff4d80b7c2c5887f1fb736"
//        static let hockeyAppIDForBeta: String = "63cdcc2b54eb4a41aeb7317d59819ac8"
        #else
        static let appCenterSecret: String = "adfa3b02-4bab-40e6-95b6-d7a542d9bd49"
        static let wowzaLicenseKey: String = "GOSK-0847-010C-4A40-6059-B937"
//        static let mixpanelToken: String = "7be9f2a4f489f557795137e0a0e8c380"
//        static let mixpanelTokenForAppStore: String = "3e5357d0b4fa8c007562896801423004"
//        static let firAppID: String = "57d91f1e959d69683c000264"
//        static let hockeyAppIDForLive: String = "547b66f1a8b24e5cb024471954303366"
//        static let hockeyAppIDForBeta: String = "adfa3b024bab40e695b6d7a542d9bd49"
        #endif

    }

    enum Server: String, CaseIterable {
        #if FLEET
        //case production = "https://fleetbackendv2.waylens.com"
         // case production = "http://fms.mk.com.vn:8888"
//        case production = "http://fms02.mkvision.com:31190"
        case production = "http://fms.mkvision.com"
//        case production = "https://fms.mkvision.com"
          //case production = "http://new.fms.eveus.com"
        
  
           //    https://fleet-api.waylens.com/api/v2/fleet
        //    https://fleet-api.waylens.com/api/v2
    
        //case dev = "https://fleet-api.waylens.com"
        case dev = "http://dev.fleetbackend.waylens.com:8500"
        #else
        case china = "http://horn.vidit.com.cn"
        case shanghai = "https://tscastle.cam2cloud.com:9002"
        case us_test = "https://wstest.waylens.com/360"
        case us_public = "https://ws.waylens.com/360"
        
    //    case us_public = "https://fms-core.fleet.autosecure360.com"
        #endif
    }

    enum CameraServer: String, CaseIterable {
        #if FLEET
        case production = "wss://fleet.waylens.com/api/4g/"
        case dev = "ws://dev.fleet.waylens.com:9000/api/4g/"
        case api = "wss://fleet-api.waylens.com/api/4g/"
        #else
        case china = "wss://horn.vidit.com.cn/api/4g/"
        case shanghai = "wss://tscastle.cam2cloud.com:9002/api/4g/"
        case us_public = "wss://ws.waylens.com/360/api/4g/"
        case us_test = "wss://wstest.waylens.com/360/api/4g/"
        #endif
    }
}

