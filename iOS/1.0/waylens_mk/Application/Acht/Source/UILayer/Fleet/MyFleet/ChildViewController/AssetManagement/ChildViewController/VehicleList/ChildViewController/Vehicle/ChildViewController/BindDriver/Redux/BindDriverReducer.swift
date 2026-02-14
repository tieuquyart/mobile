//
//  BindDriverReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func BindDriverReducer(action: Action, state: BindDriverViewControllerState?) -> BindDriverViewControllerState {
        var state = state ?? BindDriverViewControllerState()

    switch action {
    case PersonnelManagementActions.loadMembers(let members):
        var items = members.filter{$0.roles.contains(.driver) && !$0.isBind}

        // use to unbind
        if let driverID = state.vehicleProfile?.driverID {
            var driverBound: FleetMember? = members.first(where: {$0.driverID == driverID})
            driverBound?.name = NSLocalizedString("Set as Idle", comment: "Set as Idle")

            if let driverBound = driverBound {
                items.insert(driverBound, at: 0)
            }
        }

        if !state.hasFinishedFirstLoading {
            state.hasFinishedFirstLoading = true
        }
        state.dataSource = BindDriverDataSource(items: items)
    case SelectorActions.select(let indexPath):
        state.dataSource = BindDriverDataSource(items: state.dataSource.provider.items.first ?? [], selectedIndexPath: indexPath)
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as BindDriverFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
