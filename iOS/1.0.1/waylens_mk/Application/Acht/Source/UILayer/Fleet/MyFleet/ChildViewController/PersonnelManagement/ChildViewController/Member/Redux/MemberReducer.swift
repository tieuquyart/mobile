//
//  MemberReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func MemberReducer(action: Action, state: MemberViewControllerState?) -> MemberViewControllerState {
        var state = state ?? MemberViewControllerState(memberProfile: MemberProfile(name: "", roles: .driver, email: nil, phoneNumber: nil), scene: .viewing(isEditing: false))

        if state.viewState.activityIndicatingState.isSuccess {
            state.viewState.activityIndicatingState = .none
        }

        switch action {
        case MemberActions.loadMemberProfile:
            break
        case ProfileActions.composingProfileInfo(let newInfo):
            switch newInfo {
            case .name(let value):
                state.memberProfile.set_Name(value)
            case .role(let value):
                state.memberProfile.roles = value
            case .email(let value):
                state.memberProfile.email = value
            case .user_name(let value):
                state.memberProfile.set_userName(value)
            case .phoneNumber(let value):
                state.memberProfile.phoneNumber = value
            default:
                break
            }
        case MemberActions.beginEditingMemberProfile:
            state.viewState.isEditing = true
        case MemberActions.doneEditingMemberProfile:
            state.viewState.isEditing = false
        case MemberActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case MemberActions.transferFleet:
            var userProfile = UserSetting.current.userProfile
            userProfile?.isOwner = false
            UserSetting.current.userProfile = userProfile
        case let finishedPresentingErrorAction as MemberFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        default:
            break
        }

        return state
    }

}
