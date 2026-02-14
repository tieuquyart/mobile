//
//  ToggleFirmwareVersionUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ToggleFirmwareVersionUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(CameraDetailActions.toggleFirmwareVersion)
    }

}

protocol ToggleFirmwareVersionUseCaseFactory {
    func makeToggleFirmwareVersionUseCase() -> UseCase
}
