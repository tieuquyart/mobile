//
//  MixpanelHelper.swift
//  Acht
//
//  Created by Chester Shen on 1/29/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation

let useMixpanel = false
let useMSAppCenter = true

#if useMixpanel
import Mixpanel
#endif
#if useMSAppCenter
import AppCenter
import AppCenterAnalytics
#endif

extension Dictionary where Key == String, Value == Any {
    #if useMixpanel
    func toMixpanelProperties() -> Properties {
        let dict = self
        if let prop = dict as? Properties {
            return prop
        }
        var prop = [String: MixpanelType]()
        for (key, value) in dict {
            if let v = value as? String {
                prop[key] = v
            } else if let v = value as? Int {
                prop[key] = v
            } else if let v = value as? Bool {
                prop[key] = v
            }
        }
        return prop
    }
    #endif
    #if useMSAppCenter
    func toMSAppCenterProperties() -> Dictionary<String, String> {
        let dict = self
        if let prop = dict as? Dictionary<String, String> {
            return prop
        }
        var prop = [String: String]()
        for (key, value) in dict {
            if let v = value as? String {
                prop[key] = v
            } else {
                prop[key] = "\(v)"
            }
        }
        return prop
    }
    #endif
}

class MixpanelHelper {

    static func track(event: String?) {
        #if useMixpanel
        MixpanelHelper.track(event: event)
        #endif
        #if useMSAppCenter
        MSAnalytics.trackEvent(event)
        #endif
    }

    static func track(event: String?, properties: Dictionary<String, Any>?) {
        #if useMixpanel
        MixpanelHelper.track(event: event, properties: properties->toMixpanelProperties())
        #endif
        #if useMSAppCenter
        MSAnalytics.trackEvent(event, withProperties: properties->toMSAppCenterProperties())
        #endif
    }

    static func track(event: String?, properties: Dictionary<String, Any>? = nil, camera: UnifiedCamera?) {
        var prop:Dictionary<String, Any>! = properties
        if prop == nil {
            prop = Dictionary<String, Any>()
        }
        if let camera = camera {
            prop["camera_supports_4g"] = camera.supports4g
            prop["camera_4g_online"] = camera.remote?.isOnline
            prop["camera_wifi_online"] = camera.viaWiFi
            prop["camera_firmware"] = camera.firmwareShort
            prop["camera_model"] = camera.model
            prop["camera_mount_code"] = camera.mountCode
            prop["camera_mount_model"] = camera.mountHwModel
            prop["camera_mount_firmware"] = camera.mountFwVersion
        }
        #if useMixpanel
        MixpanelHelper.track(event: event, properties: prop->toMixpanelProperties())
        #endif
        #if useMSAppCenter
        MSAnalytics.trackEvent(event, withProperties: prop->toMSAppCenterProperties())
        #endif
    }
}
