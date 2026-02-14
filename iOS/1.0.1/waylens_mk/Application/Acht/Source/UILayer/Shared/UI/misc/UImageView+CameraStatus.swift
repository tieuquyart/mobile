//
//  UImageView+CameraStatus.swift
//  Acht
//
//  Created by Chester Shen on 9/5/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation

extension UIImageView {
    func updateBattery(batteryStatus: HNBatteryStatus?, showLevel: Bool=true, charging: Bool=false, white: Bool=false) {
        if let batteryLevel = batteryStatus?.rawValue, batteryLevel > 0 || batteryStatus == .unknown && charging {
            self.isHidden = false
            let name = "icon_\(charging ? "charging" : "battery")\(white ? "_white" : "")\(showLevel && batteryLevel > 0 ? "_\(batteryLevel)" : "")"
            self.image = UIImage(named: name)
        } else {
            self.isHidden = true
        }
    }
    
    func updateSignal(signalStatus: HNSignalStatus?, white: Bool=false) {
        if let status = signalStatus {
            self.isHidden = false
            if status == .no_signal {
                self.image = UIImage(named: "no_signal")
            } else {
                let signalLevel = status.rawValue
                self.image = UIImage(named: "\(white ? "icon_4g_w_": "icon_4g_")\(signalLevel)")
            }
        } else {
            self.isHidden = true
        }
    }
    
    func setSignalImage(signalStatus: HNSignalStatus?) {
        if let signalLevel = signalStatus?.rawValue, signalStatus != .no_signal {
            image = UIImage(named: "icon_4g_signal_\(signalLevel)")
        } else if signalStatus == .no_signal {
            image = UIImage(named: "no_signal")
        } else {
            image = nil
        }
    }
    
    func updateMode(mode: HNCameraMode?) {
        if mode == .parking {
            image = UIImage(named: "icon_parked")
            isHidden = false
        } else if mode == .driving {
            image = UIImage(named: "icon_driving")
            isHidden = false
        } else {
            isHidden = true
        }
    }
    
    func updateGPS(gpsStatus: HNGPSStatus?) {
        if gpsStatus == .searching {
            isHidden = false

            animationImages = [UIImage(named: "icon_gps_1")!, UIImage(named: "icon_gps_2")!, UIImage(named: "icon_gps_3")!, UIImage(named: "icon_gps_2")!]
            animationDuration = 1

            startAnimating()
        } else if gpsStatus == .on {
            stopAnimating()
            image = UIImage(named: "icon_gps_3")
            isHidden = false
        } else {
            image = nil
            isHidden = true
        }
    }
}
