//
//  SecureEsNetworkMobilePhoneStepThreeReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func SecureEsNetworkMobilePhoneStepThreeReducer(action: Action, state: SecureEsNetworkMobilePhoneStepThreeViewControllerState?) -> SecureEsNetworkMobilePhoneStepThreeViewControllerState {
        var state = state ?? SecureEsNetworkMobilePhoneStepThreeViewControllerState()

    switch action {
//    case SecureEsNetworkMobilePhoneStepThreeActions:
//    <#code#>
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as SecureEsNetworkMobilePhoneStepThreeFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
