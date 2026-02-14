//
//  SC360Library.swift
//  SC360
//
//  Created by Chester Shen on 11/22/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import GPUImage

enum ProjectionMode {
    case frontback
    case perspective
    case panorama
    case ball
    case raw
}

class SC360Library: ImageProcessingOperation {
    let maximumInputs: UInt = 1
    var sources: SourceContainer {
        return inputRelay.sources
    }
    var targets: TargetContainer {
        return outputRelay.targets
    }
    var input: ImageSource?
    let inputRelay = CachedImageRelay()
    let outputRelay = ImageRelay()
    var projectionMode: ProjectionMode = .frontback
    var dewarping: SynchronziedOperation!
    var interactiveManager: InteractiveManager?
    var director: Director?
    var sharedDirection: Direction
    var showTimestamp: Bool = false
    var showGPS: Bool = false
    var timestampExtraction: TimestampExtraction?
    var overlayBlending: FloatOverlay?
    var outputSize: Size? {
        didSet {
            dewarping?.overriddenOutputSize = outputSize
            director?.updateViewPort()
            if let size = outputSize {
                timestampExtraction?.overriddenOutputSize = Size(width: size.width * Float(timestampSizeRatio.width), height: size.height * Float(timestampSizeRatio.height))
            }
        }
    }
    let timestampSizeRatio = CGSize(width: 1, height: 0.03)
//    var dewarpingPools: []
    init(input: ImageSource?, output: ImageConsumer?, interactiveView: UIView?) {
        sharedDirection = Direction()
        if let view = interactiveView {
            interactiveManager = InteractiveManager(view: view)
            interactiveManager?.delegate = self
        }
        if let input = input {
            switchInput(input)
        }
        if let output = output {
            outputRelay.addTarget(output)
        }
        setupProjection()
    }
    
    func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        inputRelay.newTextureAvailable(texture, fromSourceIndex: fromSourceIndex)
    }
    
    func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        // pass
    }
    
    func clear() {
        inputRelay.outputTexture = nil
        interactiveManager?.stopTimer()
    }
    
    func toggleFace(_ down: Bool) {
        director?.onFace(down)
    }

    func switchProjection(_ mode: ProjectionMode) {
        if projectionMode == mode {
            return
        }
        projectionMode = mode
        inputRelay.removeAllTargets()
        dewarping?.removeAllTargets()
        overlayBlending?.removeAllTargets()
        setupProjection()
    }
    
    func switchTimestamp(_ on:Bool, hasGPS:Bool) {
        if ((on == showTimestamp) &&
            (hasGPS == showGPS)) {
            return
        }
        showTimestamp = on
        showGPS = hasGPS
        inputRelay.removeAllTargets()
        dewarping?.removeAllTargets()
        overlayBlending?.removeAllTargets()
        setupPipeline()
    }
    
    func switchInput(_ newInput: ImageSource?) {
        if input === newInput {
            return
        }
        input?.removeAllTargets()
        input = newInput
        input?.addTarget(inputRelay)
    }
    
    func setupProjection() {
        switch projectionMode {
        case .frontback:
            let frontback = FrontBackDewarping()
            director = Director(filter: frontback, direction: sharedDirection)
            dewarping = frontback
            dewarping.overriddenOutputSize = outputSize
        case .perspective:
            interactiveManager?.inertiaEnabled = false
            let perspective = PerspectiveDewarping()
            director = Director(filter: perspective, direction: sharedDirection)
            dewarping = perspective
            dewarping.overriddenOutputSize = outputSize
        case .panorama:
            interactiveManager?.inertiaEnabled = false
            let pano = PanoramaDewarping()
            director = PanoramaDirector(filter: pano, direction: sharedDirection)
            dewarping = pano
            dewarping.overriddenOutputSize = outputSize
        case .ball:
            interactiveManager?.inertiaEnabled = true
            let ball = BallDewarping()
            director = BallDirector(filter: ball)
            dewarping = ball
            dewarping.overriddenOutputSize = outputSize
        case .raw:
            interactiveManager?.inertiaEnabled = false
            dewarping = nil
        }
        setupPipeline()
    }
    
    func setupPipeline() {
        if projectionMode == .raw {
            inputRelay --> outputRelay
            return
        }
        if showTimestamp {
            if timestampExtraction == nil {
                timestampExtraction = TimestampExtraction()
                if let size = outputSize {
                    timestampExtraction?.overriddenOutputSize = Size(width: size.width * Float(timestampSizeRatio.width), height: size.height * Float(timestampSizeRatio.height))
                }
            }
            if overlayBlending == nil {
                let overlayFrame = CGRect(origin: CGPoint(x: 0, y: 1 - timestampSizeRatio.height), size: timestampSizeRatio)
                overlayBlending = FloatOverlay(frame: overlayFrame)
            }
            timestampExtraction?.hasGPS = showGPS ? 1.0 : 0.0
            inputRelay --> dewarping --> overlayBlending! --> outputRelay
            inputRelay --> timestampExtraction! --> overlayBlending!
        } else {
            inputRelay --> dewarping --> outputRelay
        }
        dewarping.needUpdateTexture = true
    }
    
    func updateOutputSize(_ size: CGSize) {
        outputSize = Size(width: Float(size.width), height: Float(size.height))
    }
}

extension SC360Library: InteractionResponsive {
    func onMove(x: CGFloat, y: CGFloat) {
        director?.onMove(x: x, y: y)
        dewarping?.needUpdateTexture = true
    }
    
    func onScale(_ diff: CGFloat) {
        director?.onScale(diff)
    }
}
