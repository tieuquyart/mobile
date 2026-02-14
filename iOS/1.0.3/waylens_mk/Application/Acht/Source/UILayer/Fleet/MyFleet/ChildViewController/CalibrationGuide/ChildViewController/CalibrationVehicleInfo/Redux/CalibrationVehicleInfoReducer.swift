//
//  CalibrationVehicleInfoReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CalibrationVehicleInfoReducer(action: Action, state: CalibrationVehicleInfoViewControllerState?) -> CalibrationVehicleInfoViewControllerState {
        var state = state ?? CalibrationVehicleInfoViewControllerState()

    switch action {
//    case CalibrationVehicleInfoActions:
//    <#code#>
    case SelectorActions.select(let indexPath):
        let element = state.viewState.elements[indexPath.row]

        if element == .left || element == .right {
            state.viewState.selectedElements.remove(.left)
            state.viewState.selectedElements.remove(.right)
            state.viewState.selectedElements.insert(element)
        }
        else if element == .truck || element == .carOrSmallSuv || element == .largeSuvOrPickup {
            state.viewState.selectedElements.remove(.truck)
            state.viewState.selectedElements.remove(.carOrSmallSuv)
            state.viewState.selectedElements.remove(.largeSuvOrPickup)
            state.viewState.selectedElements.insert(element)
        }
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as CalibrationVehicleInfoFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
