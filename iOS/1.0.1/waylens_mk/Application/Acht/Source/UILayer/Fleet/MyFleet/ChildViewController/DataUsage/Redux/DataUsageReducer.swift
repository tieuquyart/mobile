//
//  DataUsageReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func DataUsageReducer(action: Action, state: DataUsageViewControllerState?) -> DataUsageViewControllerState {
        var state = state ?? DataUsageViewControllerState()

        if state.viewState.activityIndicatingState != .none {
            state.viewState.activityIndicatingState = .none
        }

        switch action {
        case DataUsageActions.loadBillingData(let billingData):
            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }
            state.dataSource = DataUsageDataSource(thisMonthBillingData: billingData, historyBillingDataArray: state.dataSource.historyBillingDataArray)
        case DataUsageActions.loadHistoricalBillingData(let historyBillingDataArray):
            state.dataSource = DataUsageDataSource(thisMonthBillingData: state.dataSource.thisMonthBillingData, historyBillingDataArray: historyBillingDataArray)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as DataUsageFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
