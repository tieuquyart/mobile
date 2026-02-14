//
//  CalibrationVehicleInfoViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct CalibrationVehicleInfoViewControllerState: ReSwift.StateType, Equatable {
    public var loadedState: LoadedState<[String]> = .notLoaded
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: CalibrationVehicleInfoViewState = CalibrationVehicleInfoViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct CalibrationVehicleInfoViewState: Equatable {
    enum Element: Int, CaseIterable {
        case rudderSideTitle
        case left
        case right
        case seperator
        case cabinSizeTitle
        case truck
        case largeSuvOrPickup
        case carOrSmallSuv

        var title: String? {
            switch self {
            case .rudderSideTitle:
                return NSLocalizedString("If the vehicle is left or right hand drive", comment: "If the vehicle is left or right hand drive")
            case .left:
                return NSLocalizedString("Left", comment: "Left")
            case .right:
                return NSLocalizedString("Right", comment: "Right")
            case .seperator:
                return nil
            case .cabinSizeTitle:
                return NSLocalizedString("Choose the type closest to yoru vehicle in driver cabin size", comment: "Choose the type closest to yoru vehicle in driver cabin size")
            case .truck:
                return NSLocalizedString("Truck", comment: "Truck")
            case .largeSuvOrPickup:
                return NSLocalizedString("Large SUV / Pickup", comment: "Large SUV / Pickup")
            case .carOrSmallSuv:
                return NSLocalizedString("Car / Small SUV", comment: "Car / Small SUV")
            }
        }
    }

    private(set) var elements: [Element] = Element.allCases
    var selectedElements: Set<Element> = [.left, .truck]

    var activityIndicatingState: ActivityIndicatingState
}
