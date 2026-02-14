//
//  CameraDetailReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CameraDetailReducer(action: Action, state: CameraDetailViewControllerState?) -> CameraDetailViewControllerState {
        var state = state ?? CameraDetailViewControllerState(cameraInfo: CameraInfo(cameraSN: "", vehiclePlateNumber: ""))

        switch action {
        case CameraDetailActions.loadCameraInfo(var info):
            info?.cameraSN = state.cameraInfo?.cameraSN ?? ""
            info?.vehiclePlateNumber = state.cameraInfo?.vehiclePlateNumber ?? ""
            state.cameraInfo = info
        case CameraDetailActions.toggleFirmwareVersion:
            state.isShowingShortFirmwareVersion = !state.isShowingShortFirmwareVersion
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as CameraDetailFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
