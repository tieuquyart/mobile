//
//  GeoFenceDrawingViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import MapKit

public struct GeoFenceDrawingViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRuleForEdit
    public var isEditable = false
    public var shape: GeoFenceShapeForEdit?
    public var centralLocation: NamedLocation? = nil

    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceDrawingViewState = GeoFenceDrawingViewState(activityIndicatingState: .none)

    public init(isEditable: Bool = true, rule: GeoFenceRuleForEdit = GeoFenceRuleForEdit(), fenceShape: GeoFenceShapeForEdit? = nil) {
        self.isEditable = isEditable
        self.rule = rule
        shape = fenceShape
    }
}

public struct GeoFenceDrawingViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
