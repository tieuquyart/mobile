//
//  MotionImageInput.swift
//  SC360Example
//
//  Created by Chester Shen on 11/26/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import GPUImage
import MetalKit

class MotionImageInput: TriggerSource, ImageSource, LocalPreviewViewModelDelegate {
    public let targets = TargetContainer()
    
    var internalImage: CGImage?
    let inputFrameProcessingQueue = DispatchQueue(
        label: "com.sunsetlakesoftware.GPUImage.motionImageInputFrameProcessingQueue",
        attributes: [])
    let semaphore = DispatchSemaphore(value:1)
    public init() {
        
    }
    
    public func clear() {
    }
    
    public func updateImage(_ image: UIImage) {
        guard (semaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else {
//            print("Drop a Image!")
            return
        }
        internalImage = image.cgImage
        semaphore.signal()
    }
    func needPower2Size() -> Bool {
        return true
    }
    
    func processImage(_ image: CGImage) {
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        do {
            let imageTexture = try textureLoader.newTexture(cgImage:image, options: [MTKTextureLoader.Option.SRGB : false])
            let outputTexture = Texture(orientation: .portrait, texture: imageTexture)
            outputTexture.timingStyle = .videoFrame(timestamp: Timestamp(.zero))
            updateTargetsWithTexture(outputTexture)
        } catch {
            fatalError("Failed loading image texture")
        }
    }
    
    public func tick() {
        guard (semaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else {
            return
        }
        if let image = internalImage {
            internalImage = nil
            inputFrameProcessingQueue.async {
                self.processImage(image)
                self.semaphore.signal()
            }
        } else {
            inputFrameProcessingQueue.async {
                for (target, _) in self.targets {
                    if let sourceTarget = target as? ImageProcessingOperation {
                         _ = sourceTarget.updateTargetIfNeeded()
                    }
                }
                self.semaphore.signal()
            }
        }
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        //
    }

}
