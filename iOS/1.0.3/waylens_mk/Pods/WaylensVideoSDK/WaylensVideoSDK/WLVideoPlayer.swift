//
//  WLVideoPlayer.swift
//  SC360
//
//  Created by Chester Shen on 11/12/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import IJKMediaFrameworkWithSSL
import GPUImage
import MetalKit
import WaylensFoundation

protocol TriggerSource: ImageSource {
    func tick()
    func clear()
}

public enum WLVideoPlayerState {
    case unloaded
    case playing
    case paused
    case buffering
    case stopped
    case completed
    case error
}

public protocol WLVideoPlayerDelegate: AnyObject {
    func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState)
    func player(_ player: WLVideoPlayer, aspectRatioDidChange aspectRatio: CGFloat)
}

public extension WLVideoPlayerDelegate {
    func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState) {}
    func player(_ player: WLVideoPlayer, aspectRatioDidChange aspectRatio: CGFloat) {}
}

public enum WLVideoPlayerItem {
    case video(url: URL)
    case mjpegPreview(url: URL)
    case image(_ image: UIImage)
}

public class WLVideoPlayer: NSObject {
    private enum Config {
        static let defaultNaturalSize = CGSize(width: 1920, height: 1080)
    }

    public private(set) var state: WLVideoPlayerState = .unloaded {
        didSet {
            if state != oldValue {
                delegate?.player(self, stateDidChange: state)
                switch state {
                case .playing:
                    shouldCheckProgress = player?.isPlaying() ?? false
                default:
                    shouldCheckProgress = false
                }
                checkTimer()
                if state == .completed && isLooping {
                    start()
                }
                isConsideredAsCompleted = false
            }
        }
    }

    public weak var delegate: WLVideoPlayerDelegate?

    public private(set) var currentItem: WLVideoPlayerItem?

    public var currentPlaybackTime: TimeInterval {
        get {
            if state == .completed {
                return duration
            }
            guard let player = player else {
                return 0
            }

            return player.currentPlaybackTime
        }
    }

    public var duration: TimeInterval {
        get {
            return selectedDuration ?? player?.duration ?? 0
        }
        set {
            selectedDuration = newValue
        }
    }

    public var isLooping: Bool = false

    public private(set) var naturalSize: CGSize = Config.defaultNaturalSize {
        didSet {
            let newAspectRatio = naturalSize.width / naturalSize.height
            if newAspectRatio != (oldValue.width / oldValue.height) {
                self.delegate?.player(self, aspectRatioDidChange: newAspectRatio)
            }
        }
    }

    private var _dewarpParams: WLVideoDewarpParams = WLVideoDewarpParams(renderMode: .original, rotate180Degrees: false, showTimeStamp: false, showGPS: false)

    /// Params for dewarping 360 degrees fish eye video or image.
    ///
    /// Default is not using dewarping.
    public var dewarpParams: WLVideoDewarpParams {
        set {
            _dewarpParams = newValue
            dewarpParamsDidChange()
            Log.info("\(self.classForCoder) set dewarp params:\n\(newValue)")
        }
        get {
            if case .immersive(let direction) = _dewarpParams.renderMode, direction != library.sharedDirection {
                _dewarpParams.renderMode = .immersive(direction: library.sharedDirection)
            }
            return _dewarpParams
        }
    }

    public var isActive: Bool = true {
        didSet {
            if isActive != oldValue {
                checkTimer()
            }
        }
    }

    public var thumbnailImageAtCurrentTime: UIImage? {
        if let currentItem = currentItem {
            switch currentItem {
            case .video:
                return player?.thumbnailImageAtCurrentTime()
            case .mjpegPreview:
                return previewModel?.thumbnailImageAtCurrentTime
            case .image(let image):
                return image
            }
        }
        return nil
    }

    private var library: SC360Library

    /// A view for video rendering.
    private var displayView: DisplayView
    private var rawImageView: UIImageView
    private var player: IJKMediaPlayback?
    private var previewModel: LocalPreviewViewModel?
    private var timer: Timer?
    private var shouldCheckProgress: Bool = false
    private var displayLink: CADisplayLink?

