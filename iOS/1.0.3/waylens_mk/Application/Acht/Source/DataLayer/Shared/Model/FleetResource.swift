//
//  FleetResource.swift
//  Fleet
//
//  Created by forkon on 2019/10/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FleetResource {

    enum Image {
        enum MyFleetIcon: String {
            case dataUsage = "data usage"
            case personnelManagement = "personnel management"
            case assetManagement = "asset management"
            case geoFencingManagement = "geofencing"
            case album = "album"
            case settings = "Profile_setting"
            case connectCameraWiFi = "wifi"
            case shop = "Profile_shop"

            var image: UIImage? {
                return UIImage(named: self.rawValue)
            }
        }

        static var goDetailButton: UIImage? {
            return UIImage(named: "detail")
        }

        static var goLiveButton: UIImage? {
            return UIImage(named: "go live")
        }

        static var closeButton: UIImage? {
            return UIImage(named: "close_black")
        }

        static var dropDownArrow: UIImage? {
            return UIImage(named: "down_blue")
        }

        static var rightArrowGray: UIImage? {
            return UIImage(named: "next_grey")
        }

        static var rightArrowBlue: UIImage? {
            return UIImage(named: "next_blue")
        }

        static func icon15x15(for vehicleState: Vehicle.State) -> UIImage? {
            switch vehicleState {
            case .parking:
                return UIImage(named: "parking_small")
            case .driving:
                return UIImage(named: "driving_small")
            case .offline:
                return UIImage(named: "offline_small")
            }
        }

        static func iconNoShadow29x29(for eventType: EventType) -> UIImage? {
            switch eventType {
            case .parkingMotion:
                return UIImage(named: "parking_big")
            case .parkingHit:
                return UIImage(named: "Bump_big")
            case .drivingHit:
                return UIImage(named: "Bump_big")
            case .parkingHeavy:
                return UIImage(named: "Impact_big")
            case .drivingHeavy:
                return UIImage(named: "Impact_big")
            case .hardAccel, .harshAccel, .severeAccel, .forwardCollisionWarning:
                return UIImage(named: "Hard accel_big")
            case .hardBrake, .harshBrake, .severeBrake:
                return UIImage(named: "Hard brake_big")
            case .sharpTurn, .harshTurn, .severeTurn:
                return UIImage(named: "Sharp turn_big")
            default:
                return UIImage(named: "parking_big")
            }
            // Thiếu vượt quá tốc độ
        }

        static func icon(for geoFenceRuleTypes: GeoFenceRuleTypes) -> UIImage? {
            if geoFenceRuleTypes.contains(.enter) && geoFenceRuleTypes.contains(.exit) {
                return #imageLiteral(resourceName: "Enter&Exit")
            }
            else if geoFenceRuleTypes.contains(.enter) {
                return #imageLiteral(resourceName: "Enter")
            }
            else if geoFenceRuleTypes.contains(.exit) {
                return #imageLiteral(resourceName: "Exit")
            }
            else {
                return nil
            }
        }

    }

}
