//
//  CalibrationCalibrateReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CalibrationCalibrateReducer(action: Action, state: CalibrationCalibrateViewControllerState?) -> CalibrationCalibrateViewControllerState {
        var state = state ?? CalibrationCalibrateViewControllerState()

        if state.viewState == .triggeredCalibration {
            state.viewState = .doneCalibration
        }

        switch action {
        case CalibrationActions.judgeDmsCameraPosition(let valid):
            switch state.viewState {
            case .ready(_), .triggeredCalibration, .doneCalibration:
                break
            default:
                state.viewState = valid ? .available : .positionInvalid
            }
        case CalibrationActions.calibrateAgain:
            state.viewState = .positionInvalid
        case CountDownActions.tick(let countDown):
            if countDown != 0 {
                state.viewState = .ready(countDown: countDown)
            }
            else {
                state.viewState = .triggeredCalibration
            }
        case ErrorActions.failedToProcess(let errorMessage):
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as CalibrationCalibrateFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
