//
//  GeoFenceRuleTypeAndScopeReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func GeoFenceRuleTypeAndScopeReducer(action: Action, state: GeoFenceRuleTypeAndScopeViewControllerState?) -> GeoFenceRuleTypeAndScopeViewControllerState {
        var state = state ?? GeoFenceRuleTypeAndScopeViewControllerState()

        switch action {
        case AddNewGeoFenceActions.editedGeoFenceRule(let newRule):
            state.rule = newRule
        case SelectorActions.select(let indexPath):
            let element = state.viewState.elements[indexPath.row]

            if element == .scopeAll || element == .scopeSpecific {
                state.viewState.selectedElements.remove(.scopeSpecific)
                state.viewState.selectedElements.remove(.scopeAll)
                state.viewState.selectedElements.insert(element)

                if element == .scopeSpecific {
                    state.rule.scope = .specific
                }
                else if element == .scopeAll {
                    state.rule.scope = .all
                }
            }
            else if element == .typeEnter || element == .typeExit {
                if state.viewState.selectedElements.contains(element) {
                    state.viewState.selectedElements.remove(element)
                }
                else {
                    state.viewState.selectedElements.insert(element)
                }

                if element == .typeEnter {
                    if state.rule.type == nil {
                        state.rule.type = .enter
                    }
                    else {
                        if state.rule.type?.contains(.enter) == true {
                            var typeCopy = state.rule.type
                            typeCopy?.remove(.enter)
                            state.rule.type = typeCopy
                        }
                        else {
                            state.rule.type = state.rule.type?.union(.enter)
                        }
                    }
                }

                if element == .typeExit {
                    if state.rule.type == nil {
                        state.rule.type = .exit
                    }
                    else {
                        if state.rule.type?.contains(.exit) == true {
                            var typeCopy = state.rule.type
                            typeCopy?.remove(.exit)
                            state.rule.type = typeCopy
                        }
                        else {
                            state.rule.type = state.rule.type?.union(.exit)
                        }
                    }
                }
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as GeoFenceRuleTypeAndScopeFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
