//
//  LoadCameraListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadCameraListUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))
        WaylensClientS.shared.request(.cameraList) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(let value):
                if let cameraInfos = value["cameraInfos"] as? [[String : Any]] {
                    self.actionDispatcher.dispatch(CameraListActions.loadCameraList(cameraInfos.compactMap{try? JSONDecoder().decode(CameraProfile.self, from: $0.jsonData ?? Data())}))
                }
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol LoadCameraListUseCaseFactory {
    func makeLoadCameraListUseCase() -> UseCase
}