    /// Which state player will be after prepared.
    private var stateOnPrepared: WLVideoPlayerState?
    private var playbackTimeOnPrepared: TimeInterval = 0
    private var loadState: IJKMPMovieLoadState {
        return player?.loadState ?? []
    }
    private var previousSource: TriggerSource?
    fileprivate var source: TriggerSource?
    private var imageInput: MotionImageInput?
    
   public func getRawImageView() -> UIImageView {
        return  rawImageView
    }

    private var isInteractive: Bool = false {
        didSet {
            checkTimer()
        }
    }

    private var preferredFramesPerSecond: Int = 30 {
        didSet {
            displayView.preferredFramesPerSecond = preferredFramesPerSecond
        }
    }
    
    private var selectedDuration: TimeInterval? = nil
    private var isConsideredAsCompleted: Bool = false

    private var infoOfPlayerDidSetup: (url: URL?, usingCustomGLView: Bool?) = (url: nil, usingCustomGLView: nil)

    /// Only `currentItem` is `WLVideoPlayerItem.video`, the value is true.
    private var seekable: Bool {
        return player != nil
    }

    /// Initializes a WLVideoPlayer with a view.
    /// - Parameter container: The `UIView` will be used to hold player's display view.
    public init(container: UIView) {
        let displayView = DisplayView(frame: container.bounds)
        displayView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        displayView.translatesAutoresizingMaskIntoConstraints = true
        container.addSubview(displayView)

        self.displayView = displayView
        displayView.preferredFramesPerSecond = preferredFramesPerSecond

        library = SC360Library(input: nil, output: displayView, interactiveView: container)

        rawImageView = UIImageView()
        rawImageView.backgroundColor = .black
        rawImageView.frame = displayView.superview?.bounds ?? displayView.bounds
        rawImageView.contentMode = .scaleAspectFit
        rawImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        rawImageView.translatesAutoresizingMaskIntoConstraints = true
        rawImageView.isHidden = true
        displayView.superview?.insertSubview(rawImageView, aboveSubview: displayView)

        super.init()

        displayView.delegate = self

        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
        #if DEBUG
        IJKFFMoviePlayerController.setLogReport(true)
        #else
        IJKFFMoviePlayerController.setLogReport(false)
        #endif
    }

    /// Replaces the player's current item with the specified player item.
    /// - Parameter item: The `WLVideoPlayerItem` that will become the player's current item.
    /// - Returns: The player.
    ///
    /// If the item is nil, the player will shut down.
    @discardableResult
    public func replaceCurrentItem(with item: WLVideoPlayerItem?) -> Self {
        shutdown()

        currentItem = item

        if let currentItem = currentItem {
            switch currentItem {
            case .video(_):
                setupPlayerAccordingToDewarpParamsIfNeeded()
            case .mjpegPreview(_):
                if previewModel == nil {
                    previewModel = LocalPreviewViewModel()
                }
                previewModel?.delegate = self
                imageInput = MotionImageInput()
                library.switchInput(imageInput)
                source = imageInput
            case .image(_):
                if state == .unloaded {
                    state = .paused
                }
                imageInput = MotionImageInput()
            }
        }

        return self
    }

    /// Start playback, if not yet prepared, will buffer first and then play.
    public func start() {
        guard let currentItem = currentItem else {
            return
        }

        setupPlayScene()

        switch currentItem {
        case .video(_):
            if let player = player {
//                rawImageView.isHidden = true
                if player.isPreparedToPlay {
                    if state == .completed && currentPlaybackTime != 0 {
                        seek(to: 0)
                    }
                    player.play()
                } else {
                    player.shouldAutoplay = true
                    player.prepareToPlay()
                    state = .buffering
                    stateOnPrepared = .playing
                }
            }
        case .mjpegPreview(let url):
            previewModel?.startPreview(url.absoluteString)
        case .image(let image):
            display(image: image)
        }
    }
    
    public func pause() {
        if let player = player {
            if player.isPreparedToPlay {
                player.pause()
            } else {
                player.shouldAutoplay = false
                state = .paused
                stateOnPrepared = .paused
            }
        }

        if let previewModel = previewModel {
            previewModel.stopPreviewIfConnected()
            state = .paused
        }
    }
    
    public func stop() {
        if let player = player {
            if player.isPreparedToPlay {
                player.stop()
            } else {
                player.shouldAutoplay = false
                stateOnPrepared = .stopped
            }
        }
        if let previewModel = previewModel {
            previewModel.stopPreviewIfConnected()
        }
        state = .stopped
    }


