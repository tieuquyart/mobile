//
//  WLDmsData.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2020/12/18.
//  Copyright © 2020 Waylens. All rights reserved.
//

import Foundation

@objc
public enum WLDmsDataKeys: Int {
    case resolution,
         driverName,
         isDriverValid,
         isFaceReal,
         hasGlasses,
         hasMask,
         eyesOnRoad,
         headOnRoad,
         isWearingSeatbelt,
         isUsingCellphone,
         isDayDreaming,
         isSmoking,
         isEating,
         isYawning,
         cameraStatus,
         drowsiness,
         distraction,
         headGesture,
         blinkRate,
         blinkDuration,
         fixationLength,
         expression,
         eyeMode,
         gaze,
         isGazeValid,
         headRect,
         rawHeadRect,
         headAngle,
         inputOffset,
         inputResolution,
         srcResolution
}

@objc
public class WLDmsData: NSObject {
    public private(set) var cameraStatus: String? = nil
    public private(set) var driverName: String? = nil
    public private(set) var isDriverValid = false
    public private(set) var isFaceReal: Bool? = nil
    public private(set) var hasGlasses: Bool? = nil
    public private(set) var hasMask: Bool? = nil
    public private(set) var eyesOnRoad: Bool? = nil
    public private(set) var headOnRoad: Bool? = nil
    public private(set) var isWearingSeatbelt: Bool? = nil
    public private(set) var isUsingCellphone: Bool? = nil
    public private(set) var isDayDreaming: Bool? = nil
    public private(set) var isSmoking: Bool? = nil
    public private(set) var isEating: Bool? = nil
    public private(set) var isYawning: Bool? = nil
    public private(set) var drowsiness: String? = nil
    public private(set) var distraction: String? = nil
    public private(set) var headGesture: String? = nil
    public private(set) var blinkDuration: Int? = nil
    public private(set) var blinkRate: Float? = nil
    public private(set) var fixationLength: Int? = nil
    public private(set) var expression: String? = nil
    public private(set) var eyeMode: String? = nil
    public private(set) var gaze: String? = nil

    /// A Boolean value that indicates whether the driver is keeping his eyes on the road.
    public private(set) var isGazeValid: Bool = false
    public private(set) var resolution: CGSize = CGSize.zero
    public private(set) var headRect: CGRect = CGRect.zero
    public private(set) var rawHeadRect: CGRect = CGRect.zero
    public private(set) var headAngle: CGFloat = 0.0
    public private(set) var inputOffset: CGPoint = CGPoint.zero
    public private(set) var inputResolution: CGSize = CGSize.zero
    public private(set) var srcResolution: CGSize = CGSize.zero

    @objc public init(dict: [Int : Any]) {
        super.init()

        self.cameraStatus = dict[WLDmsDataKeys.cameraStatus.rawValue] as? String
        self.driverName = dict[WLDmsDataKeys.driverName.rawValue] as? String
        self.isDriverValid = dict[WLDmsDataKeys.isDriverValid.rawValue] as? Bool ?? false
        self.hasGlasses = dict[WLDmsDataKeys.hasGlasses.rawValue] as? Bool
        self.hasMask = dict[WLDmsDataKeys.hasMask.rawValue] as? Bool
        self.isFaceReal = dict[WLDmsDataKeys.isFaceReal.rawValue] as? Bool
        self.eyesOnRoad = dict[WLDmsDataKeys.eyesOnRoad.rawValue] as? Bool
        self.headOnRoad = dict[WLDmsDataKeys.headOnRoad.rawValue] as? Bool
        self.isWearingSeatbelt = dict[WLDmsDataKeys.isWearingSeatbelt.rawValue] as? Bool
        self.isUsingCellphone = dict[WLDmsDataKeys.isUsingCellphone.rawValue] as? Bool
        self.isDayDreaming = dict[WLDmsDataKeys.isDayDreaming.rawValue] as? Bool
        self.isSmoking = dict[WLDmsDataKeys.isSmoking.rawValue] as? Bool
        self.isEating = dict[WLDmsDataKeys.isEating.rawValue] as? Bool
        self.isYawning = dict[WLDmsDataKeys.isYawning.rawValue] as? Bool
        self.drowsiness = dict[WLDmsDataKeys.drowsiness.rawValue] as? String
        self.distraction = dict[WLDmsDataKeys.distraction.rawValue] as? String
        self.headGesture = dict[WLDmsDataKeys.headGesture.rawValue] as? String
        self.blinkDuration = dict[WLDmsDataKeys.blinkDuration.rawValue] as? Int
        self.blinkRate = dict[WLDmsDataKeys.blinkRate.rawValue] as? Float
        self.fixationLength = dict[WLDmsDataKeys.fixationLength.rawValue] as? Int
        self.expression = dict[WLDmsDataKeys.expression.rawValue] as? String
        self.eyeMode = dict[WLDmsDataKeys.eyeMode.rawValue] as? String
        self.gaze = dict[WLDmsDataKeys.gaze.rawValue] as? String
        self.isGazeValid = dict[WLDmsDataKeys.isGazeValid.rawValue] as? Bool ?? false
        self.resolution = dict[WLDmsDataKeys.resolution.rawValue] as? CGSize ?? CGSize.zero
        self.headRect = dict[WLDmsDataKeys.headRect.rawValue] as? CGRect ?? CGRect.zero
        self.rawHeadRect = dict[WLDmsDataKeys.rawHeadRect.rawValue] as? CGRect ?? CGRect.zero
        self.headAngle = dict[WLDmsDataKeys.headAngle.rawValue] as? CGFloat ?? 0
        self.inputOffset = dict[WLDmsDataKeys.inputOffset.rawValue] as? CGPoint ?? CGPoint.zero
        self.inputResolution = dict[WLDmsDataKeys.inputResolution.rawValue] as? CGSize ?? CGSize.zero
        self.srcResolution = dict[WLDmsDataKeys.srcResolution.rawValue] as? CGSize ?? CGSize.zero
    }

    public func displayItems() -> [Mirror.Child] {
        return Mirror(reflecting: self).children.filter { (child) -> Bool in
            if let label = child.label {
                return ![
                    "isGazeValid",
                    "resolution",
                    "headRect",
                    "rawHeadRect",
                    "headAngle",
                    "inputOffset",
                    "inputResolution",
                    "srcResolution"
                ].contains(label)
            }
            return false
        }
    }

}
