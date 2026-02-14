//
//  AVPlayerInput.swift
//  SC360
//
//  Created by Chester Shen on 11/8/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import GPUImage
import AVFoundation

class AVPlayerInput: TriggerSource, ImageSource {
    public let targets = TargetContainer()
    let playerItem: AVPlayerItem
    var output: AVPlayerItemVideoOutput?
    var textureCache: CVMetalTextureCache?
    var playerStatusObervation: NSKeyValueObservation?
    var outputTexture: Texture?
    public init(playerItem: AVPlayerItem ) {
        self.playerItem = playerItem
        playerStatusObervation =  playerItem.observe(\.status, options: [.initial, .new, .old], changeHandler: { [weak self] (item, change) in
            guard let this = self else { return }
            if item.status == .readyToPlay && this.output == nil {
                this.setup()
            }
        })
    }
    
    deinit {
        playerStatusObervation = nil
    }
    
    public func clear() {
        tearDown()
        outputTexture = nil
    }
    
    func setup() {
        let outputSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        output = AVPlayerItemVideoOutput(pixelBufferAttributes: outputSettings)
        playerItem.add(output!)
        let _ = CVMetalTextureCacheCreate(kCFAllocatorDefault,
                                          nil,
                                          sharedMetalRenderingDevice.device,
                                          nil,
                                          &textureCache)
    }
    
    func tearDown() {
        if let output = self.output {
            playerItem.remove(output)
            self.output = nil
        }
    }
    
    func process(buffer:CVPixelBuffer, with sampleTime:CMTime) {
        let bufferHeight = CVPixelBufferGetHeight(buffer)
        let bufferWidth = CVPixelBufferGetWidth(buffer)
        //        let bufferPitch = (((bufferWidth) + 63) & ~63)
        //        width_pitch = Float(bufferWidth) / Float(bufferPitch)
//        let startTime = CFAbsoluteTimeGetCurrent()
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue:CVOptionFlags(0)))
        var textureRef: CVMetalTexture? = nil
        let _ = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                          textureCache!,
                                                          buffer,
                                                          nil,
                                                          .bgra8Unorm,
                                                          bufferWidth,
                                                          bufferHeight,
                                                          0,
                                                          &textureRef)
        
        if let concreteTexture = textureRef,
           let movieTexture = CVMetalTextureGetTexture(concreteTexture) {
            let texture = Texture(orientation: .portrait, texture: movieTexture)
            texture.timingStyle = .videoFrame(timestamp: Timestamp(sampleTime))
            outputTexture = texture
            self.updateTargetsWithTexture(texture)
        }
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue:CVOptionFlags(0)))
//        if self.runBenchmark {
//            let currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime)
//            self.numberOfFramesCaptured += 1
//            self.totalFrameTimeDuringCapture += currentFrameTime
//            print("Average frame time : \(1000.0 * self.totalFrameTimeDuringCapture / Double(self.numberOfFramesCaptured)) ms")
//            print("Current frame time : \(1000.0 * currentFrameTime) ms")
//        }
    }

    public func tick() {
        guard let output = self.output else { return }
        let currentTime = playerItem.currentTime()
        if output.hasNewPixelBuffer(forItemTime: currentTime),
            let buffer = output.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            process(buffer: buffer, with: currentTime)
            //        CVBufferRelease(buffer)
        } else {
            _ = updateTargetIfNeeded()
        }
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
        // Not needed for movie inputs
    }
}
