//
//  ApplyCameraRecordConfigUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ApplyCameraRecordConfigUseCase: UseCase {
    let camera: UnifiedCamera
    let recordConfig: String
    let bitrateFactor: Int
    let forceCodec: Int

    let actionDispatcher: ActionDispatcher

    public init(camera: UnifiedCamera, recordConfig: String, bitrateFactor: Int, forceCodec: Int, actionDispatcher: ActionDispatcher) {
        self.camera = camera
        self.recordConfig = recordConfig
        self.bitrateFactor = bitrateFactor
        self.forceCodec = forceCodec
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(RecordConfigActions.willSelectRecordConfig(recordConfig))
        camera.local?.doSetRecordConfig(recordConfig, bitrateFactor: Int32(bitrateFactor), forceCodec: Int32(forceCodec))
    }

}

protocol ApplyCameraRecordConfigUseCaseFactory {
    func makeApplyCameraRecordConfigUseCase(recordConfig: String, bitrateFactor: Int, forceCodec: Int) -> UseCase
}
