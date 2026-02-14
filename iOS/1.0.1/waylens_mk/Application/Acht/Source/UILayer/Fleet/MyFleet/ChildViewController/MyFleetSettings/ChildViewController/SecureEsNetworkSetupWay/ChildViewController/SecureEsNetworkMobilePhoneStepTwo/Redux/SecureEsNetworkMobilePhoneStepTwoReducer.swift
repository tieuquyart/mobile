//
//  SecureEsNetworkMobilePhoneStepTwoReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func SecureEsNetworkMobilePhoneStepTwoReducer(action: Action, state: SecureEsNetworkMobilePhoneStepTwoViewControllerState?) -> SecureEsNetworkMobilePhoneStepTwoViewControllerState {
        var state = state ?? SecureEsNetworkMobilePhoneStepTwoViewControllerState()

        switch action {
        //    case SecureEsNetworkMobilePhoneStepTwoActions:
        //    <#code#>
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as SecureEsNetworkMobilePhoneStepTwoFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
