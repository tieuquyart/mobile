//
//  GeoFenceRuleTypeAndScopeViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct GeoFenceRuleTypeAndScopeViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRuleForEdit
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceRuleTypeAndScopeViewState = GeoFenceRuleTypeAndScopeViewState(activityIndicatingState: .none)

    public init(rule: GeoFenceRuleForEdit = GeoFenceRuleForEdit(), enableTypeChoices: Bool = true) {
        self.rule = rule

        if self.rule.scope == .all {
            viewState.selectedElements.insert(.scopeAll)
        }

        if self.rule.scope == .specific {
            viewState.selectedElements.insert(.scopeSpecific)
        }

        if self.rule.type?.contains(.enter) == true {
            viewState.selectedElements.insert(.typeEnter)
        }

        if self.rule.type?.contains(.exit) == true {
            viewState.selectedElements.insert(.typeExit)
        }

        viewState.enableTypeChoices = enableTypeChoices
    }
}

public struct GeoFenceRuleTypeAndScopeViewState: Equatable {
    enum Element: Int, CaseIterable {
        case typeTitle
        case typeEnter
        case typeExit
        case seperator
        case scopeTitle
        case scopeSpecific
        case scopeAll

        var title: String? {
            switch self {
            case .typeTitle:
                return NSLocalizedString("How will the vehicles trigger the geo-fence?", comment: "How will the vehicles trigger the geo-fence?")
            case .typeEnter:
                return NSLocalizedString("Enter", comment: "Enter")
            case .typeExit:
                return NSLocalizedString("Exit", comment: "Exit")
            case .seperator:
                return nil
            case .scopeTitle:
                return NSLocalizedString("Which vehicles will trigger the geo-fence?", comment: "Which vehicles will trigger the geo-fence?")
            case .scopeSpecific:
                return NSLocalizedString("Specific vehicles", comment: "Specific vehicles")
            case .scopeAll:
                return NSLocalizedString("All vehicles in the fleet", comment: "All vehicles in the fleet")
            }
        }

        var detail: String? {
            switch self {
            case .scopeAll:
                return NSLocalizedString("All vehicles in the fleet are included, including vehicles added to the fleet later.", comment: "All vehicles in the fleet are included, including vehicles added to the fleet later.")
            default:
                return nil
            }
        }
    }

    private(set) var elements: [Element] = Element.allCases
    var selectedElements: Set<Element> = []
    var enableTypeChoices: Bool = true {
        didSet {
            if enableTypeChoices {
                self.elements = Element.allCases
            }
            else {
                self.elements = [.scopeTitle, .scopeSpecific, .scopeAll]
            }
        }
    }
    var activityIndicatingState: ActivityIndicatingState
}
