//
//  AddNewGeoFenceReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func AddNewGeoFenceReducer(action: Action, state: AddNewGeoFenceViewControllerState?) -> AddNewGeoFenceViewControllerState {
        var state = state ?? AddNewGeoFenceViewControllerState()

        switch action {
        case AddNewGeoFenceActions.editedGeoFenceRule(let newRule):
            state.rule = newRule
        case SelectorActions.select(let indexPath):
            let element = state.viewState.elements[indexPath.row]

            if element == .typeCircular || element == .typePolygonal || element == .typeReused {
                state.viewState.selectedElement = element
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as AddNewGeoFenceFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
