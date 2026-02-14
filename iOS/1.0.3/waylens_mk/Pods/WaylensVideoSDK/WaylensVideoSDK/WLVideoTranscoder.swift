//
//  Waylens360Transcoder.swift
//  SimpleMovieFilter
//
//  Created by gliu on 9/18/17.
//  Copyright © 2017 Sunset Lake Software LLC. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

public enum WLVideoTranscodeResolution: CaseIterable {
    case hd1280x720
    case hd1920x1080
    case custom(width: Float, height: Float)

    public var videoDimensions: Size {
        switch self {
        case .hd1280x720:
            return Size(width: 1280, height: 720)
        case .hd1920x1080:
            return Size(width: 1920, height: 1080)
        case .custom(let width, let height):
            return Size(width: width, height: height)
        }
    }

    public static var allCases: [WLVideoTranscodeResolution] {
        return [.hd1280x720, .hd1920x1080]
    }
}

public struct WLVideoTranscoderInput {

    /// The URL of the local file will be transcoded.
    public var fileUrl: URL

    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
}

public struct WLVideoTranscoderOutput {

    /// Output location.
    public var destinationUrl: URL

    /// Set the resolution of output video.
    public var resolution: WLVideoTranscodeResolution

    /// Set the bitrate of output video.
    ///
    /// Set to 0 to use default value.
    public var bitrateInKbps: Double

    /// Params for dewarping 360 degrees fish eye video.
    ///
    /// If value is nil, not using dewarping.
    public var dewarpParams: WLVideoDewarpParams?

    public init(
        destinationUrl: URL,
        resolution: WLVideoTranscodeResolution,
        bitrateInKbps: Double,
        dewarpParams: WLVideoDewarpParams?
    ) {
        self.destinationUrl = destinationUrl
        self.resolution = resolution
        self.bitrateInKbps = bitrateInKbps
        self.dewarpParams = dewarpParams
    }
}

public class WLVideoTranscoder {
    /// A closure executed when monitoring transcode progress of a transcoder.
    public typealias ProgressHandler = (Float) -> Void

    /// A closure to be called when the transcoding is complete.
    public typealias CompletionHandler = () -> Void

    /// A closure to be called when the transcoding is failed.
    public typealias FailureHandler = () -> Void

    public var isTranscoding: Bool {
        state == .transcoding
    }

    private enum TranscodeState {
        case idle
        case transcoding
        case cancelled
        case failed
        case completed
    }

    private var state: TranscodeState = .idle
    private var inputURL: URL
    private var outputURL: URL
    private var inputAudioTrack: AVAssetTrack?
    private var movie: WaylensMovieInput!
    // var filterSharpen:Sharpen!
    private var filterExposure: ExposureAdjustment!
    private var filterSaturation: SaturationAdjustment!
    private var filterContrast: ContrastAdjustment!
    private var filterDistortion: SC360Library!
    private var filterBlendOverlay: AlphaBlend!
    private var lastFilter: ImageSource!
    private var size: Size!
    
    private var movieOutput: WaylensMovieOutput? = nil
    // var width_pitch : Float = 1

    private var progressHandler: ProgressHandler? = nil
    private var completionHandler: CompletionHandler? = nil
    private var failureHandler: FailureHandler? = nil

