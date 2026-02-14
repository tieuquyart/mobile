//
//  JudgeDmsCameraPositionUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

fileprivate var gazeHistory: [Int8] = []

class JudgeDmsCameraPositionUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let dmsData: WLDmsData?
    private let driverHeadPositionJudger: DriverHeadPositionJudger
    private let needsValidGaze: Bool

    public init(
        dmsData: WLDmsData?,
        needsValidGaze: Bool = true,
        driverHeadPositionJudger: DriverHeadPositionJudger = DriverHeadPositionJudgerImpl(),
        actionDispatcher: ActionDispatcher
    ) {
        self.dmsData = dmsData
        self.needsValidGaze = needsValidGaze
        self.driverHeadPositionJudger = driverHeadPositionJudger
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        guard let dmsData = dmsData else {
            actionDispatcher.dispatch(CalibrationActions.judgeDmsCameraPosition(valid: false))
            return
        }

        if dmsData.isDriverValid {
            var isGazeValid: Bool

            if needsValidGaze {
                gazeHistory.insert(dmsData.isGazeValid == true ? 1 : 0, at: 0)

                if gazeHistory.count > 15 {
                    _ = gazeHistory.popLast()
                }

                isGazeValid = (gazeHistory.reduce(0, +) > gazeHistory.count / 2) // Solve the frequent blinking problem.
            }
            else {
                isGazeValid = true
            }

            if isGazeValid {
                let isValid = driverHeadPositionJudger.judge(headRect: dmsData.headRect, pictureSize: dmsData.resolution)
                actionDispatcher.dispatch(CalibrationActions.judgeDmsCameraPosition(valid: isValid))
            }
            else {
                actionDispatcher.dispatch(CalibrationActions.judgeDmsCameraPosition(valid: false))
            }
        }
        else {
            actionDispatcher.dispatch(CalibrationActions.judgeDmsCameraPosition(valid: false))
        }
    }

}

protocol JudgeDmsCameraPositionUseCaseFactory {
    func makeJudgeCameraPositionUseCase(dmsData: WLDmsData?) -> UseCase
}

public protocol DriverHeadPositionJudger {
    func judge(headRect: CGRect, pictureSize: CGSize) -> Bool
}

extension DriverHeadPositionJudger {

    public func judge(headRect: CGRect, pictureSize: CGSize) -> Bool {
        let headHeightRatio = headRect.height / pictureSize.height
        let headCenter = CGPoint(x: headRect.midX, y: headRect.midY)

        /*
        print("====== pictureSize: \(pictureSize)")
        print("====== headRect: \(headRect)")
        print("====== headHeightRatio: 0.2 <= \(headHeightRatio) <= 0.5")
        print("====== headCenter.x: \(pictureSize.width * 0.33) <= \(headCenter.x) <= \(pictureSize.width * 0.67)")
        print("====== headCGRect.minY: \(headRect.minY) >= \(pictureSize.height * 0.1)")
        print("====== headCGRect.maxY: \(headRect.maxY) <= \(pictureSize.height * 0.75)")
        */

        if (headHeightRatio >= 0.2 && headHeightRatio <= 0.5) &&
            ((headCenter.x >= (pictureSize.width * 0.33)) && (headCenter.x <= (pictureSize.width * 0.67))) &&
            (headRect.minY >= (pictureSize.height * 0.1)) &&
            (headRect.maxY <= (pictureSize.height * 0.75))
        {
            return true
        }
        else {
            return false
        }
    }

}

private class DriverHeadPositionJudgerImpl: DriverHeadPositionJudger {}
