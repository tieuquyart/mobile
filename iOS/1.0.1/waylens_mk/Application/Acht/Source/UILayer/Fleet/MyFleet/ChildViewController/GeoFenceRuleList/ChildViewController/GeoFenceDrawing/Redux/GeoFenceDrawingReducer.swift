//
//  GeoFenceDrawingReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func GeoFenceDrawingReducer(action: Action, state: GeoFenceDrawingViewControllerState?) -> GeoFenceDrawingViewControllerState {
        var state = state ?? GeoFenceDrawingViewControllerState()

        if state.centralLocation != nil {
            state.centralLocation = nil
        }

        switch action {
        case GeoFenceDrawingActions.composeGeoFence(let composedData):
            if let shape = state.shape {
                if case .polygon(let points) = shape, let ps = points, ps.count >= 500 {
                    let errorMessage = ErrorMessage(title: NSLocalizedString("More points are not supported to be added.", comment: "More points are not supported to be added."), message: "")
                    state.errorsToPresent.insert(errorMessage)
                }
                else {
                    state.shape = GeoFenceShapeReducer(shape: shape, composedData: composedData)
                }
            }
        case GeoFenceDrawingActions.cleanGeoFence:
            if let shape = state.shape {
                state.shape = GeoFenceShapeReducer(shape: shape, composedData: "-")
            }
        case GeoFenceDrawingActions.savedGeoFence(let geoFenceId):
            state.rule.fenceID = geoFenceId
            state.isEditable = false
        case LocationPickerActions.locationSelected(let location):
            state.centralLocation = location
        case ProfileActions.composingProfileInfo(let info):
            if case .range(let rangeText) = info, let range = CLLocationDistance(rangeText) {
                if let shape = state.shape {
                    let convertedRange = Measurement(value: range, unit: UnitLength.miles).converted(to: .meters).value
                    state.shape = GeoFenceShapeReducer(shape: shape, composedData: convertedRange)
                }
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as GeoFenceDrawingFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

    static func GeoFenceShapeReducer(shape: GeoFenceShapeForEdit, composedData: Any) -> GeoFenceShapeForEdit {
        switch shape {
        case .circle(let center, let radius):
            switch composedData {
            case let coordinate as CLLocationCoordinate2D:
                return .circle(center: coordinate, radius: radius)
            case let distance as CLLocationDistance:
                return .circle(center: center, radius: max(20, distance))
            default:
                return shape
            }
        case .polygon(let points):
            switch composedData {
            case let coordinates as [CLLocationCoordinate2D]:
                return .polygon(points: (points ?? []) + coordinates)
            case let coordinate as CLLocationCoordinate2D:
                return .polygon(points: (points ?? []) + [coordinate])
            case let string as String:
                if string == "-" {
                    var points = points
                    _ = points?.popLast()
                    return .polygon(points: points ?? [])
                }
                else {
                    return shape
                }
            default:
                return shape
            }
        }
    }

}

