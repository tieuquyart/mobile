//
//  WLAdasConfig.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2021/8/5.
//

public enum WLAdasConfigKeys: String {
    case isEnabled = "enable"
    case forwardCollisionTTC = "fcw"
    case forwardCollisionTR = "fcwr"
    case headwayMonitorTTC = "hdw"
    case headwayMonitorTR = "hdwr"
    case cameraHeight = "cht"
    case vehicleWidth = "vwt"
    case rightOffsetToCenter = "rtc"
}

@objc
public class WLAdasConfig: NSObject {
    @objc public let isEnabled: Bool
    @objc public let forwardCollisionTTC: Double
    @objc public let forwardCollisionTR: Int
    @objc public let headwayMonitorTTC: Double
    @objc public let headwayMonitorTR: Int
    @objc public let cameraHeight: Double
    @objc public let vehicleWidth: Double
    @objc public let rightOffsetToCenter: NSNumber?

    @objc public init(dict: [String : Any]) {
        self.isEnabled = dict[WLAdasConfigKeys.isEnabled.rawValue] as? Bool ?? false
        self.forwardCollisionTTC = dict[WLAdasConfigKeys.forwardCollisionTTC.rawValue] as? Double ?? 0
        self.forwardCollisionTR = dict[WLAdasConfigKeys.forwardCollisionTR.rawValue] as? Int ?? 0
        self.headwayMonitorTTC = dict[WLAdasConfigKeys.headwayMonitorTTC.rawValue] as? Double ?? 0
        self.headwayMonitorTR = dict[WLAdasConfigKeys.headwayMonitorTR.rawValue] as? Int ?? 0
        self.cameraHeight = dict[WLAdasConfigKeys.cameraHeight.rawValue] as? Double ?? 0
        self.vehicleWidth = dict[WLAdasConfigKeys.vehicleWidth.rawValue] as? Double ?? 0
        self.rightOffsetToCenter = dict[WLAdasConfigKeys.rightOffsetToCenter.rawValue] as? NSNumber

        super.init()
    }
    
    @objc public func toDict() -> [String : Any] {
        var result: [String : Any] = [
            WLAdasConfigKeys.isEnabled.rawValue : isEnabled,
            WLAdasConfigKeys.forwardCollisionTTC.rawValue : forwardCollisionTTC,
            WLAdasConfigKeys.forwardCollisionTR.rawValue : forwardCollisionTR,
            WLAdasConfigKeys.headwayMonitorTTC.rawValue : headwayMonitorTTC,
            WLAdasConfigKeys.headwayMonitorTR.rawValue : headwayMonitorTR,
            WLAdasConfigKeys.cameraHeight.rawValue : cameraHeight,
            WLAdasConfigKeys.vehicleWidth.rawValue : vehicleWidth,
        ]
        
        if let rightOffsetToCenter = rightOffsetToCenter?.doubleValue {
            result[WLAdasConfigKeys.rightOffsetToCenter.rawValue] = rightOffsetToCenter
        }
        
        return result
    }
}
