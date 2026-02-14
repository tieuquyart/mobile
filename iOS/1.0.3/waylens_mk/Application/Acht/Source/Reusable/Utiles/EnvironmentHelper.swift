//
//  EnvironmentHelper.swift
//  Acht
//
//  Created by Chester Shen on 12/4/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
enum AppEnvironment:String {
    case simulator
    case develop
    case adHoc
    case testFlight
    case appStore
    
    var shouldCheckUpdate:Bool {
        return self == .adHoc || self == .develop
    }

    var isSandBox: Bool {
        return self == .develop
    }
}

struct Environment {
    static var isAppStoreReceiptionSandbox: Bool {
        #if IOS_SIMULATOR
            return false
        #else
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt";
        #endif
    }
    static var hasEmbeddedMobileProvision: Bool {
        return Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
    }
    
    static var current: AppEnvironment {
        #if IOS_SIMULATOR
            return .simulator
        #elseif DEBUG
            return .develop
        #else
            if hasEmbeddedMobileProvision {
                return .adHoc
            }
            if isAppStoreReceiptionSandbox {
                return .testFlight
            }
            return .appStore;
        #endif
    }
}
