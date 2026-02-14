//
//  SecureEsNetworkMiFiReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func SecureEsNetworkMiFiReducer(action: Action, state: SecureEsNetworkMiFiViewControllerState?) -> SecureEsNetworkMiFiViewControllerState {
        var state = state ?? SecureEsNetworkMiFiViewControllerState()

    switch action {
//    case SecureEsNetworkMiFiActions:
//    <#code#>
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as SecureEsNetworkMiFiFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
