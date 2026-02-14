//
//  IOS13SSIDHelper.swift
//  Acht
//
//  Created by forkon on 2019/9/6.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensFoundation
import WaylensUIKit

class IOS13SSIDHelper: NSObject, CLLocationManagerDelegate {
    typealias GetCurrentSSIDHandler = ((String?) -> Void)

    struct RequestPermissionCondition {
        var isPermissionAllowed: Bool
        var lastRequestLocationPermissionDate: Date?
        var timeIntervalSinceLastRequest: TimeInterval

        var isSatisfied: Bool {
            if isPermissionAllowed {
                return false
            } else {
                if let lastRequestLocationPermissionDate = lastRequestLocationPermissionDate, Date().timeIntervalSince(lastRequestLocationPermissionDate) < timeIntervalSinceLastRequest {
                    return false
                }
            }

            return true
        }
    }

    let permission = LocationPermission()
    var conditionForRequestPermission: RequestPermissionCondition

    override init() {
        conditionForRequestPermission = RequestPermissionCondition(
            isPermissionAllowed: permission.isAllowed,
            lastRequestLocationPermissionDate: UserSetting.shared.lastRequestLocationPermissionDate,
            timeIntervalSinceLastRequest: 7.days
        )

        super.init()
    }

    func requestPermissionIfNeeded(with response: LocationPermission.PermissionBlock? = nil) {
        if conditionForRequestPermission.isSatisfied {
            requestPermission(with: response)
        }
    }

    func requestPermission(with response: LocationPermission.PermissionBlock? = nil) {
        UserSetting.shared.lastRequestLocationPermissionDate = Date()
        conditionForRequestPermission.lastRequestLocationPermissionDate = UserSetting.shared.lastRequestLocationPermissionDate

        permission.request { (allowed) in
            response?(allowed)

            if !allowed {
                UIApplication.shared.keyWindow?.rootViewController?.alertJumpingToSystemSettingsMessage(String(format: NSLocalizedString("Please enable Location Services for the xxx App from your phone Settings and Privacy menu to ensure the best experience.", comment: "Please enable Location Services for the %@ App from your phone Settings and Privacy menu to ensure the best experience."), sharedApplication.wl.displayName))
            }
        }
    }

    func requestPermissionAndGetCurrentSSID(with response: @escaping GetCurrentSSIDHandler) {
        requestPermission { (allowed) in
            if allowed {
                response(SSID.currentSSID())
            } else {
                response(nil)
            }
        }
    }
}

private extension CLAuthorizationStatus {

    var isAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }

}

class LocationPermission: NSObject, CLLocationManagerDelegate {
    typealias PermissionBlock = (_ allowed: Bool) -> Void

    private var locationManager = CLLocationManager()
    private var permissionBlock: PermissionBlock? = nil

    fileprivate var isNotDetermined: Bool {
        return CLLocationManager.authorizationStatus() == .notDetermined
    }

    var isAllowed: Bool {
        return CLLocationManager.authorizationStatus().isAuthorized
    }

    func request(with response: PermissionBlock?) {
        if isNotDetermined {
            self.permissionBlock = response

            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else {
            response?(isAllowed)
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            permissionBlock?(status.isAuthorized)
            permissionBlock = nil
        }
    }

}
