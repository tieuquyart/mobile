//
//  PersonnelManagementReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func PersonnelManagementReducer(action: Action, state: PersonnelManagementViewControllerState?) -> PersonnelManagementViewControllerState {
        var state = state ?? PersonnelManagementViewControllerState()

        switch action {
        case PersonnelManagementActions.loadMembers(let members):
            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }
            state.members = members
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case let finishedPresentingErrorAction as PersonnelManagementFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
