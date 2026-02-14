//
//  CalibrationCalibrateViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct CalibrationCalibrateViewControllerState: ReSwift.StateType, Equatable {
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: CalibrationCalibrateViewState = .positionInvalid

    public init() {

    }
}

public enum CalibrationCalibrateViewState: Equatable {
    case available
    case positionInvalid
    case ready(countDown: Int)
    case triggeredCalibration
    case doneCalibration
}