    /// Moves the playback cursor.
    /// - Parameter time: The time in seconds.
    ///
    /// If and only if `currentItem` is `WLVideoPlayerItem.video`, just work as expected.
    public func seek(to time: TimeInterval) {
        if !seekable {
            return
        }

        if player?.isPreparedToPlay == true {
            player?.currentPlaybackTime = max(0, min(duration, time))
        } else {
            playbackTimeOnPrepared = time
        }
    }

    /// Shut down the player and release resource.
    public func shutdown() {
        _shutdown()
        imageInput = nil
        previewModel?.shutdown()
        previewModel = nil
        source?.clear()
        source = nil
        library.switchInput(nil)
        library.clear()
        state = .unloaded
        stopTimer()
    }

    public func shutdownAndKeepCurrentFrameImage() {
        let lastFrameImage = thumbnailImageAtCurrentTime

        shutdown()

        if let lastFrameImage = lastFrameImage {
            replaceCurrentItem(with: .image(lastFrameImage)).start()
        }
    }

}

//MARK: - Private

private extension WLVideoPlayer {

    func dewarpParamsDidChange() {
        isInteractive = false

        switch dewarpParams.renderMode {
        case .split:
            library.switchProjection(.frontback)
        case .immersive(let direction):
            if let direction = direction {
                library.sharedDirection = direction
            }
            library.switchProjection(.perspective)
            isInteractive = true
        case .ball:
            library.switchProjection(.ball)
            isInteractive = true
        case .original:
            library.switchProjection(.raw)
        }

        library.switchTimestamp(dewarpParams.showTimeStamp, hasGPS: dewarpParams.showGPS)
        library.toggleFace(dewarpParams.rotate180Degrees)

        setupPlayScene()

        if let currentItem = currentItem {
            if case .image(let image) = currentItem {
                display(image: image)
            }
            else {
                let usingCustomGLView = infoOfPlayerDidSetup.usingCustomGLView
                let currentPlaybackTime = self.currentPlaybackTime

                setupPlayerAccordingToDewarpParamsIfNeeded()

                if let usingCustomGLView = usingCustomGLView, usingCustomGLView != infoOfPlayerDidSetup.usingCustomGLView {
                    player?.currentPlaybackTime = currentPlaybackTime
                    start()
                }
                else {
                    tick()
                }
            }
        }
    }

    func setupPlayScene() {
        switch dewarpParams.renderMode {
        case .split:
            displayView.isHidden = false
            rawImageView.isHidden = true
        case .immersive(_):
            displayView.isHidden = false
            rawImageView.isHidden = true
        case .ball:
            displayView.isHidden = false
            rawImageView.isHidden = true
        case .original:
            if let currentItem = currentItem {
                switch currentItem {
                case .video(_):
                    displayView.isHidden = true
                    rawImageView.isHidden = true
                case .mjpegPreview(_),
                     .image(_):
                    displayView.isHidden = true
                    rawImageView.isHidden = false
                }
            }
        }
    }

    func setupPlayerAccordingToDewarpParamsIfNeeded() {
        if case .video(let url) = currentItem {
            if dewarpParams.renderMode == .original {
                if !(infoOfPlayerDidSetup.url == url && infoOfPlayerDidSetup.usingCustomGLView == false) {
                    player?.shutdown()
                    if (player?.view.superview == displayView.superview) {
                        player?.view.removeFromSuperview()
                    }
                    player = nil

                    player = IJKFFMoviePlayerController.init(contentURL: url, with: options(forVideo: url))
                    if (player != nil) {
                        displayView.superview?.insertSubview(player!.view, aboveSubview: displayView)
                    }
                    player?.view.frame = displayView.superview?.bounds ?? displayView.bounds
                    player?.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    player?.view.translatesAutoresizingMaskIntoConstraints = true
                    player?.scalingMode = .aspectFit

                    infoOfPlayerDidSetup = (url: url, usingCustomGLView: false)

                    removeObservers()
                    installObservers()
                    IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
                }
            }
            else {
                if !(infoOfPlayerDidSetup.url == url && infoOfPlayerDidSetup.usingCustomGLView == true) {
                    player?.shutdown()
                    if (player?.view.superview == displayView.superview) {
                        player?.view.removeFromSuperview()
                    }
                    player = nil
                    
                    let adapter = IJKPlayerAdapter(frame: .zero)
                    player = IJKFFMoviePlayerController(moreContent: url, with: options(forVideo: url), withGLView: adapter)
                    library.switchInput(adapter)
                    source = adapter

                    infoOfPlayerDidSetup = (url: url, usingCustomGLView: true)

                    removeObservers()
                    installObservers()
                    IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
                }
            }
        }
    }

