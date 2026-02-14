//
//  UpdateCameraRecordConfigListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class UpdateCameraRecordConfigListUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let camera: UnifiedCamera

    public init(camera: UnifiedCamera, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(RecordConfigActions.updateRecordConfigList((camera.local?.recordConfigList as? [WLEvcamRecordConfigListItem]) ?? []))
    }

}

protocol UpdateCameraRecordConfigListUseCaseFactory {
    func makeUpdateCameraRecordConfigListUseCase() -> UseCase
}
