//
//  AddNewGeoFenceViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct AddNewGeoFenceViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRuleForEdit
    public private(set) var ruleBeforeEdit: GeoFenceRuleForEdit? = nil
    public internal(set) var fence: GeoFence? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: AddNewGeoFenceViewState

    public init(rule: GeoFenceRuleForEdit? = nil, fence: GeoFence? = nil) {
        if let rule = rule {
            self.rule = rule
        }
        else {
            self.rule = GeoFenceRuleForEdit()
        }

        self.ruleBeforeEdit = self.rule

        self.fence = fence

        viewState = AddNewGeoFenceViewState(activityIndicatingState: .none)

        switch fence?.shape {
        case .some(.circle):
            viewState.selectedElement = .typeCircular
        case .some(.polygon):
            viewState.selectedElement = .typePolygonal
        default:
            break
        }
    }
}

public struct AddNewGeoFenceViewState: Equatable {
    public enum Element: Int, CaseIterable {
        case name
        case seperator
        case type
        case typeCircular
        case typePolygonal
        case typeReused

        var title: String? {
            switch self {
            case .name:
                return NSLocalizedString("Name", comment: "Name")
            case .seperator:
                return nil
            case .type:
                return NSLocalizedString("Type", comment: "Type")
            case .typeCircular:
                return NSLocalizedString("Circular", comment: "Circular")
            case .typePolygonal:
                return NSLocalizedString("Polygonal", comment: "Polygonal")
            case .typeReused:
                return NSLocalizedString("Reused", comment: "Reused")
            }
        }

        var detail: String? {
            switch self {
            case .typeCircular:
                return NSLocalizedString("On the next page, you need to do the following steps to build your geo-fenceing area.\n\n1. Select the central point on the map.\n2. Fill in the range of the geo-fencing area.", comment: "On the next page, you need to do the following steps to build your geo-fenceing area.\n\n1. Select the central point on the map.\n2. Fill in the range of the geo-fencing area.")
            case .typePolygonal:
                return NSLocalizedString("On the next page, you need to do the following steps to build your geo-fence area.\n\n1 Tap on the map to get a start point.\n2 Build the area by adding more point on the map.\n3 Tap \"Done\" to Confirm the zone.", comment: "On the next page, you need to do the following steps to build your geo-fence area.\n\n1 Tap on the map to get a start point.\n2 Build the area by adding more point on the map.\n3 Tap \"Done\" to Confirm the zone.")
            case .typeReused:
                return NSLocalizedString("On the next page, you need to select a existing graph to build your geo-fence area.", comment: "On the next page, you need to select a existing graph to build your geo-fence area.")
            default:
                return nil
            }
        }
    }

    var elements: [Element] = Element.allCases
    var selectedElement: Element? = nil
    var activityIndicatingState: ActivityIndicatingState
}
