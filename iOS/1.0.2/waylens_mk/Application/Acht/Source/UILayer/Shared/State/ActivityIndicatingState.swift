//
//  ActivityIndicatingState.swift
//  Acht
//
//  Created by forkon on 2019/11/10.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

enum ActivityIndicatingState: Equatable {
    case none
    case saving
    case doneSaving
    case removing
    case doneRemoving
    case setting
    case doneSetting
    case updating
    case doneUpdating
    case loading
    case doneLoading
    case binding
    case doneBinding
    case unbinding
    case doneUnbinding
    case activating
    case doneActivating
    case adding
    case doneAdding

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
        case .loading:
            return NSLocalizedString("Loading...", comment: "Loading...")
        case .doneLoading:
            return NSLocalizedString("Loaded successfully!", comment: "Loaded successfully!")
        case .binding:
            return NSLocalizedString("Binding...", comment: "Binding...")
        case .doneBinding:
            return NSLocalizedString("Bound successfully!", comment: "Bound successfully!")
        case .unbinding:
            return NSLocalizedString("Unbinding...", comment: "Unbinding...")
        case .doneUnbinding:
            return NSLocalizedString("Unbound successfully!", comment: "Unbound successfully!")
        case .activating:
            return NSLocalizedString("Activating...", comment: "Activating...")
        case .doneActivating:
            return NSLocalizedString("Activated successfully!", comment: "Activated successfully!")
        case .adding:
            return NSLocalizedString("Adding...", comment: "Adding...")
        case .doneAdding:
            return NSLocalizedString("Added successfully!", comment: "Added successfully!")
        }
    }

    var isSuccess: Bool {
        switch self {
        case .doneSaving, .doneRemoving, .doneSetting, .doneUpdating, .doneBinding, .doneUnbinding, .doneActivating, .doneLoading, .doneAdding:
            return true
        default:
            return false
        }
    }
}
