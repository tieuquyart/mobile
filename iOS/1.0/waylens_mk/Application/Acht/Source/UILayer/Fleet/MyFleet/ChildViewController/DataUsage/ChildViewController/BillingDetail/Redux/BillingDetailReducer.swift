//
//  BillingDetailReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func BillingDetailReducer(action: Action, state: BillingDetailViewControllerState?) -> BillingDetailViewControllerState {
        var state = state ?? BillingDetailViewControllerState()

    switch action {
//    case BillingDetailActions.loadBillingData(let billingDataArray):
//        state.dataSource = BillingDetailDataSource(thisMonthBillingData: state.dataSource.thisMonthBillingData, historyBillingDataArray: billingDataArray)
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as BillingDetailFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
