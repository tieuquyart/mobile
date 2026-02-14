//
//  UpdateCameraRecordConfigUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UpdateCameraRecordConfigUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let camera: UnifiedCamera

    public init(camera: UnifiedCamera, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(RecordConfigActions.updateRecordConfig(camera.local?.recordConfig))
    }

}

protocol UpdateCameraRecordConfigUseCaseFactory {
    func makeUpdateCameraRecordConfigUseCase() -> UseCase
}
