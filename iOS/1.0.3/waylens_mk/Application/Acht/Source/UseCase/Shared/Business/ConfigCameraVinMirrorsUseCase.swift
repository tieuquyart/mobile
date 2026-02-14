//
//  ConfigCameraVinMirrorsUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ConfigCameraVinMirrorsUseCase: UseCase {
    let vinMirrors: [VinMirror]
    let camera: UnifiedCamera?

    public init(camera: UnifiedCamera?, vinMirrors: [VinMirror]) {
        self.camera = camera
        self.vinMirrors = vinMirrors
    }

    public func start() {
        camera?.local?.doSetVinMirror(vinMirrors.map{$0.rawValue})
    }

}

protocol ConfigCameraVinMirrorsUseCaseFactory {
    func makeConfigCameraVinMirrorsUseCase(with vinMirrors: [VinMirror]) -> UseCase
}
