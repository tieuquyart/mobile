//
//  WLAdasConfig.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2021/8/5.
//

public enum WLAuxConfigKeys: String {
    case model = "model"
    case angle = "angle"
    case plug = "plug"
}

@objc
public enum WLAuxAngle: Int, CustomStringConvertible, CaseIterable {
    case normal = 0
    case degrees90 = 1
    case degrees180 = 2
    case degrees270 = 3
    
    public var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .degrees90:
            return "90°"
        case .degrees180:
            return "180°"
        case .degrees270:
            return "270°"
        }
    }
}

@objc
public enum WLAuxModel: Int, CustomStringConvertible {
    case na = 0
    case ecm02 = 1
    case ecm01 = 2
    
    public var description: String {
        switch self {
        case .na:
            return "NA"
        case .ecm01:
            return "DMS"
        case .ecm02:
            return "AUX"
        }
    }
}

@objc
public enum WLAuxPlug: Int {
    case na = 0
    case ecm02 = 1
    case ecm01 = 2
    
    public var description: String {
        switch self {
        case .na:
            return "NA"
        case .ecm01:
            return "DMS"
        case .ecm02:
            return "AUX"
        }
    }
}

@objc
public class WLAuxConfig: NSObject {
    @objc public let model: WLAuxModel
    @objc public let angle: WLAuxAngle
    @objc public let plug: WLAuxPlug
    
    @objc public init(dict: [String : Any]) {
        self.model = WLAuxModel(rawValue: dict[WLAuxConfigKeys.model.rawValue] as? Int ?? 0) ?? .na
        self.angle = WLAuxAngle(rawValue: dict[WLAuxConfigKeys.angle.rawValue] as? Int ?? 0) ?? .normal
        self.plug = WLAuxPlug(rawValue: dict[WLAuxConfigKeys.plug.rawValue] as? Int ?? 0) ?? .na

        super.init()
    }
    
    @objc public func toDict() -> [String : Any] {
        return [
            WLAuxConfigKeys.model.rawValue : model.rawValue,
            WLAuxConfigKeys.angle.rawValue : angle.rawValue,
            WLAuxConfigKeys.plug.rawValue : plug.rawValue,
        ]
    }
}