    func display(image: UIImage) {
        if dewarpParams.renderMode == .original {
            rawImageView.image = image
            naturalSize = image.size
        } else {
            if let source = source, !(source is MotionImageInput) {
                previousSource = source
            } else {
                previousSource = nil
            }

//            library.switchTimestamp(false, hasGPS: false)
            library.switchInput(imageInput)
            source = imageInput
            imageInput?.updateImage(image)
            naturalSize = Config.defaultNaturalSize
        }

        tick()
    }

    func _shutdown() {
        infoOfPlayerDidSetup = (url: nil, usingCustomGLView: nil)
        player?.shutdown()
        previewModel?.stopPreviewIfConnected()
        if (player?.view.superview == displayView.superview) {
            player?.view.removeFromSuperview()
        }
        player = nil
        selectedDuration = nil
        removeObservers()
    }

    func options(forVideo videoUrl: URL) -> IJKFFOptions {
        let scheme = videoUrl.scheme
        let isLive: Bool

        if let scheme = scheme {
            isLive = scheme.hasPrefix("rtmp") || scheme.hasPrefix("rtsp")
        } else {
            isLive = false
        }

        let options = IJKFFOptions.byDefault()!
        options.setPlayerOptionIntValue(1, forKey: "videotoolbox")
        options.setPlayerOptionIntValue(1, forKey: "framedrop")
        options.setPlayerOptionIntValue(3, forKey: "video-pictq-size")
        options.setPlayerOptionIntValue(1, forKey: "fast")
        options.setPlayerOptionIntValue(2048, forKey: "videotoolbox-max-frame-width")
        options.setPlayerOptionIntValue(0, forKey: "an")
        options.setPlayerOptionIntValue(1, forKey: "packet-buffering")

        options.setFormatOptionValue("Waylens Secure360 iOS", forKey: "user_agent")

        if isLive {
            options.setPlayerOptionIntValue(500 * 1024, forKey: "max-buffer-size")
            options.setPlayerOptionIntValue(1, forKey: "infbuf")

            options.setFormatOptionIntValue(0, forKey: "timeout")
            options.setFormatOptionIntValue(400 * 1024, forKey: "probesize")
            options.setFormatOptionIntValue(400 * 1024, forKey: "formatprobesize")
            options.setFormatOptionIntValue(1000 * 1000, forKey: "analyzeduration")
            options.setFormatOptionIntValue(10, forKey: "fpsprobesize")
            options.setFormatOptionIntValue(10, forKey: "max_ts_probe")
            if scheme?.hasPrefix("rtsp") ?? false {
                options.setPlayerOptionIntValue(1, forKey: "an")
                options.setFormatOptionValue("tcp", forKey: "rtsp_transport")
                options.setPlayerOptionIntValue(100000, forKey: "max_delay")

            } else if scheme?.hasPrefix("rtmp") ?? false {
                options.setFormatOptionIntValue(1000, forKey: "rtmp_buffer")
                options.setFormatOptionValue("live", forKey: "rtmp_live")
                options.setFormatOptionValue("HornWaylensiOS", forKey: "rtmp_flashver")
                options.setFormatOptionIntValue(0, forKey: "sync-av-start")
            }
        } else {
            options.setPlayerOptionIntValue(10 * 1024 * 1024, forKey: "max-buffer-size")
            options.setPlayerOptionIntValue(50, forKey: "min-frames")
            options.setPlayerOptionIntValue(0, forKey: "infbuf")

            options.setFormatOptionIntValue(30 * 1000 * 1000, forKey: "timeout")
        }

        if let cookies = HTTPCookieStorage.shared.cookies(for: videoUrl) { // set cookie to pass access restriction
            let headers = HTTPCookie.requestHeaderFields(with: cookies)
            let header = "Cookie: \(headers["Cookie"] ?? "")"
            if !videoUrl.isFileURL {
                options.setFormatOptionValue(header, forKey: "headers")
            }
        }

        return options
    }

