//
//  MemberViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct MemberViewControllerState: ReSwift.StateType, Equatable {
    public var memberProfile: MemberProfile
    public var scene: MemberViewControllerScene
    public var viewState: MemberViewState
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []

    init(memberProfile: MemberProfile, scene: MemberViewControllerScene) {
        self.memberProfile = memberProfile
        self.scene = scene

        switch scene {
        case .addingNew:
            viewState = MemberViewState(isEditing: true, activityIndicatingState: .none)
        case .viewing(let isEditing):
            viewState = MemberViewState(isEditing: isEditing, activityIndicatingState: .none)
        }
    }
}

public enum MemberViewControllerScene: Equatable {
    case addingNew
    case viewing(isEditing: Bool)

    public static func == (lhs: MemberViewControllerScene, rhs: MemberViewControllerScene) -> Bool {
        switch (lhs, rhs) {
        case (.addingNew, .addingNew):
            return true
        case (.viewing(let left), .viewing(let right)):
            return left == right
        default:
            return false
        }
    }
}

public struct MemberViewState: Equatable {
    var isEditing: Bool
    var activityIndicatingState: ActivityIndicatingState//MemberViewStateActivityIndicatingState

    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
        return (lhs.isEditing == rhs.isEditing) && (lhs.activityIndicatingState == rhs.activityIndicatingState)
    }
}

enum MemberViewStateActivityIndicatingState: Equatable {
    case none
    case saving
    case doneSaving
    case removing
    case doneRemoving
    case setting
    case doneSetting
    case updating
    case doneUpdating

    var message: String {
        switch self {
        case .none:
            return ""
        case .saving:
            return NSLocalizedString("Saving...", comment: "Saving...")
        case .doneSaving:
            return NSLocalizedString("Saved successfully!", comment: "Saved successfully!")
        case .removing:
            return NSLocalizedString("Removing...", comment: "Removing...")
        case .doneRemoving:
            return NSLocalizedString("Removed successfully!", comment: "Removed successfully!")
        case .setting:
            return NSLocalizedString("Setting...", comment: "Setting...")
        case .doneSetting:
            return NSLocalizedString("Setted successfully!", comment: "Setted successfully!")
        case .updating:
            return NSLocalizedString("Updating...", comment: "Updating...")
        case .doneUpdating:
            return NSLocalizedString("Updated successfully!", comment: "Updated successfully!")
        }
    }

    var isSuccess: Bool {
        switch self {
        case .doneSaving, .doneRemoving, .doneSetting, .doneUpdating:
            return true
        default:
            return false
        }
    }
}
