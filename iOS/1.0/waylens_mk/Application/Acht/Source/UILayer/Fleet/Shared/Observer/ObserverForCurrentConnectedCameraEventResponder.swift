//
//  ObserverForCurrentConnectedCameraEventResponder.swift
//  Fleet
//
//  Created by forkon on 2020/8/10.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

protocol ObserverForCurrentConnectedCameraEventResponder: class {
    func connectedCameraDidChange(_ camera: WLCameraDevice?)
}