    public init(input: WLVideoTranscoderInput, output: WLVideoTranscoderOutput) throws {
        var videoNaturalSize: CGSize? = nil

        //playback
        do {
            self.inputURL = input.fileUrl
            self.outputURL = output.destinationUrl
            let inputOptions = [AVURLAssetPreferPreciseDurationAndTimingKey:NSNumber(value:true)]
            let inputAsset = AVURLAsset(url:inputURL, options:inputOptions)

            for track in inputAsset.tracks {
                switch track.mediaType {
                 case .video:
                    videoNaturalSize = track.naturalSize
                    // NSLog("video resolution: \(track.naturalSize)")
                    // self.width_pitch = (Float(track.naturalSize.width)/Float((Int(track.naturalSize.width) + 63) & ~63))
                case .audio:
                    inputAudioTrack = track
                default:
                    break
                }
            }
            movie = try WaylensMovieInput.init(asset: inputAsset, playAtActualSpeed: false, loop: false)
            movie.delegate = self
            // filterSharpen = Sharpen()
            // filterSharpen.sharpness = 0.35
            filterExposure = ExposureAdjustment()
            filterExposure.exposure = -0.0
            filterSaturation = SaturationAdjustment()
            filterSaturation.saturation = 1
            filterContrast = ContrastAdjustment()
            filterContrast.contrast = 1.2
            filterDistortion = SC360Library(input: movie, output: nil, interactiveView: nil)

            if let dewarpParams = output.dewarpParams {
                switch dewarpParams.renderMode {
                case .split:
                    filterDistortion.switchProjection(.frontback)
                case .immersive(let direction):
                    if let direction = direction {
                        filterDistortion.sharedDirection = direction
                    }
                    filterDistortion.switchProjection(.perspective)
                case .ball:
                    filterDistortion.switchProjection(.ball)
                case .original:
                    filterDistortion.switchProjection(.raw)
                }

                filterDistortion.toggleFace(dewarpParams.rotate180Degrees)
                filterDistortion.switchTimestamp(dewarpParams.showTimeStamp, hasGPS: dewarpParams.showGPS)
            }
            else {
                filterDistortion.switchProjection(.raw)
            }

            let enableSharpen = true
            if enableSharpen {
                // movie --> filterDistortion --> filterSharpen --> filterExposure --> filterSaturation --> filterContrast
                movie --> filterDistortion --> filterExposure --> filterSaturation --> filterContrast
                lastFilter = filterContrast
            } else {
                movie --> filterDistortion
                lastFilter = filterDistortion
            }

            /*
            if let outputView = output.view {
                lastFilter --> outputView
            }
            */
        } catch {
            // Log.error("Couldn't process movie with error: \(error)")
            throw error
        }

        //encode
        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at:outputURL)
            }

            let size: Size

            if case .original = output.dewarpParams?.renderMode, let videoNaturalSize = videoNaturalSize {
                size = Size(width: Float(videoNaturalSize.width), height: Float(videoNaturalSize.height))
            }
            else {
                size = output.resolution.videoDimensions
            }

            movieOutput = try WaylensMovieOutput(
                URL: outputURL,
                size: size,
                dele: self,
                bitrateInKbps: output.bitrateInKbps
            )
            lastFilter --> movieOutput!
        } catch {
            // Log.error("Couldn't initialize movie, error: \(error)")
            throw error
        }

        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resume), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Start the transcoding.
    ///
    /// - Returns: The transcoder.
    @discardableResult
    public func start() -> Self {
        sharedMetalRenderingDevice.cache.purgeAll()
        if (state != .transcoding) {
            movieOutput?.startRecording()
            self.movie.start()
            state = .transcoding
        }
        
        if movieOutput == nil {
            failureHandler?()
        }

        return self
    }

    /// Pause the transcoding.
    @objc public func pause() {
        movie.pause()
    }

    /// Resume the transcoding.
    @objc public func resume() {
        movie.resume()
    }

    /// Cancels the transcoding.
    public func cancel() {
        state = .cancelled
        movie.cancel()
    }

    /// Sets a closure to be called periodically during transcoding.
    ///
    /// After starting transcoding, the `transcodeProgress(closure:)` APIs can be used to monitor the progress
    /// of video being transcoded.
    ///
    /// - parameter closure: The code to be executed periodically as video is transcoded.
    ///
    /// - returns: The transcoder.
    @discardableResult
    public func transcodeProgress(closure: @escaping ProgressHandler) -> Self {
        progressHandler = closure
        return self
    }

    /// Sets a closure to be called when the transcoding is complete.
    ///
    /// - parameter closure: The code to be executed as the transcoding is complete.
    @discardableResult
    public func completion(closure: @escaping CompletionHandler) -> Self {
        completionHandler = closure
        return self
    }

    /// Sets a closure to be called when the transcoding is failed.
    ///
    /// - parameter closure: The code to be executed as the transcoding is failed.
    @discardableResult
    public func failure(closure: @escaping FailureHandler) -> Self {
        failureHandler = closure
        return self
    }

}

//MARK: - Private

private extension WLVideoTranscoder {

    func removeFile(_ url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func addAudioTrack(completion: @escaping (Bool)->Void) {
        let asset = AVURLAsset(url: outputURL)

        guard let audioTrack = inputAudioTrack, let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(false)
            return
        }

        let mixComposition = AVMutableComposition()
        
        do {
            let newVideoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
            let newAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            try newVideoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
            try newAudioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: audioTrack, at: .zero)
            let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough)!
            let tempURL = outputURL.deletingLastPathComponent().appendingPathComponent("temp_" + outputURL.lastPathComponent)
            exportSession.outputFileType = .mov
            exportSession.outputURL = tempURL
            exportSession.shouldOptimizeForNetworkUse = true
            removeFile(tempURL)
            exportSession.exportAsynchronously {
                self.removeFile(self.outputURL)
                try? FileManager.default.moveItem(at: tempURL, to: self.outputURL)
                completion(true)
            }
        } catch {
            // Log.error("Fail to insert audio track: \(error.localizedDescription)")
            completion(false)
        }
    }

    func onWriterFinish() {
        if state == .completed && inputAudioTrack != nil {
            addAudioTrack(completion: { [weak self] (done) in
                guard let self = self else {
                    return
                }

                DispatchQueue.main.async {
                    if done {
                        self.completionHandler?()
                    }
                    else {
                        self.failureHandler?()
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                if self.state == .completed {
                    self.completionHandler?()
                }
                else {
                    self.failureHandler?()
                }
            }
        }
    }

    func runBenchmark() {
        self.movie.runBenchmark = true
    }

}

extension WLVideoTranscoder: WaylensMovieInputProgressDelegate {

    public func onConsumeProgress(_ percent: Float) {
        // debugPrint("ReadFrames \(movie.numberOfFramesRead) Input frames \(movie.numberOfFramesCaptured) Output frames \(movieOutput!.encodedFrames)")
        DispatchQueue.main.async {
            self.progressHandler?(percent)
        }
    }

    public func onInputFinished(finished: Bool) {
        if finished {
            state = .completed
        } else if state != .cancelled {
            state = .failed
        }
        movieOutput?.finishRecording({
            self.onWriterFinish()
        })
    }

}

extension WLVideoTranscoder: WaylensMovieOutputDelegate {

    public func onUpdateTime(Offset sec : Double) {
        // filterDistortion.immersiveAngle += 0.5
    }

    public func onUpdateSubtitle(Text text : String) {

    }

}
