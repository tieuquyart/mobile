//
//  CameraObserverForVinMirrorEventResponder.swift
//  Acht
//
//  Created by forkon on 2020/4/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

protocol CameraObserverForVinMirrorEventResponder: class {
    func received(newVinMirrors: [VinMirror])
}
