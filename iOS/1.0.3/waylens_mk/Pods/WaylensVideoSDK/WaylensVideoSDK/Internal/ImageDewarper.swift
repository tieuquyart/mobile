//
//  ImageDewarper.swift
//  SC360
//
//  Created by Chester Shen on 11/27/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import GPUImage
import MetalKit

public class ImageDewarper: ImageSource, ImageConsumer{
    public let maximumInputs: UInt = 1
    let h_w_ratio: Float = 9.0 / 16.0
    public let sources = SourceContainer()
    
    public static let shared = ImageDewarper()
    public let targets = TargetContainer()
    let queue = DispatchQueue(label: "com.waylens.horn.imagedewarper", qos: .default, attributes: [])
    let dewarping = FrontBackDewarping()
    var currentCompletion: ((UIImage?) -> Void)?
    
    init() {
        self --> dewarping --> self
    }
    
    deinit {
        removeAllTargets()
    }
    
    public func processImage(_ image: UIImage, width: CGFloat, facedown: Bool, completion: @escaping ((UIImage?) -> Void)) {
        guard let cgImage = image.cgImage else { return }
        queue.async {
            let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
            do {
                let imageTexture = try textureLoader.newTexture(cgImage: cgImage, options: [MTKTextureLoader.Option.SRGB : false])
                let outputTexture = Texture(orientation: .portrait, texture: imageTexture)
                self.currentCompletion = completion
                self.dewarping.facedown = facedown ? 1.0 : 0.0
                self.dewarping.overriddenOutputSize = Size(width: Float(width), height: Float(width) * self.h_w_ratio)
                self.updateTargetsWithTexture(outputTexture)
            } catch {
                fatalError("Failed loading image texture")
            }
        }
    }
    
    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        let image = texture.texture.toUIImage()
        if let completion = currentCompletion {
            DispatchQueue.main.async {
                completion(image)
            }
            currentCompletion = nil
        }
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
    }
}

extension MTLTexture {
    
    func toUIImage() -> UIImage {
        let bytesPerPixel: Int = 4
        let bytesPerRow = width * bytesPerPixel
        let imageByteCount = bytesPerRow * height

        let src = UnsafeMutableRawPointer.allocate(byteCount: imageByteCount, alignment: 4)
        defer {
            src.deallocate()
        }

        let region = MTLRegionMake2D(0, 0, self.width, self.height)
        self.getBytes(src, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        let context = CGContext(data: src, width: self.width, height: self.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue);

        if let dstImageFilter = context?.makeImage() {
            return UIImage(cgImage: dstImageFilter, scale: 1.0, orientation: .up)
        }
        else {
            return UIImage()
        }
    }
}