    func installObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)

        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)

        NotificationCenter.default.addObserver(self, selector: #selector(moviePlaybackDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)

        NotificationCenter.default.addObserver(self, selector: #selector(movieDidSeekComplete(_:)), name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: player)

        NotificationCenter.default.addObserver(self, selector: #selector(movieDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func checkProgress() {
        if state == .playing && duration > 0.01 && currentPlaybackTime >= duration {
            isConsideredAsCompleted = true
            shouldCheckProgress = false
            pause()
        }
    }

    func checkTimer() {
        if isActive && (isInteractive || state == .playing) {  // shoud start timer
            startTimer()
        } else {
            stopTimer()
        }
    }

    func startTimer() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            if #available(iOS 10.0, *) {
                displayLink?.preferredFramesPerSecond = 25
            }
            displayLink?.add(to: .main, forMode: .common)
        }
    }

    func stopTimer() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
        library.interactiveManager?.stopTimer()
    }

    @objc func tick() {
        source?.tick()
        if shouldCheckProgress {
            checkProgress()
        }
    }

    // MARK: - Notifications

    @objc func loadStateDidChange(_ sender: Notification) {
        guard player === sender.object as? IJKMediaPlayback else { return }
        if loadState.contains(.stalled) && state == .playing {
            state = .buffering
        }
    }

    @objc func mediaIsPreparedToPlayDidChange(_ sender: Notification) {
        guard player === sender.object as? IJKMediaPlayback else { return }
        if stateOnPrepared == .paused {
            pause()
        } else if stateOnPrepared == .stopped {
            stop()
            stateOnPrepared = nil
            return
        } else if stateOnPrepared == .playing {
            start()
        }
        stateOnPrepared = nil
        if playbackTimeOnPrepared > 0 {
            seek(to: playbackTimeOnPrepared)
            playbackTimeOnPrepared = 0
        }

        if let naturalSize = player?.naturalSize {
            if dewarpParams.renderMode == .original {
                self.naturalSize = naturalSize
            } else {
                self.naturalSize = Config.defaultNaturalSize
            }
        }
    }

    @objc func moviePlaybackDidChange(_ sender: Notification) {
        guard let player = player, player === sender.object as? IJKMediaPlayback else { return }
        switch player.playbackState {
        case .interrupted:
            state = .stopped
        case .stopped:
            if isConsideredAsCompleted {
                state = .completed
            } else if state != .completed && state != .error {
                state = .stopped
            }
        case .paused:
            if isConsideredAsCompleted {
                state = .completed
            } else if state != .completed {
                state = .paused
            }
        case .playing:
            state = .playing
            if previousSource != nil, source is MotionImageInput {
                library.switchInput(previousSource)
                source = previousSource
            }
        case .seekingForward, .seekingBackward:
            state = .buffering
        default:
            break
        }
    }

    @objc func movieDidSeekComplete(_ sender: Notification) {
        guard player === sender.object as? IJKMediaPlayback else { return }

    }

    @objc func movieDidFinish(_ sender: Notification) {
        guard player === sender.object as? IJKMediaPlayback else { return }
        if let value = sender.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber {
            if value.intValue == IJKMPMovieFinishReason.playbackEnded.rawValue {
                state = .completed
            } else if value.intValue == IJKMPMovieFinishReason.playbackError.rawValue {
                state = .error
            }
        }
    }

}

extension WLVideoPlayer: LocalPreviewViewModelDelegate {

    func updateImage(_ image: UIImage) {
        if dewarpParams.renderMode == .original {
            rawImageView.image = image
            state = .playing
            naturalSize = image.size
        } else {
            if let imageInput = source as? MotionImageInput {
                imageInput.updateImage(image)
                state = .playing
            }
            naturalSize = Config.defaultNaturalSize
        }
    }

    func needPower2Size() -> Bool {
        return dewarpParams.renderMode != .original
    }

}

extension WLVideoPlayer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        library.updateOutputSize(size)
    }

    public func draw(in view: MTKView) {
        view.draw(view.bounds)
    }
}
