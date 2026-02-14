//
//  ApplyCameraAdasConfigUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

class ApplyCameraAdasConfigUseCase: UseCase {
    let camera: UnifiedCamera
    let key: AnyKeyPath
    let value: String?

    let actionDispatcher: ActionDispatcher

    public init(camera: UnifiedCamera, key: AnyKeyPath, value: String?, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.key = key
        self.value = value
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        if
           let key = key as? PartialKeyPath<WLAdasConfig>,
           let value = value,
           var adasConfigDict = camera.local?.adasConfig?.toDict()
        {
            let number = NumberFormatter().number(from: value)
            var errorMessage: ErrorMessage? = nil
            
            switch key {
            case \WLAdasConfig.forwardCollisionTTC:
                if let number = number, number.doubleValue >= 0.5 && number.doubleValue <= 5.0 {
                    adasConfigDict[WLAdasConfigKeys.forwardCollisionTTC.rawValue] = number.doubleValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 0.5 ≤ value ≤ 5.0")
                }
            case \WLAdasConfig.forwardCollisionTR:
                if let number = number, number.intValue >= 20 && number.intValue <= 200 {
                    adasConfigDict[WLAdasConfigKeys.forwardCollisionTR.rawValue] = number.intValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 20 ≤ value ≤ 200")
                }
            case \WLAdasConfig.headwayMonitorTTC:
                if let number = number, number.doubleValue >= 0.5 && number.doubleValue <= 5.0 {
                    adasConfigDict[WLAdasConfigKeys.headwayMonitorTTC.rawValue] = number.doubleValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 0.5 ≤ value ≤ 5.0")
                }
            case \WLAdasConfig.headwayMonitorTR:
                if let number = number, number.intValue >= 20 && number.intValue <= 200 {
                    adasConfigDict[WLAdasConfigKeys.headwayMonitorTR.rawValue] = number.intValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 20 ≤ value ≤ 200")
                }
            case \WLAdasConfig.cameraHeight:
                if let number = number, number.doubleValue > 0 && number.doubleValue < 10 {
                    adasConfigDict[WLAdasConfigKeys.cameraHeight.rawValue] = number.doubleValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 0 < value < 10")
                }
            case \WLAdasConfig.vehicleWidth:
                if let number = number, number.doubleValue > 0 && number.doubleValue < 10 {
                    adasConfigDict[WLAdasConfigKeys.vehicleWidth.rawValue] = number.doubleValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "Value Range: 0 < value < 10")
                }
            case \WLAdasConfig.rightOffsetToCenter:
                if let number = number {
                    adasConfigDict[WLAdasConfigKeys.rightOffsetToCenter.rawValue] = number.doubleValue
                }
                else {
                    errorMessage = ErrorMessage(title: NSLocalizedString("Invalid Value", comment: "Invalid Value"), message: "")
                }
            default:
                break
            }

            if let errorMessage = errorMessage {
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: errorMessage))
            }
            else {
                camera.local?.doSetAdasConfig(WLAdasConfig(dict: adasConfigDict))
            }
        }
    }

}

protocol ApplyCameraAdasConfigUseCaseFactory {
    func makeApplyCameraAdasConfigUseCase(key: AnyKeyPath, value: String?) -> UseCase
}
