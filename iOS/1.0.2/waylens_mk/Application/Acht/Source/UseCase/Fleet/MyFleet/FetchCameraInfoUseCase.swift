//
//  FetchCameraInfoUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FetchCameraInfoUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let cameraSN: String

    public init(
        cameraSN: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.cameraSN = cameraSN
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .deviceInfo(deviceID: cameraSN)
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(let response):
                let cameraInfo = try? JSONDecoder().decode(CameraInfo.self, from: response.jsonData ?? Data())
                self.actionDispatcher.dispatch(CameraDetailActions.loadCameraInfo(cameraInfo))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol FetchCameraInfoUseCaseFactory {
    func makeFetchCameraInfoUseCase() -> UseCase?
}
