//
//  IJKPlayerAdapter.swift
//  SC360
//
//  Created by Chester Shen on 11/9/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import IJKMediaFrameworkWithSSL
import GPUImage

func makeFourCC(_ fcc: String) -> UInt32 {
    let _fcc = fcc.prefix(4)
    var v:UInt32 = 0
    if BYTE_ORDER == LITTLE_ENDIAN {
        for i in _fcc.unicodeScalars.reversed() {
            v = (v << 8 | i.value)
        }
    } else if BYTE_ORDER == BIG_ENDIAN {
        for i in _fcc.unicodeScalars {
            v = (v << 8 | i.value)
        }
    }
    return v
}

class IJKPlayerAdapter: UIView, IJKSDLGLViewProtocol, ImageSource {
    public var isThirdGLView: Bool = true
    public var fps: CGFloat {
        return 30
    }
    public var scaleFactor: CGFloat = 1
    public let targets = TargetContainer()
    
    let renderPipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer
    let inputSemaphore = DispatchSemaphore(value:1)
    let processingSemaphore = DispatchSemaphore(value:1)
    let inputQueue = DispatchQueue(
        label: "com.waylens.SC360.IJKPlayerAdapter.inputQueue",
        attributes: [])
    let processingQueue = DispatchQueue(
        label: "com.waylens.SC360.IJKPlayerAdapter.processingQueue",
        attributes: [])
    var framesRendered: Int = 0
    var inputTextureBuffer = [Texture]()
    var nextOut: Int = 0
    var nextIn: Int = 0
    var isProcessing: Bool = false
    let BufferCapacity: Int = 2
//    var startTime: TimeInterval = 0

    public override init(frame: CGRect) {
        renderPipelineState = generateRenderPipelineState(
            device:sharedMetalRenderingDevice,
            vertexFunctionName:defaultVertexFunctionNameForInputs(1),
            fragmentFunctionName:"YUV2RGBFragment", operationName:"yuv2rgb"
        )

        vertexBuffer = sharedMetalRenderingDevice.device.makeBuffer(
            bytes: standardImageVertices,
            length: standardImageVertices.count * MemoryLayout<Float>.size,
            options: []
        )!
        vertexBuffer.label = "Vertices"

        super.init(frame: frame)

        CVMetalTextureCacheCreate(
            kCFAllocatorDefault,
            nil,
            sharedMetalRenderingDevice.device,
            nil,
            &textureCache
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func snapshot() -> UIImage? {
        return nil
    }
    
    var SDL_FCC_VTB: UInt32 = makeFourCC("_VTB")
    
    var textureCache: CVMetalTextureCache!
    
    public func clear() {
        inputQueue.async {
            self.nextIn = 0
            self.nextOut = 0
            self.inputTextureBuffer.removeAll()
        }
    }
    
    public func display_pixels(_ overlay: UnsafeMutablePointer<IJKOverlay>!) {
        let overlayData = overlay.pointee
        guard let bufferRef = overlayData.pixel_buffer else { return }
        let buffer = bufferRef.takeUnretainedValue()
        switch overlayData.format {
        case SDL_FCC_VTB:
            process(buffer: buffer)
        default:
            break
        }
    }
    
    func process(buffer:CVPixelBuffer) {
        guard (inputSemaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else {
            print("Drop a input frame!")
            return
        }
        inputQueue.async {
            guard let textureY = self.createTexture(fromPixelBuffer: buffer, pixelFormat: .r8Unorm, planeIndex: 0),
                let textureCbCr = self.createTexture(fromPixelBuffer: buffer, pixelFormat: .rg8Unorm, planeIndex: 1)
                else {
                    fatalError("Could not create YCbCr texture")
            }
            self.convertFrame(textureY: CVMetalTextureGetTexture(textureY)!, textureCrCb: CVMetalTextureGetTexture(textureCbCr)!)
        }
    }
    
    func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        
        if status != kCVReturnSuccess {
            texture = nil
        }
        
        return texture
    }
    
    func convertFrame(textureY: MTLTexture, textureCrCb: MTLTexture) {
        
        guard let commondBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {
            fatalError("Could not create command buffer")
        }
        
        let outputWidth = textureY.width
        let outputHeight = textureY.height
        if inputTextureBuffer.count == 0 {
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                             width: outputWidth,
                                                                             height: outputHeight,
                                                                             mipmapped: false)
            textureDescriptor.usage = [.renderTarget, .shaderRead]
            for _ in 0..<BufferCapacity {
                guard let mtlTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: textureDescriptor) else {
                    fatalError("Could not create texture")
                }
                let newTexture = Texture(orientation: .portrait, texture: mtlTexture)
                newTexture.timingStyle = .videoFrame(timestamp: Timestamp(.zero)) // placeholder for timestamp
                inputTextureBuffer.append(newTexture)
            }
            nextIn = 0
            nextOut = 0
        }
        if isProcessing && (nextOut - 1) % BufferCapacity == nextIn % BufferCapacity && nextOut < nextIn {
            nextIn = nextIn + 1
            nextOut = nextIn
        } else if !isProcessing && nextOut % BufferCapacity == nextIn % BufferCapacity && nextOut < nextIn {
//            print("Drop \(BufferCapacity - 1) texture frames")
            nextOut = nextIn - 1
        }
        let texture = inputTextureBuffer[nextIn % BufferCapacity]
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = texture.texture
//        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1)
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = .dontCare
        
        guard let renderEncoder = commondBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("Could not create render encoder")
        }
        
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let inputTextureCoordinates = texture.textureCoordinates(for: .portrait, normalized: true)
        let textureBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: inputTextureCoordinates,
                                                                         length: inputTextureCoordinates.count * MemoryLayout<Float>.size,
                                                                         options: [])!
        textureBuffer.label = "Texture Coordinates"
        renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(textureY, index: 0)
        renderEncoder.setFragmentTexture(textureCrCb, index: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        commondBuffer.addCompletedHandler { (_) in
            self.inputQueue.async {
                self.nextIn += 1
                self.inputSemaphore.signal()
            }
        }
        commondBuffer.commit()
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
//        if let texture = outputTexture {
//            inputFrameProcessingQueue.async {
//                target.newTextureAvailable(texture, fromSourceIndex:atIndex)
//            }
//        }
    }
}

extension IJKPlayerAdapter: TriggerSource {
    public func tick() {
        guard (processingSemaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else {
//            print("Skip a tick!")
            return
        }
        inputQueue.async {
            if self.nextOut < self.nextIn {
                let texture = self.inputTextureBuffer[self.nextOut % self.BufferCapacity]
                self.nextOut += 1
                self.isProcessing = true
                self.processingQueue.async {
                    self.updateTargetsWithTexture(texture)
                    self.inputQueue.sync {
                        self.isProcessing = false
                    }
                    self.processingSemaphore.signal()
                }
            } else {
                var texture: Texture? = nil
                if self.nextOut > 0 {
                    texture = self.inputTextureBuffer[(self.nextOut - 1) % self.BufferCapacity]
                }
                self.isProcessing = true
                self.processingQueue.async {
                    for (target, index) in self.targets {
                        if let sourceTarget = target as? ImageProcessingOperation, sourceTarget.updateTargetIfNeeded() {
                            if let texture = texture {
                                sourceTarget.newTextureAvailable(texture, fromSourceIndex: index)
                            }
                        }
                    }
                    self.inputQueue.sync {
                        self.isProcessing = false
                    }
                    self.processingSemaphore.signal()
                }
            }
        }
    }
}
