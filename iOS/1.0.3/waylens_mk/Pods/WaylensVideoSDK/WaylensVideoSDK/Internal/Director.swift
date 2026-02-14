//
//  Director.swift
//  SC360
//
//  Created by Chester Shen on 11/22/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import QuartzCore
import GPUImage

class PanoramaDirector: Director {
    override var maxFOV: CGFloat { return 90 }
    
    override func updateViewPort() {
        if angleX > maxFOV {
            currentScale = defaultAngleX / maxFOV
        }
        if angleX < minFOV {
            currentScale = defaultAngleX / minFOV
        }
        if centerLatitude > maxLatitude {
            centerLatitude = maxLatitude
        }
        centerLatitude = max(centerLatitude, min(minLatitude + angleY, 0))
        filter?.updateViewPort(latitude: Float(centerLatitude), longitude: Float(centerLongitude), viewAngleY: Float(angleY), viewAngleX: Float(angleX), facedown: facedown)
    }
}

class BallDirector: Director {
    override var defaultAngleX: CGFloat { return 180 }
    override var maxFOV: CGFloat { return 360 }
    override var minFOV: CGFloat { return 12 }
    override var h_w_ratio: CGFloat {
        var h_w_ratio: CGFloat = 1.0
        if let size = filter?.overriddenOutputSize {
            h_w_ratio = CGFloat(size.height / size.width)
        }
        return h_w_ratio
    }
    static func defaultDirection() -> Direction {
        let d = Direction()
        d.centerLatitude = 35
        d.centerLongitude = 0
        d.currentScale = 1.22
		d.facedown = false
        return d
    }
    
    convenience init(filter: ViewPortOnDome) {
        let direction = BallDirector.defaultDirection()
        self.init(filter: filter, direction: direction)
    }
    
    override func onMove(x: CGFloat, y: CGFloat) {
        let dx = x * angleX * (facedown ? 1 : -1)
        centerLongitude += dx
        updateViewPort()
    }
    
    override func onScale(_ diff: CGFloat) {
    }
    
    override func updateViewPort() {
        if angleX > maxFOV {
            currentScale = defaultAngleX / maxFOV
        }
        if angleX < minFOV {
            currentScale = defaultAngleX / minFOV
        }
        if centerLatitude > maxLatitude {
            centerLatitude = maxLatitude
        }
//        centerLatitude = max(centerLatitude, min(minLatitude + angleY, 0))
        filter?.updateViewPort(
            latitude: Float(centerLatitude),
            longitude: Float(centerLongitude),
            viewAngleY: Float(angleY),
            viewAngleX: Float(angleX),
            facedown: facedown
        )
    }
}

class Director: InteractionResponsive {
    var defaultAngleX: CGFloat { return 54 }
    var maxFOV: CGFloat { return 60 }
    var minFOV: CGFloat { return 12 }
    var maxLatitude: CGFloat { return 90 }
    var minLatitude: CGFloat { return -20 }
    private var si: CGFloat {
        return facedown ? -1 : 1
    }
    var direction: Direction
    var currentScale: CGFloat {
        get {
            return direction.currentScale
        }
        set {
            direction.currentScale = newValue
        }
    }
    var centerLatitude: CGFloat {
        get {
            return direction.centerLatitude
        }
        set {
            direction.centerLatitude = newValue
        }
    }
    var centerLongitude: CGFloat {
        get {
            return direction.centerLongitude
        }
        set {
            direction.centerLongitude = newValue
        }
    }
    var facedown: Bool {
        get {
            return direction.facedown
        }
        set {
            direction.facedown = newValue
        }
    }
    var filter: ViewPortOnDome?
    
    init(filter: ViewPortOnDome, direction: Direction?) {
        self.filter = filter
        if let direction = direction {
            self.direction = direction
        } else {
            self.direction = Direction()
        }
        updateViewPort()
    }
    
    var h_w_ratio: CGFloat {
        var h_w_ratio: CGFloat = 9.0 / 16.0
        if let size = filter?.overriddenOutputSize {
            h_w_ratio = CGFloat(size.height / size.width)
        }
        return h_w_ratio
    }
    
    var angleX: CGFloat {
        return defaultAngleX / currentScale
    }
    
    var angleY: CGFloat {
        return defaultAngleX * h_w_ratio / currentScale
    }
    
    func onMove(x: CGFloat, y: CGFloat) {
        let dy = y * 2 * angleY * si
        let dx = -x * 2 * angleX * si
        centerLatitude += dy
        centerLongitude += dx
        updateViewPort()
    }
    
    func onScale(_ diff: CGFloat) {
        currentScale *= diff
        updateViewPort()
    }
    
    func onFace(_ down: Bool) {
        self.facedown = down
        updateViewPort()
    }
    
    func updateViewPort() {
        if angleX > maxFOV {
            currentScale = defaultAngleX / maxFOV
        }
        if angleX < minFOV {
            currentScale = defaultAngleX / minFOV
        }
        if centerLatitude > maxLatitude {
            centerLatitude = maxLatitude
        }
        if centerLatitude - angleY < minLatitude {
            centerLatitude = minLatitude + angleY
        }
        filter?.updateViewPort(
            latitude: Float(centerLatitude),
            longitude: Float(centerLongitude),
            viewAngleY: Float(angleY),
            viewAngleX: Float(angleX),
            facedown: facedown
        )
    }
}
