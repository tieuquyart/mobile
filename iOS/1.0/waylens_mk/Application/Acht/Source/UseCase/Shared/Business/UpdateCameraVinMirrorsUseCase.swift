//
//  UpdateCameraVinMirrorsUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UpdateCameraVinMirrorsUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let camera: UnifiedCamera

    public init(camera: UnifiedCamera, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        let vinMirrors: [VinMirror] = camera.local?.vinMirrorList?.compactMap{VinMirror(rawValue: $0 as! String)} ?? []
        actionDispatcher.dispatch(VinMirrorActions.updateVinMirrors(vinMirrors))
    }

}

protocol UpdateCameraVinMirrorsUseCaseFactory {
    func makeUpdateCameraVinMirrorsUseCase() -> UseCase
}
