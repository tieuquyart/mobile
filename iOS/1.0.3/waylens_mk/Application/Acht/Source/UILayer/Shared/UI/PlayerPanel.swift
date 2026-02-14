//
//  HNPlayerPanel.swift
//  Acht
//
//  Created by Chester Shen on 6/15/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK
import WaylensVideoSDK

class PlayerPanel: UIViewController {
    @IBOutlet weak var videoArea: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var dmsInfoArea: UIView!
    @IBOutlet weak var dmsInfoLabel: UILabel!
    @IBOutlet weak var dmsFace: UIImageView!
    @IBOutlet weak var blurView: VisualEffectView!
    @IBOutlet weak var leftEyeLabel: UILabel!
    @IBOutlet weak var rightEyeLabel: UILabel!
    @IBOutlet weak var pictureBottomConstraint: NSLayoutConstraint!


    weak var delegate: HNPlayerPanelDelegate?
    
    var refreshSpeedTimer: WLTimer?
    var startDate: Date?
    var viaWiFi = false
    
    var isHighlightCardShown = false
    var canHighlight = true

    var showDMSInfo = true

    private(set) var currentResolution = HNVideoResolution.spliced

    private var _duration: TimeInterval?
    var duration: TimeInterval {
        get {
            return _duration ?? (playSource != .localLive ? videoPlayer?.duration : nil) ?? 0
        }
        
        set {
            _duration = newValue
            controlView.updateUI()
        }

    }
    
    var startOffset: TimeInterval = 0
    var allowThumbnail: Bool {
        return playState != .playing && playSource != .localLive
    }
    var rawThumbnail: UIImage? {
        didSet {
            if allowThumbnail {
                if let image = rawThumbnail {
                    videoPlayer?.replaceCurrentItem(with: WLVideoPlayerItem.image(image)).start()
                    thumbnail.isHidden = true
                    videoArea.isHidden = false
                } else {
                    // TODO: clear the screen
                }
            }
        }
    }

    var currentPlayTime: TimeInterval {
        return (videoPlayer?.currentPlaybackTime ?? 0) + startOffset
    }

    var playSource: HNPlaySource = .none {
        didSet {
            refreshThumbnail()
            view.setNeedsLayout()
            
            if playSource == .none {
                videoArea.isHidden = true
            }
            
            if oldValue != playSource {
                delegate?.playerDidChange(source: playSource)
            }
            controlView.updateUI()
            updateStatusOverlay(withLiveStatus: UnifiedCameraManager.shared.current?.remote?.liveStatus)
        }
    }
    
    var playState: HNPlayState = .unloaded {
        didSet {
            Log.debug("play state did set: \(playState)")
            refreshThumbnail()
            
            if playState == .unloaded || playState == .stopped || playState == .paused || playState == .completed { // to play
                
            } else { // to pause
                if playSource == .remoteLive {
                    refreshSpeedTimer?.start()
                }
            }
            if oldValue != playState {
                delegate?.playerDidChange(playState)
            }
            if playState == .playing || playState == .buffering {
                myIdleTimerManager.instance().myIdleTimerAdd(self)
            } else {
                myIdleTimerManager.instance().myIdleTimerRemove(self)
            }
            
            controlView.updateUI()
            updateStatusOverlay(withLiveStatus: UnifiedCameraManager.shared.current?.remote?.liveStatus)
        }
    }

    var isLocalRecording = false
    
    var fullScreen = false {
        didSet {
            view.setNeedsUpdateConstraints()
            controlView.updateUI()
        }
    }
    
    var viewMode: HNViewMode = .frontBack {
        didSet {
            videoPlayer?.dewarpParams.renderMode = .original// viewMode.renderMode
            controlView.updateUI()
        }
    }
    private(set) var videoPlayer: WLVideoPlayer?
    
    let controlView: HNPlayerControlView
    
    weak var timeLineHorizontalView: CameraTimeLineHorizontalView? {
        didSet {
            if let timeLineHorizontalView = timeLineHorizontalView {
                controlView.addTimeLineHorizontalView(timeLineHorizontalView)
            } else {
                controlView.removeTimeLineHorizontalView()
            }
        }
    }
    
    var isPlayBarCoveredVideo: Bool = false {
        didSet {
            view.setNeedsUpdateConstraints()
        }
    }

    var isMuted: Bool = false {
        didSet {
            if isMuted {

            } else {

            }
        }
    }

    private var _supportViewMode: Bool = true
    var supportViewMode : Bool {
        get {
            return _supportViewMode
        }

        set {
            _supportViewMode = newValue
            //controlView.showViewModeButton(_supportViewMode)
            if _supportViewMode == false {
                viewMode = .raw
            } else {
                viewMode = .frontBack
            }
        }
    }

    private weak var originalSuperView: UIView?
    private weak var originalParent: UIViewController?
    private var visible = false
    private var playerExptectedToBePlaying: Bool = false
    private var streamResolutions : Array<HNVideoResolution> = [.hd, .sd]
    private var dmsFacePoints = Array<CALayer>()
    private var dmsFaceLines  = Array<CAShapeLayer>()

    init(controlView: HNPlayerControlView) {
        self.controlView = controlView
        super.init(nibName: String(describing: PlayerPanel.self), bundle : nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initVideoPlayer() {
        videoPlayer = WLVideoPlayer(container: videoArea)
        videoPlayer?.delegate = self
        videoPlayer?.dewarpParams.renderMode = .original// viewMode.renderMode
        videoPlayer?.dewarpParams.rotate180Degrees = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         view.addSubview(controlView)
         reset()
         initVideoPlayer()
        
        print("thanh image" , thumbnail.image ?? "")	
//
//        leftEyeLabel.textColor = .white
//        leftEyeLabel.textAlignment = .center
//        leftEyeLabel.adjustsFontSizeToFitWidth = true
//        leftEyeLabel.numberOfLines = 1
//        leftEyeLabel.minimumScaleFactor = 0.1
//        leftEyeLabel.clipsToBounds = false
//        leftEyeLabel.baselineAdjustment = .alignCenters
//        rightEyeLabel.textColor = UIColor.white
//        rightEyeLabel.textAlignment = .center
//        rightEyeLabel.adjustsFontSizeToFitWidth = true
//        rightEyeLabel.numberOfLines = 1
//        rightEyeLabel.minimumScaleFactor = 0.1
//        rightEyeLabel.clipsToBounds = false
//        rightEyeLabel.baselineAdjustment = .alignCenters
//
//        leftEyeLabel.layer.removeFromSuperlayer()
//        rightEyeLabel.layer.removeFromSuperlayer()
//        dmsFace.layer.addSublayer(leftEyeLabel.layer)
//        dmsFace.layer.addSublayer(rightEyeLabel.layer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
        shutdown()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        controlView.frame = view.bounds
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        updatePlayerContainingViewHeightConstraint()
        if fullScreen {
            pictureBottomConstraint.constant = 0
        } else {
            if isPlayBarCoveredVideo {
                pictureBottomConstraint.constant = 0
            } else {
                pictureBottomConstraint.constant = -HNPortraitControlView.playBarHeight
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func addToParentViewController(_ parent: UIViewController, superView: UIView) {
        self.originalSuperView = superView
        self.originalParent = parent
        self.moveToParentViewController(parent, superView: superView)
        self.view.frame = superView.bounds
        view.setNeedsUpdateConstraints()
    }
    
    func setBlurred(_ level: CGFloat) {
        if level == 0 {
            blurView.isHidden = true
        } else {
            blurView.isHidden = false
            blurView.blurRadius = level * 10
        }
    }
    
    func refreshThumbnail() {
        if playState == .unloaded && rawThumbnail == nil {
            thumbnail.isHidden = false
        }
        if playState == .playing {
            thumbnail.isHidden = true
            videoArea.isHidden = false
        }
    }
    
    func isPlayingOrPreparing(_ source:HNPlaySource = .none) -> Bool {
        let playing = playState == .playing || playState == .buffering
        return (source == .none && playing) || (playSource == source && playing)
    }
    
    func playLocalLive(_ url:String?, isRecording:Bool) {
        print("playLocalLive")
        dmsInfoArea.isHidden = true
        guard let urlstring = url, let url = URL(string: urlstring) else {
            return
        }
        playSource = .localLive
        isLocalRecording = isRecording
        videoPlayer?.replaceCurrentItem(with: .mjpegPreview(url: url)).start()
      
    }

    
    func stopLocalLive() {
        videoPlayer?.stop()
    }
    
    func playRemoteLive(_ url:String?) {
        print("playRemoteLive")
        dmsInfoArea.isHidden = true
        guard let urlstring = url, let url = URL(string: urlstring) else {
            return
        }
        playSource = .remoteLive
        videoPlayer?.replaceCurrentItem(with: .video(url: url)).start()
    }
    
    func playVideo(_ url:String?, playbackTime:TimeInterval=0, startOffset:TimeInterval=0) {
        print("playVideo")
        dmsInfoArea.isHidden = true
        guard let urlstring = url else {
            return
        }
        var mUrl : URL?
        if url!.hasPrefix("/") {
            mUrl = URL.init(fileURLWithPath: urlstring)
        } else {
            mUrl = URL(string: urlstring)
        }
        if playSource == .localLive {
            stopLocalLive()
        }
        guard let url = mUrl else {
            return
        }
        videoPlayer?.replaceCurrentItem(with: .video(url: url)).start()

        self.startOffset = startOffset
        if playbackTime - startOffset > 0 {
            self.videoPlayer?.seek(to: playbackTime - startOffset)
        }
    }
    
    func setFacedown(_ down: Bool) {
        videoPlayer?.dewarpParams.rotate180Degrees = down
    }
    
    func shutdown() {
        stop()
        videoPlayer?.shutdown()
    }
    
    func stop() {
        if videoPlayer?.state == .stopped {
            playState = .stopped
        } else if videoPlayer?.state != .error {
            videoPlayer?.stop()
        }
    }
    
    func pause() {
        if playState != .paused {
            videoPlayer?.pause()
            playState = .paused
        }
    }
    
    func resume() {
        if playState == .paused {
            videoPlayer?.start()
        }
    }
    
    //    func seek() {
    //        if playState != .seeking {
    //            videoPlayer?.pause()
    //            playState = .seeking
    //        }
    //    }
    
    func reset() {
        rawThumbnail = nil
        thumbnail.image = nil
        playState = .unloaded
        fullScreen = false
        playSource = .none
        viewMode = .frontBack
        startOffset = 0
        setBlurred(0)
        showDMSInfo = true
        dmsInfoArea.isHidden = true

        canHighlight = false
        isHighlightCardShown = false
        controlView.updateUI()
        playerExptectedToBePlaying = false
    }
    
    func refreshSpeed(kbps: Int) {
        if isPlayingOrPreparing(.remoteLive) {
            controlView.transferRateLabels.setText("\(kbps)k/s")
        }
    }
    
    func showTime(_ date: Date) {
        if fullScreen {
            controlView.showTime(date)
        }
    }
    
    func showTimePointInfo(_ timePointInfo: HNTimePointInfo) {
        if fullScreen {
            controlView.showTimePointInfo(timePointInfo)
        }
    }
    
    @objc func hidePlayerControls() {
        controlView.hideControlView()
        delegate?.showControls(show: false, duration: 0.4)
    }
    
    func showPlayerControls() {
        controlView.showControlView()
        delegate?.showControls(show: true, duration: 0.4)
    }
    
    func togglePlayerControlsDisplay() {
        if controlView.controlViewAppeared {
            hidePlayerControls()
        } else {
            showPlayerControls()
        }
    }

    func showResolutionButton(_ show: Bool, streams : Array<String>?) {
        if ((streams == nil) || (streams?.count == 0)) {
            controlView.showResolutionButton(show, streams: -1)
            return
        }
        streamResolutions = HNVideoResolution.parse(streams!)

        if streamResolutions.contains(currentResolution) == false {
            if streams!.count > 2 && streamResolutions.contains(.spliced) {
                currentResolution = .spliced
            } else {
                currentResolution = streamResolutions.first!
            }
        }

        delegate?.onResolution(currentResolution, index: streamResolutions.firstIndex(of: currentResolution)!)
        controlView.showResolutionButton(show, streams: streamResolutions.count)
    }
    
    func showHighlightButton(_ show: Bool) {
        canHighlight = show
        if show && isHighlightCardShown {
            isHighlightCardShown = false
        }
        controlView.updateUI()
    }
    
    func showHighlightCard() {
        isHighlightCardShown = true
        controlView.updateUI()
    }
    
    func hideHighlightCard() {
        isHighlightCardShown = false
        controlView.updateUI()
    }
    
    func onSnapshot() {
        delegate?.onSnapshot()
    }
    
    func onHighlight() {
        delegate?.onHighlight()
    }
    
    func onHighlightCard() {
        delegate?.onHighlightCard()
    }
    
    @objc func onPlay() {
        if (playState == .playing || playState == .buffering) {
            playerExptectedToBePlaying = false
            delegate?.onPlay(false)
        } else {
            playerExptectedToBePlaying = true
            delegate?.onPlay(true)
        }
    }
    
    @objc func onReload() {
        playerExptectedToBePlaying = true
        delegate?.onPlay(true)
    }
    
    func onSwitchViewMode() {
        if _supportViewMode == false {
            showDMSInfo = !showDMSInfo
            return
        }
        if viewMode == .frontBack {
            viewMode = .panorama
        } else {
            viewMode = .frontBack
        }
        delegate?.onViewMode(viewMode)
    }
    
    func onFullScreen() {
        fullScreen = !fullScreen
        delegate?.onFullScreen(fullScreen)
    }
    
    func onSwitchResoluttion() {
        if viewMode == .raw {
            hidePlayerControls()
            presentSwitchStreamSheet(items: streamResolutions.sorted{$0.rawValue < $1.rawValue}) { [weak self] (selectedResolution) in
                guard let self = self else {
                    return
                }

                self.currentResolution = selectedResolution
                self.delegate?.onResolution(self.currentResolution, index: self.streamResolutions.firstIndex(of: self.currentResolution)!)
            }
        }
        else {
            let index = streamResolutions.firstIndex(of: currentResolution)!
            if index >= streamResolutions.count-1 {
                currentResolution = streamResolutions[0]
            } else {
                currentResolution = streamResolutions[index + 1]
            }
            delegate?.onResolution(currentResolution, index: streamResolutions.firstIndex(of: currentResolution)!)
        }
    }

    func onDMSFace() {
        delegate?.onDMSFace()
    }

    #if !FLEET
    func onMicButtonTouchStateChange(_ micButton: UIButton) {
        delegate?.onMicButtonTouchStateChange(micButton)
    }
    #endif
    
    @IBAction func onTapScreen(_ sender: Any) {
        if controlView.controlViewAppeared {
            hidePlayerControls()
        } else {
            showPlayerControls()
        }
    }
    
    // MARK: - Notifications
    @objc func handleAppDidEnterBackgroundNotification() {
        shutdown()
    }
    
}

extension PlayerPanel: WLVideoPlayerDelegate {

    func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState) {
        Log.info("panorma player state \(state)")

        switch state {
        case .buffering:
            playState = .buffering
        case .playing:
            playState = .playing
        case .paused:
            break // always triggered by user
        case .stopped:
            playState = .stopped
        case .unloaded:
            playState = .unloaded
        case .completed:
            playState = .completed
        case .error:
            playState = .error
        @unknown default:
            break
        }
    }

    func player(_ player: WLVideoPlayer, aspectRatioDidChange aspectRatio: CGFloat) {
        updatePlayerContainingViewHeightConstraint()
    }

}

extension PlayerPanel {
    
    private func moveToParentViewController(_ parent: UIViewController, superView: UIView) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        superView.addSubview(self.view)
        parent.addChild(self)
        self.didMove(toParent: parent)
    }
    
    fileprivate func updatePlayerContainingViewHeightConstraint() {
        guard let playerContainingView = view.superview else {
            return
        }

        if fullScreen {
            playerContainingView.heightConstraint?.constant = UIScreen.main.bounds.shorterEdge
        } else {
            var aspectRatio: CGFloat = 16.0 / 9.0

            if let videoPlayer = videoPlayer {
                aspectRatio = videoPlayer.naturalSize.width / videoPlayer.naturalSize.height
            }

            playerContainingView.heightConstraint?.constant = UIScreen.main.bounds.shorterEdge / CGFloat(aspectRatio) + (isPlayBarCoveredVideo ? 0.0 : HNPortraitControlView.playBarHeight)
        }

        playerContainingView.superview?.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [UIView.AnimationOptions.allowUserInteraction], animations: {
            playerContainingView.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension PlayerPanel {
    
    enum PlayerPanelStatusOverlay {
        case playButton
        case reloadButton(message: String?)
        case messageLabel(message: String)
        case busyIndicator(message: String?)
    }
    
    private struct AssociatedKeys {
        static var overlayStackView: UInt8 = 18
        static var busyIndicator: UInt8    = 28
        static var messageLabel: UInt8     = 38
        static var playButton: UInt8       = 48
        static var reloadButton: UInt8     = 58
    }
    
    private var overlayStackView: UIStackView {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.overlayStackView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var stackView = objc_getAssociatedObject(self, &AssociatedKeys.overlayStackView) as? UIStackView
            
            if stackView == nil {
                stackView = UIStackView()
                stackView!.axis = .vertical
                stackView!.alignment = .center
                stackView!.distribution = .equalCentering
                stackView!.translatesAutoresizingMaskIntoConstraints = false
                stackView!.spacing = 8.0
                
                stackView!.isHidden = true
                
                objc_setAssociatedObject(self, &AssociatedKeys.overlayStackView, stackView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return stackView!
        }
    }
    
    private var busyIndicator: WLActivityIndicator {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.busyIndicator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var indicator = objc_getAssociatedObject(self, &AssociatedKeys.busyIndicator) as? WLActivityIndicator
            
            if indicator == nil {
                indicator = WLActivityIndicator(frame: CGRect.zero)
                indicator!.hidesWhenStopped = true
                indicator!.isLight = true
                indicator!.translatesAutoresizingMaskIntoConstraints = false
                indicator!.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
                indicator!.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                
                indicator!.isHidden = true
                
                objc_setAssociatedObject(self, &AssociatedKeys.busyIndicator, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return indicator!
        }
    }
    
    private var messageLabel: UILabel {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.messageLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var label = objc_getAssociatedObject(self, &AssociatedKeys.messageLabel) as? UILabel
            
            if label == nil {
                label = UILabel()
                label!.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
                label!.textAlignment = .natural
                label!.textColor = UIColor.white
                label!.numberOfLines = 1
                
                objc_setAssociatedObject(self, &AssociatedKeys.messageLabel, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return label!
        }
    }
    
    private var playButton: UIButton {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.playButton, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var button = objc_getAssociatedObject(self, &AssociatedKeys.playButton) as? UIButton
            
            if button == nil {
                button = UIButton(type: UIButton.ButtonType.custom)
                button?.setImage(#imageLiteral(resourceName: "play_button_big"), for: UIControl.State.normal)
                button?.setImage(#imageLiteral(resourceName: "play_button_big_blue"), for: UIControl.State.highlighted)
                button?.addTarget(self, action: #selector(onPlay), for: UIControl.Event.touchUpInside)
                
                objc_setAssociatedObject(self, &AssociatedKeys.playButton, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return button!
        }
    }
    
    private var reloadButton: UIButton {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.reloadButton, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var button = objc_getAssociatedObject(self, &AssociatedKeys.reloadButton) as? UIButton
            
            if button == nil {
                button = UIButton(type: UIButton.ButtonType.custom)
                button?.setImage(#imageLiteral(resourceName: "btn_retry_normal"), for: UIControl.State.normal)
                button?.setImage(#imageLiteral(resourceName: "btn_retry_highlight"), for: UIControl.State.highlighted)
                button?.addTarget(self, action: #selector(onReload), for: UIControl.Event.touchUpInside)
                
                objc_setAssociatedObject(self, &AssociatedKeys.reloadButton, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return button!
        }
    }
    
    func hideDMSFaceButton(hide : Bool){
        controlView.hideDMSFaceButton(hide: hide)
    }
    
    func updateStatusOverlay(withLiveStatus liveStatus: HNLiveStatus? = nil) {
        switch (playSource, playState, liveStatus) {
        case (.localLive, .buffering, _):
            fallthrough
        case (.localPlayback, .buffering, _):
            fallthrough
        case (.remotePlayback, .buffering, _):
            showStatusOverlay(.busyIndicator(message: nil), blurBackground: false)
        case (.remoteLive, .playing, .some(.waitForStop)):
            fallthrough
        case (.remoteLive, .buffering, .some(.stopped)):
            showStatusOverlay(.busyIndicator(message: nil), blurBackground: false)
        case (.remoteLive, .buffering, .some(.offline)):
            fallthrough
        case (.remoteLive, .stopped, .some(.timeout)):
            showStatusOverlay(.reloadButton(message: liveStatus?.message))
        case (.remoteLive, .buffering, _):
            showStatusOverlay(.busyIndicator(message: liveStatus?.message), blurBackground: false)
        case (.remoteLive, .unloaded, _):
            fallthrough
        case (.remoteLive, .paused, _):
            fallthrough
        case (.remoteLive, .stopped, _):
            fallthrough
        case (.remoteLive, .completed, _):
            if (playState == .stopped || playState == .completed) && playerExptectedToBePlaying {
                showStatusOverlay(.reloadButton(message: HNLiveStatus.stopped.message))
            } else {
                showStatusOverlay(.playButton)
            }
        case (.remoteLive, .error, _):
            showStatusOverlay(.reloadButton(message: NSLocalizedString("Failed to play!", comment: "Failed to play!")))
        case (.offline, playState, _):
            showStatusOverlay(.messageLabel(message: NSLocalizedString("Oops! Your camera is offline now.", comment: "Oops! Your camera is offline now.")))
        default:
            hideStatusOverlay()
        }
    }
    
    private func showStatusOverlay(_ statusOverlay: PlayerPanelStatusOverlay, blurBackground: Bool = true) {
        if blurBackground {
            setBlurred(1.0)
        } else {
            setBlurred(0.0)
        }
        
        overlayStackView.arrangedSubviews.forEach({ (subview) in
            subview.removeFromSuperview()
        })
        overlayStackView.removeAllArrangedSubviews()
        
        switch statusOverlay {
        case .playButton:
            overlayStackView.addArrangedSubview(playButton)
        case .reloadButton(let message):
            messageLabel.text = (message != nil ? message! : nil)
            messageLabel.sizeToFit()
            overlayStackView.addArrangedSubview(reloadButton)
            overlayStackView.addArrangedSubview(messageLabel)
        case .messageLabel(let message):
            messageLabel.text = message
            messageLabel.sizeToFit()
            overlayStackView.addArrangedSubview(messageLabel)
        case .busyIndicator(let message):
            busyIndicator.startAnimating()
            messageLabel.text = (message != nil ? message! : nil)
            messageLabel.sizeToFit()
            overlayStackView.addArrangedSubview(busyIndicator)
            overlayStackView.addArrangedSubview(messageLabel)
        }
        
        if !view.subviews.contains(overlayStackView) {
            view.addSubview(overlayStackView)
            overlayStackView.centerXAnchor.constraint(equalTo: videoArea.centerXAnchor).isActive = true
            overlayStackView.centerYAnchor.constraint(equalTo: videoArea.centerYAnchor).isActive = true
        }
        
        overlayStackView.isHidden = false
        overlayStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        view.bringSubviewToFront(overlayStackView)
    }
    
    private func hideStatusOverlay() {
        if !overlayStackView.isHidden {
            setBlurred(0.0)
            
            busyIndicator.stopAnimating()
            overlayStackView.isHidden = true
        }
    }
    
}

extension PlayerPanel {

    private func titleAttribute() -> [NSAttributedString.Key : Any] {
        return [ .foregroundColor : UIColor(rgb: 0xC5C5C5, a: 1.0),
                 .strokeWidth : -0.1,
                 .strokeColor : UIColor.black,
                 .font : UIFont(name: "BeVietnamPro-Regular", size: view.bounds.height/36)!]
    }
    private func normalAttribute() -> [NSAttributedString.Key : Any] {
        return [ .foregroundColor : UIColor.white,
                 .strokeWidth : -0.1,
                 .strokeColor : UIColor.black,
                 .font : UIFont(name: "BeVietnamPro-Bold", size: view.bounds.height/36)!]
    }
    private func highLightAttribute() -> [NSAttributedString.Key : Any] {
        return [ .foregroundColor : UIColor(rgb: 0x4EAEE3, a: 1.0),
                 .strokeWidth : -0.1,
                 .strokeColor : UIColor.black,
                 .font : UIFont(name: "BeVietnamPro-Bold", size: view.bounds.height/36)! ]
    }
    private func warnAttribute() -> [NSAttributedString.Key : Any] {
        return [ .foregroundColor : UIColor(rgb: 0xff7000, a: 1.0),
                 .strokeWidth : -0.1,
                 .strokeColor : UIColor.black,
                 .font :UIFont(name: "BeVietnamPro-Bold", size: view.bounds.height/36)! ]
    }

    func updateDmsInfo(dms: readsense_dms_data_v2_t?, with recordConfig: String!) {
      //  print("updateDmsInfo : thanh")
        if dms != nil {
            let dmsInfo = dms?.v1
            let faceInfo = dms?.face
            var name : String?
            if faceInfo != nil {
                let nameMirror = Mirror(reflecting: faceInfo!.name)
                name = nameMirror.children.reduce("") { name, element in
                    guard let value = element.value as? UInt8, value != 0 else {
                        return name
                    }
                    return name! + String(UnicodeScalar(UInt8(value)))
                }
            }

            let dmsLabel = NSMutableAttributedString()
            dmsInfoArea.isHidden = !showDMSInfo
            if (dmsInfo!.header.nitems == 0 ||
                dmsInfo!.header.nitems > 10) {
                dmsLabel.append(NSAttributedString.init(string: "No Driver\n\n", attributes: warnAttribute()))
                dmsInfoLabel.attributedText = dmsLabel
                dmsFace.isHidden = true
            } else {

                dmsLabel.append(NSAttributedString.init(string: String(format:"Face Direction\n"), attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: String(format:"%0.0f,%0.0f,%0.0f\n",
                                                                       dmsInfo!.items.fyaw,
                                                                       dmsInfo!.items.fpitch,
                                                                       dmsInfo!.items.froll),
                                                        attributes: normalAttribute()))
                dmsLabel.append(NSAttributedString.init(string: String(format:"Eye Direction\n"), attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: String(format:"%0.0f,%0.0f,%0.0f\n\n",
                                                                       dmsInfo!.items.fyaw_gaze,
                                                                       dmsInfo!.items.fpitch_gaze,
                                                                       dmsInfo!.items.froll_gaze),
                                                        attributes: normalAttribute()))

                dmsLabel.append(NSAttributedString.init(string: "Wearing Glasses:\n",
                                                        attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: (dmsInfo!.items._b_glass != 0) ? "Yes\n" : "No\n",
                                                        attributes: (dmsInfo!.items._b_glass != 0) ? highLightAttribute() : normalAttribute()))
                dmsLabel.append(NSAttributedString.init(string: "Eye Status:\n",
                                                        attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: (dmsInfo!.items.b_open_eye != 0) ? "Open\n" : "Closed\n",
                                                        attributes: (dmsInfo!.items.b_open_eye != 0) ? normalAttribute() : warnAttribute()))
                dmsLabel.append(NSAttributedString.init(string: "Yawning:\n",
                                                        attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: (dmsInfo!.items.b_open_mouth != 0) ? "Yes\n" : "No\n",
                                                        attributes: (dmsInfo!.items.b_open_mouth != 0) ? warnAttribute() : normalAttribute()))
                dmsLabel.append(NSAttributedString.init(string: "Attention:\n",
                                                        attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: (dmsInfo!.items._b_attention != 0) ? "Focusing\n" : "Lost\n",
                                                        attributes: (dmsInfo!.items._b_attention != 0) ? highLightAttribute() : warnAttribute()))
                dmsLabel.append(NSAttributedString.init(string: "\nDrowsiness:\n",
                                                        attributes: titleAttribute()))
                dmsLabel.append(NSAttributedString.init(string: (dmsInfo!.items._b_drawsy != 0) ? "Yes\n" : "No\n",
                                                        attributes: (dmsInfo!.items._b_drawsy != 0) ? warnAttribute() : normalAttribute()))
                dmsLabel.append(NSAttributedString.init(string: "Behavior:\n",
                                                        attributes: titleAttribute()))
                if (dmsInfo!.items.b_phone != 0) {
                    dmsLabel.append(NSAttributedString.init(string: "Calling\n",
                                                            attributes: warnAttribute()))
                } else if (dmsInfo!.items.b_water != 0) {
                    dmsLabel.append(NSAttributedString.init(string: "Drinking\n",
                                                            attributes: warnAttribute()))
                } else if (dmsInfo!.items.b_smoke != 0) {
                    dmsLabel.append(NSAttributedString.init(string: "Smoking\n",
                                                            attributes: warnAttribute()))
                } else {
                    dmsLabel.append(NSAttributedString.init(string: "None\n",
                                                            attributes: normalAttribute()))
                }

                dmsLabel.append(NSAttributedString.init(string: "\nDriver:\n",
                                                        attributes: titleAttribute()))

                if (faceInfo != nil) && (faceInfo!.faceid != 0) && (name != nil) {
                    dmsLabel.append(NSAttributedString.init(string: name!,
                                                            attributes: highLightAttribute()))

                } else {
                    dmsLabel.append(NSAttributedString.init(string: "Unidentified\n\n\n",
                                                            attributes: warnAttribute()))
                }

//                dmsInfoLabel.font = UIFont(name: "whitney", size: 14)
                dmsInfoLabel.attributedText = dmsLabel
                dmsInfoLabel.layer.shadowColor = UIColor.darkGray.cgColor
                dmsInfoLabel.layer.shadowOpacity = 0.6
                dmsInfoLabel.layer.shadowRadius = 1.0
//                dmsInfoLabel.sizeToFit()

                var points = Array<CGPoint>()
                let pointsMirror = Mirror(reflecting: dmsInfo!.items.vec_points)
                if ((currentResolution == .dms) && (playSource == .localPlayback) && (playState != .stopped)) {
                    let viewSize = dmsFace.frame.size
                    let imageSize = CGSize(width: 1280, height: 800)
                    let aspectRatio = CGFloat(1280.0/800.0)
                    var leftPending = 0.0
                    var topPending = 0.0
                    var texureSize = viewSize
                    if (viewSize.width/viewSize.height > aspectRatio) {
                        texureSize.width = aspectRatio * viewSize.height
                        leftPending = Double((viewSize.width - texureSize.width) / 2)
                    }
                    if (viewSize.width/viewSize.height < aspectRatio) {
                        texureSize.height = viewSize.width / aspectRatio
                        topPending = Double((viewSize.height - texureSize.height) / 2)
                    }
                    _ = pointsMirror.children.reduce("") { _, element in
                        let (x, y) = (element.value as? (Float, Float))!
                        let point = CGPoint(x: Double(x) * Double(texureSize.width / imageSize.width) + leftPending,
                                            y: Double(y) * Double(texureSize.height / imageSize.height) + topPending)
                        points.append(point)
                        return ""
                    }
                } else if ((playSource == .localLive) || (playState == .stopped) ||
                    ((currentResolution == .sd || currentResolution == .spliced) && (playSource == .localPlayback) && (playState != .stopped))) {
                    let viewSize = dmsFace.frame.size
                    let imageSize = CGSize(width: 1280, height: 800)
                    let aspectRatio = CGFloat(1280.0/1280.0)
                    var leftPending = 0.0
                    var topPending = 0.0
                    var texureSize = viewSize
                    if (viewSize.width/viewSize.height > aspectRatio) {
                        texureSize.width = aspectRatio * viewSize.height
                        leftPending = Double((viewSize.width - texureSize.width) / 2)
                    }
                    if (viewSize.width/viewSize.height <= aspectRatio) {
                        texureSize.height = aspectRatio * viewSize.width
                        topPending = Double((viewSize.height - texureSize.height) / 2)
                    }
                    //
                    let interPending = texureSize.height * 480/1280
                    texureSize.height -= interPending
                    //topPending += Double(interPending)
                    _ = pointsMirror.children.reduce("") { _, element in
                        let (x, y) = (element.value as? (Float, Float))!
                        let point = CGPoint(x: Double(x) * Double(texureSize.width / imageSize.width) + leftPending,
                                            y: Double(y) * Double(texureSize.height / imageSize.height) + topPending)
                        points.append(point)
                        return ""
                    }
                }
                if (points.count == 68) {
                    updateFacePoints(points,
                                     mouth: (dmsInfo!.items.b_open_mouth != 0),
                                     eye: (dmsInfo!.items.b_open_eye != 0),
                                     fp: CGFloat(Double(dmsInfo!.items.fpitch) * pi / 180.0),
                                     fr: CGFloat(Double(dmsInfo!.items.froll) * pi / 180.0),
                                     fy: CGFloat(Double(dmsInfo!.items.fyaw) * pi / 180.0),
                                     ep: CGFloat(Double(dmsInfo!.items.fpitch_gaze) * pi / 180.0),
                                     er: CGFloat(Double(dmsInfo!.items.froll_gaze) * pi / 180.0),
                                     ey: CGFloat(Double(dmsInfo!.items.fyaw_gaze) * pi / 180.0))
                    dmsFace.isHidden = false
                } else {
                    dmsFace.isHidden = true
                }
            }
        } else {
            dmsInfoArea.isHidden = true
        }
    }

    func updateDmsESInfo(_ dmsData: WLDmsData?, with recordConfig: String!) {
        dmsInfoArea.isHidden = !showDMSInfo

        guard let dmsData = dmsData else {
            dmsInfoArea.isHidden = true
            return
        }

        let dmsLabel = NSMutableAttributedString()

        if !dmsData.isDriverValid {
            dmsLabel.append(NSAttributedString.init(string: "No Driver\n\n", attributes: warnAttribute()))
            dmsInfoLabel.attributedText = dmsLabel
            dmsFace.isHidden = true
            leftEyeLabel.text = ""
            rightEyeLabel.text = ""
            return
        }

        dmsData.displayItems().forEach { (child) in
           // print("thanh child ",child.label)
            guard let label = child.label else {
                return
            }

//            dmsLabel.append(NSAttributedString.init(string: label, attributes: titleAttribute()))
//            dmsLabel.append(NSAttributedString.init(string: "\n\(NSLocalizedString(label , comment: "text")): ", attributes: titleAttribute()))
            dmsLabel.append(NSAttributedString.init(string: "\n\(label.wl.titleCase()): ", attributes: titleAttribute()))
//            let unknownSub = NSLocalizedString("Unknown", comment: "Unknown")
            let unknownSub = "Unknown"
            switch child.value {
            case is Bool:
                if let boolValue = child.value as? Bool {
                    dmsLabel.append(NSAttributedString.init(string: boolValue.yesNoString(), attributes: boolValue ? highLightAttribute() : normalAttribute()))
                }
                else {
                    dmsLabel.append(NSAttributedString.init(string: unknownSub, attributes: normalAttribute()))
                }
            case is String:
                if let stringValue = child.value as? String {
                 //   print("dms stringValue",stringValue)
                    dmsLabel.append(NSAttributedString.init(string: stringValue, attributes: normalAttribute()))
                }
                else {
                    dmsLabel.append(NSAttributedString.init(string: unknownSub , attributes: normalAttribute()))
                }
            case is Float:
                if let floatValue = child.value as? Float {
                    dmsLabel.append(NSAttributedString.init(string: "\(floatValue)", attributes: normalAttribute()))
                }
                else {
                    dmsLabel.append(NSAttributedString.init(string: unknownSub , attributes: normalAttribute()))
                }
            case is Int:
                if let intValue = child.value as? Float {
                    dmsLabel.append(NSAttributedString.init(string: "\(intValue)", attributes: normalAttribute()))
                }
                else {
                    dmsLabel.append(NSAttributedString.init(string: unknownSub , attributes: normalAttribute()))
                }
            default:
                dmsLabel.append(NSAttributedString.init(string: unknownSub , attributes: normalAttribute()))
            }
        }

        dmsInfoLabel.attributedText = dmsLabel
        dmsInfoLabel.layer.shadowColor = UIColor.darkGray.cgColor
        dmsInfoLabel.layer.shadowOpacity = 0.6
        dmsInfoLabel.layer.shadowRadius = 1.0

        if (currentResolution == .dms) || (currentResolution == .spliced) {
            dmsFace.isHidden = false
            drawDriverHeadWireFrame(with: dmsData, recordConfig: recordConfig)
        }
        else {
            dmsFace.isHidden = true
        }
    }
    
    
    func drawDriverHeadWireFrame(with dmsData: WLDmsData, recordConfig: String) {
        func dms_x_2_src_from(x: Float) -> Double {
            return Double(dmsData.inputOffset.x) + Double(x) / Double(dmsData.resolution.width) * Double(dmsData.inputResolution.width)
        }
        func dms_y_2_src_from(y: Float) -> Double {
            return Double(dmsData.inputOffset.y) + Double(y) / Double(dmsData.resolution.height) * Double(dmsData.inputResolution.height)
        }

        let pathOutBox = UIBezierPath()
        pathOutBox.lineWidth = 2
        pathOutBox.lineCapStyle = .round
        pathOutBox.lineJoinStyle = .round

        // outbox + 2eyes positions
        var points = Array<CGPoint>()
        var srcPoints = Array<CGPoint>()
        srcPoints.append(CGPoint(x: CGFloat(dmsData.rawHeadRect.origin.x - dmsData.rawHeadRect.size.width*0), y: CGFloat(dmsData.rawHeadRect.origin.y - dmsData.rawHeadRect.size.width/2)))
        srcPoints.append(CGPoint(x: CGFloat(dmsData.rawHeadRect.origin.x + dmsData.rawHeadRect.size.width/1), y: CGFloat(dmsData.rawHeadRect.origin.y - dmsData.rawHeadRect.size.width/2)))
        srcPoints.append(CGPoint(x: CGFloat(dmsData.rawHeadRect.origin.x + dmsData.rawHeadRect.size.width/1), y: CGFloat(dmsData.rawHeadRect.origin.y + dmsData.rawHeadRect.size.width/2)))
        srcPoints.append(CGPoint(x: CGFloat(dmsData.rawHeadRect.origin.x - dmsData.rawHeadRect.size.width*0), y: CGFloat(dmsData.rawHeadRect.origin.y + dmsData.rawHeadRect.size.width/2)))


        if ((currentResolution == .dms) && (playSource == .localPlayback) && (playState != .stopped)) {
            let viewSize = dmsFace.frame.size
            let imageSize = CGSize(width: CGFloat(dmsData.srcResolution.width),
                                   height: CGFloat(dmsData.srcResolution.height))
            let aspectRatio = CGFloat(CGFloat(dmsData.srcResolution.width)/CGFloat(dmsData.srcResolution.height))
            var leftPending = Double(0.0)
            var topPending = Double(0.0)
            var texureSize = viewSize

            if (viewSize.width/viewSize.height > aspectRatio) {
                texureSize.width = aspectRatio * viewSize.height
                leftPending = Double((viewSize.width - texureSize.width) / 2)
            }

            if (viewSize.width/viewSize.height < aspectRatio) {
                texureSize.height = viewSize.width / aspectRatio
                topPending = Double((viewSize.height - texureSize.height) / 2)
            }

            for p in srcPoints {
                var point = CGPoint(x: dms_x_2_src_from(x: Float(p.x)) * Double(texureSize.width / imageSize.width) + leftPending,
                                    y: dms_y_2_src_from(y: Float(p.y)) * Double(texureSize.height / imageSize.height) + topPending)
                if  point.x < -viewSize.width { point.x = -viewSize.width }
                if  point.y < -viewSize.height { point.y = -viewSize.height }
                if point.x > viewSize.width*2 { point.x = viewSize.width*2 }
                if point.y > viewSize.height*2 { point.y = viewSize.height*2 }
                if (point.x == CGFloat.nan || point.y == CGFloat.nan ||
                        point.x == CGFloat.signalingNaN ||  point.y == CGFloat.signalingNaN ||
                        point.x == CGFloat.greatestFiniteMagnitude ||
                        point.y == CGFloat.greatestFiniteMagnitude) {
                    points.removeAll()
                    break
                }
                points.append(point)
            }
        } else if ((playSource == .localLive) || (playState == .stopped) ||
                    (((currentResolution == .sd) || (currentResolution == .spliced)) && (playSource == .localPlayback) && (playState != .stopped))) {
            enum eRenderMode {
                case demoVideo
                case calibPreview
                case standard
                case unknown
            }

            var renderMode : eRenderMode = .unknown

            if (playSource == .localLive) {
                if (recordConfig == "DEMO") {
                    renderMode = .demoVideo
                } else if (recordConfig == "STANDARD") {
                    renderMode = .standard
                } else {
                    if (isLocalRecording) {
                        renderMode = .standard
                    } else {
                        renderMode = .calibPreview
                    }
                }
            } else if (recordConfig == "STANDARD") {
                renderMode = .standard
            } else if (recordConfig == "DEMO") {
                renderMode = .demoVideo
            } else {
                renderMode = .standard
            }

            switch renderMode {
            case .unknown:
                break
            case .standard:
                let viewSize = dmsFace.frame.size
                let imageSize = CGSize(width: 1280, height: 960)
                let aspectRatio = CGFloat(1280.0/1080.0)
                var leftPending = 0.0
                var topPending = 0.0
                var texureSize = viewSize
                if (viewSize.width/viewSize.height > aspectRatio) {
                    texureSize.width = aspectRatio * viewSize.height
                    leftPending = Double((viewSize.width - texureSize.width) / 2)
                } else if (viewSize.width/viewSize.height <= aspectRatio) {
                    texureSize.height = viewSize.width / aspectRatio
                    topPending = Double((viewSize.height - texureSize.height) / 2)
                }

                leftPending += Double(texureSize.width) * 680.0/1280.0
                topPending += Double(texureSize.height) * 640.0/1080.0
                texureSize.width *= 640.0/1280.0
                texureSize.height *= 480.0/1080.0

                for p in srcPoints {
                    var point = CGPoint(x: dms_x_2_src_from(x: Float(p.x)) * Double(texureSize.width / imageSize.width) + leftPending,
                                        y: dms_y_2_src_from(y: Float(p.y)) * Double(texureSize.height / imageSize.height) + topPending)
                    if  point.x < -viewSize.width { point.x = -viewSize.width }
                    if  point.y < -viewSize.height { point.y = -viewSize.height }
                    if point.x > viewSize.width*2 { point.x = viewSize.width*2 }
                    if point.y > viewSize.height*2 { point.y = viewSize.height*2 }
                    if (point.x == CGFloat.nan || point.y == CGFloat.nan ||
                            point.x == CGFloat.signalingNaN ||  point.y == CGFloat.signalingNaN ||
                            point.x == CGFloat.greatestFiniteMagnitude ||
                            point.y == CGFloat.greatestFiniteMagnitude) {
                        points.removeAll()
                        break
                    }
                    points.append(point)
                }
                break
            case .demoVideo:
                let viewSize = dmsFace.frame.size
                let imageSize = CGSize(width: 1280, height: 800)
                let aspectRatio = CGFloat(1280.0/1280.0)
                var leftPending = 0.0
                var topPending = 0.0
                var texureSize = viewSize
                if (viewSize.width/viewSize.height > aspectRatio) {
                    texureSize.width = aspectRatio * viewSize.height
                    leftPending = Double((viewSize.width - texureSize.width) / 2)
                } else if (viewSize.width/viewSize.height <= aspectRatio) {
                    texureSize.height = viewSize.width / aspectRatio
                    topPending = Double((viewSize.height - texureSize.height) / 2)
                }

                let interPending = texureSize.height * 480/1280
                texureSize.height -= interPending
                //topPending += Double(interPending)
                for p in srcPoints {
                    var point = CGPoint(x: dms_x_2_src_from(x: Float(p.x)) * Double(texureSize.width / imageSize.width) + leftPending,
                                        y: dms_y_2_src_from(y: Float(p.y)) * Double(texureSize.height / imageSize.height) + topPending)
                    if  point.x < -viewSize.width { point.x = -viewSize.width }
                    if  point.y < -viewSize.height { point.y = -viewSize.height }
                    if point.x > viewSize.width*2 { point.x = viewSize.width*2 }
                    if point.y > viewSize.height*2 { point.y = viewSize.height*2 }
                    if (point.x == CGFloat.nan || point.y == CGFloat.nan ||
                            point.x == CGFloat.signalingNaN ||  point.y == CGFloat.signalingNaN ||
                            point.x == CGFloat.greatestFiniteMagnitude ||
                            point.y == CGFloat.greatestFiniteMagnitude) {
                        points.removeAll()
                        break
                    }
                    points.append(point)
                }
                break
            case .calibPreview:
                let viewSize = dmsFace.frame.size
                let imageSize = CGSize(width: 1280, height: 800)
                let aspectRatio = CGFloat(1280.0/1160.0)
                var leftPending = 0.0
                var topPending = 0.0
                var texureSize = viewSize
                if (viewSize.width/viewSize.height > aspectRatio) {
                    texureSize.width = aspectRatio * viewSize.height
                    leftPending = Double((viewSize.width - texureSize.width) / 2)
                } else if (viewSize.width/viewSize.height <= aspectRatio) {
                    texureSize.height = viewSize.width / aspectRatio
                    topPending = Double((viewSize.height - texureSize.height) / 2)
                }

                let interPending = texureSize.height * 360/1280
                texureSize.height -= interPending
                //topPending += Double(interPending)
                for p in srcPoints {
                    var point = CGPoint(x: dms_x_2_src_from(x: Float(p.x)) * Double(texureSize.width / imageSize.width) + leftPending,
                                        y: dms_y_2_src_from(y: Float(p.y)) * Double(texureSize.height / imageSize.height) + topPending)
                    if  point.x < -viewSize.width { point.x = -viewSize.width }
                    if  point.y < -viewSize.height { point.y = -viewSize.height }
                    if point.x > viewSize.width*2 { point.x = viewSize.width*2 }
                    if point.y > viewSize.height*2 { point.y = viewSize.height*2 }
                    if (point.x == CGFloat.nan || point.y == CGFloat.nan ||
                            point.x == CGFloat.signalingNaN ||  point.y == CGFloat.signalingNaN ||
                            point.x == CGFloat.greatestFiniteMagnitude ||
                            point.y == CGFloat.greatestFiniteMagnitude) {
                        points.removeAll()
                        break
                    }
                    points.append(point)
                }
                break
            }
        }

        if (points.count < 4) {
            return
        }
        // else
        let tl = CGPoint(x: points[0].x, y: points[0].y)
        let tr = CGPoint(x: points[1].x, y: points[1].y)
        let bl = CGPoint(x: points[2].x, y: points[2].y)
        let br = CGPoint(x: points[3].x, y: points[3].y)

        pathOutBox.move(to: tl)
        pathOutBox.addLine(to: tr)
        pathOutBox.addLine(to: bl)
        pathOutBox.addLine(to: br)
        pathOutBox.close()

        for layer in dmsFaceLines {
            layer.removeFromSuperlayer()
        }
        dmsFaceLines.removeAll()
        for layer in dmsFacePoints {
            layer.removeFromSuperlayer()
        }

        let layerOutBox = CAShapeLayer()
        layerOutBox.isGeometryFlipped = false
        layerOutBox.fillColor = UIColor.clear.cgColor
        layerOutBox.lineWidth = 2
        dmsFace.layer.addSublayer(layerOutBox)
        dmsFaceLines.append(layerOutBox)

        // box
        dmsFaceLines[0].bounds = pathOutBox.bounds
        dmsFaceLines[0].position = CGPoint(x: (points[0].x + points[3].x)/2, y: (points[0].y + points[3].y)/2)
        dmsFaceLines[0].path = pathOutBox.cgPath
        dmsFaceLines[0].strokeColor = UIColor.white.cgColor
        dmsFaceLines[0].transform = CATransform3DRotate(CATransform3DIdentity, dmsData.headAngle, 0, 0, 1)
    }

    private func addPoint(_ point: CGPoint, size: CGFloat, color: CGColor) {
        let layer = CALayer()
        layer.backgroundColor = color
        layer.position = point
        layer.bounds = CGRect.init(x: -size/2, y: -size/2, width: size, height: size)
        layer.cornerRadius = 0
        dmsFace.layer.addSublayer(layer)
        dmsFacePoints.append(layer)
    }
    private func updateLines(_ line: Array<CGPoint>, mouth: Bool, eye: Bool, fp: CGFloat, fr: CGFloat, fy: CGFloat, ep: CGFloat, er: CGFloat, ey: CGFloat) {
        if line.count < 68 {
            return
        }
        var pos1 = line[0]
        var pos2 = line[0]
        var center = line[0]
        for i in 0...35 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        center.x = (pos1.x + pos2.x)/2
        center.y = (pos1.y + pos2.y)/2

        pos1 = line[49]
        pos2 = line[49]
        var centerMouth = line[49]
        for i in 48...67 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        centerMouth.x = (pos1.x + pos2.x)/2
        centerMouth.y = (pos1.y + pos2.y)/2

        pos1 = line[36]
        pos2 = line[36]
        var centerEyes = line[36]
        for i in 36...47 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        centerEyes.x = (pos1.x + pos2.x)/2
        centerEyes.y = (pos1.y + pos2.y)/2

        let path = UIBezierPath()
        path.lineWidth = 1
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        let pathMouth = UIBezierPath()
        pathMouth.lineWidth = 1
        pathMouth.lineCapStyle = .round
        pathMouth.lineJoinStyle = .round
        let pathEyes = UIBezierPath()
        pathEyes.lineWidth = 1
        pathEyes.lineCapStyle = .round
        pathEyes.lineJoinStyle = .round

        let pathFaceDir = UIBezierPath()
        pathFaceDir.lineWidth = 2
        pathFaceDir.lineCapStyle = .round
        pathFaceDir.lineJoinStyle = .round
        let pathEyeDirL = UIBezierPath()
        pathEyeDirL.lineWidth = 2
        pathEyeDirL.lineCapStyle = .round
        pathEyeDirL.lineJoinStyle = .round
        let pathEyeDirR = UIBezierPath()
        pathEyeDirR.lineWidth = 2
        pathEyeDirR.lineCapStyle = .round
        pathEyeDirR.lineJoinStyle = .round

        let pathOutBox = UIBezierPath()
        pathOutBox.lineWidth = 2
        pathOutBox.lineCapStyle = .round
        pathOutBox.lineJoinStyle = .round

        // face
        path.move(to: line[0])
        for i in 1...16 {
            path.addLine(to: line[i])
        }
        // brows
        path.move(to: line[17])
        for i in 18...21 {
            path.addLine(to: line[i])
        }
        path.move(to: line[22])
        for i in 23...26 {
            path.addLine(to: line[i])
        }
        let centerBrows = CGPoint(x: (line[19].x + line[24].x)/2, y: (line[19].y + line[24].y)/2)

        // nose
        path.move(to: line[27])
        for i in 28...30 {
            path.addLine(to: line[i])
        }
        path.move(to: line[31])
        for i in 32...35 {
            path.addLine(to: line[i])
        }

        // eye
        pathEyes.move(to: line[36])
        for i in 37...41 {
            pathEyes.addLine(to: line[i])
        }
        pathEyes.addLine(to: line[36])
        pathEyes.move(to: line[42])
        for i in 43...47 {
            pathEyes.addLine(to: line[i])
        }
        pathEyes.addLine(to: line[42])

        // mouth
        pathMouth.move(to: line[48])
        for i in 49...59 {
            pathMouth.addLine(to: line[i])
        }
        pathMouth.addLine(to: line[48])
        pathMouth.move(to: line[60])
        for i in 61...67 {
            pathMouth.addLine(to: line[i])
        }
        pathMouth.addLine(to: line[60])

        // directions
        let length = path.bounds.height / 2
        //pathFaceDir, hide
        let pathMouthY = length * sin(-fp)
        let pathMouthX = length * sin(-fy)
        var MouthEnd = line[30]
        let centerPathMouth = CGPoint(x: MouthEnd.x + pathMouthX/2, y: MouthEnd.y + pathMouthY/2)
        pathFaceDir.move(to: MouthEnd)
        MouthEnd.x += pathMouthX
        MouthEnd.y += pathMouthY
        pathFaceDir.addLine(to: MouthEnd)
        //pathEyeDir
        let pathEyeDirLY = length * sin(-ep)
        let pathEyeDirLX = length * sin(-ey)
        var pathEyeDirLEnd = CGPoint(x: (line[42].x + line[45].x)/2, y: (line[42].y + line[45].y)/2)
        let centerpathEyeDirL = CGPoint(x: pathEyeDirLEnd.x + pathEyeDirLX/2, y: pathEyeDirLEnd.y + pathEyeDirLY/2)
        pathEyeDirL.move(to: pathEyeDirLEnd)
        addPoint(pathEyeDirLEnd, size: 3, color: UIColor.white.cgColor)
        pathEyeDirLEnd.x += pathEyeDirLX
        pathEyeDirLEnd.y += pathEyeDirLY
        pathEyeDirL.addLine(to: pathEyeDirLEnd)

        // pathEye
        let pathEyeDirRY = length * sin(-ep)
        let pathEyeDirRX = length * sin(-ey)
        var pathEyeDirREnd = CGPoint(x: (line[36].x + line[39].x)/2, y: (line[36].y + line[39].y)/2)
        let centerpathEyeDirR = CGPoint(x: pathEyeDirREnd.x + pathEyeDirRX/2, y: pathEyeDirREnd.y + pathEyeDirRY/2)
        pathEyeDirR.move(to: pathEyeDirREnd)
        addPoint(pathEyeDirREnd, size: 3, color: UIColor.white.cgColor)
        pathEyeDirREnd.x += pathEyeDirRX
        pathEyeDirREnd.y += pathEyeDirRY
        pathEyeDirR.addLine(to: pathEyeDirREnd)
        // outbox
        let centerBox1 = CGPoint(x: (centerBrows.x + line[30].x)/2, y: (centerBrows.y + line[30].y)/2)
        let centerBox2 = CGPoint(x: (line[30].x + line[8].x)/2, y: (line[30].y + line[8].y)/2)
        let centerBox = CGPoint(x: (centerBox1.x + centerBox2.x)/2, y: (centerBox1.y + centerBox2.y)/2)
        let h_2 = sqrt((centerBrows.x - centerBox.x) * (centerBrows.x - centerBox.x) + (centerBrows.y - centerBox.y) * (centerBrows.y - centerBox.y)) * 1.1
        let w_2 = sqrt((line[17].x - line[26].x) * (line[17].x - line[26].x) + (line[17].y - line[26].y) * (line[17].y - line[26].y)) * 0.55
        let factor = CGFloat(0.7)
        let arcsize = CGFloat(2.0)
        let tlb = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y + h_2 * factor))
        let tl = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y + h_2))
        let tlr = CGPoint(x: (centerBox.x - w_2 * factor), y: (centerBox.y + h_2))
        let tlbb = CGPoint(x: tl.x, y: (tl.y - (tl.y - tlb.y)/arcsize))
        let tlrr = CGPoint(x: (tl.x + (tlr.x - tl.x)/arcsize), y: tl.y)

        let trl = CGPoint(x: (centerBox.x + w_2 * factor), y: (centerBox.y + h_2))
        let tr = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y + h_2))
        let trb = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y + h_2 * factor))
        let trbb = CGPoint(x: tr.x, y: (tr.y - (tr.y - trb.y)/arcsize))
        let trll = CGPoint(x: (tr.x + (trl.x - tr.x)/arcsize), y: tr.y)

        let blt = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y - h_2 * factor))
        let bl = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y - h_2))
        let blr = CGPoint(x: (centerBox.x - w_2 * factor), y: (centerBox.y - h_2))
        let bltt = CGPoint(x: bl.x, y: (bl.y - (bl.y - blt.y)/arcsize))
        let blrr = CGPoint(x: (bl.x + (blr.x - bl.x)/arcsize), y: bl.y)

        let brl = CGPoint(x: (centerBox.x + w_2 * factor), y: (centerBox.y - h_2))
        let br = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y - h_2))
        let brt = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y - h_2 * factor))
        let brtt = CGPoint(x: br.x, y: (br.y - (br.y - brt.y)/arcsize))
        let brll = CGPoint(x: (br.x + (brl.x - br.x)/arcsize), y: br.y)

        pathOutBox.move(to: tlb)
        pathOutBox.addLine(to: tlbb)
        pathOutBox.addCurve(to: tlrr, controlPoint1: tl, controlPoint2: tl)
        pathOutBox.addLine(to: tlr)
        pathOutBox.move(to: trl)
        pathOutBox.addLine(to: trll)
        pathOutBox.addCurve(to: trbb, controlPoint1: tr, controlPoint2: tr)
        pathOutBox.addLine(to: trb)
        pathOutBox.move(to: blt)
        pathOutBox.addLine(to: bltt)
        pathOutBox.addCurve(to: blrr, controlPoint1: bl, controlPoint2: bl)
        pathOutBox.addLine(to: blr)
        pathOutBox.move(to: brl)
        pathOutBox.addLine(to: brll)
        pathOutBox.addCurve(to: brtt, controlPoint1: br, controlPoint2: br)
        pathOutBox.addLine(to: brt)

        if dmsFaceLines.count != 7 {
            for layer in dmsFaceLines {
                layer.removeFromSuperlayer()
            }
            dmsFaceLines.removeAll()
        }
        if dmsFaceLines.count == 0 {
            let layer = CAShapeLayer()
            layer.isGeometryFlipped = false
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layer, below: dmsFacePoints[0])
            dmsFaceLines.append(layer)

            let layerMouth = CAShapeLayer()
            layerMouth.isGeometryFlipped = false
            layerMouth.fillColor = UIColor.clear.cgColor
            layerMouth.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layerMouth, below: dmsFacePoints[0])
            dmsFaceLines.append(layerMouth)

            let layerEyes = CAShapeLayer()
            layerEyes.isGeometryFlipped = false
            layerEyes.fillColor = UIColor.clear.cgColor
            layerEyes.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layerEyes, below: dmsFacePoints[0])
            dmsFaceLines.append(layerEyes)

            let layerPathMouth = CAShapeLayer()
            layerPathMouth.isGeometryFlipped = false
            layerPathMouth.fillColor = UIColor.clear.cgColor
            layerPathMouth.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathMouth, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathMouth)

            let layerPathEyeDirL = CAShapeLayer()
            layerPathEyeDirL.isGeometryFlipped = false
            layerPathEyeDirL.fillColor = UIColor.clear.cgColor
            layerPathEyeDirL.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathEyeDirL, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathEyeDirL)
            let layerPathEyeDirR = CAShapeLayer()
            layerPathEyeDirR.isGeometryFlipped = false
            layerPathEyeDirR.fillColor = UIColor.clear.cgColor
            layerPathEyeDirR.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathEyeDirR, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathEyeDirR)

            let layerOutBox = CAShapeLayer()
            layerOutBox.isGeometryFlipped = false
            layerOutBox.fillColor = UIColor.clear.cgColor
            layerOutBox.lineWidth = 2
            dmsFace.layer.insertSublayer(layerOutBox, below: dmsFacePoints[0])
            dmsFaceLines.append(layerOutBox)
        }
        let normalColor = UIColor(rgb: 0x5fa8d6).cgColor
        let warnColor = UIColor.init(rgb: 0xfe5000, a: 0.8).cgColor
        dmsFaceLines[0].bounds = path.bounds
        dmsFaceLines[0].position = center
        dmsFaceLines[0].path = path.cgPath
        dmsFaceLines[0].strokeColor = normalColor
        // mouth
        dmsFaceLines[1].bounds = pathMouth.bounds
        dmsFaceLines[1].position = centerMouth
        dmsFaceLines[1].path = pathMouth.cgPath
        dmsFaceLines[1].strokeColor = mouth ? warnColor : normalColor
        // eyes
        dmsFaceLines[2].bounds = pathEyes.bounds
        dmsFaceLines[2].position = centerEyes
        dmsFaceLines[2].path = pathEyes.cgPath
        dmsFaceLines[2].strokeColor = eye ? normalColor : warnColor

        // direction
        dmsFaceLines[3].bounds = pathFaceDir.bounds
        dmsFaceLines[3].position = centerPathMouth
        dmsFaceLines[3].path = pathFaceDir.cgPath
        dmsFaceLines[3].strokeColor = UIColor.clear.cgColor
        // eyeL
        dmsFaceLines[4].bounds = pathEyeDirL.bounds
        dmsFaceLines[4].position = centerpathEyeDirL
        dmsFaceLines[4].path = pathEyeDirL.cgPath
        dmsFaceLines[4].strokeColor = UIColor(rgb: 0x74E4A1).cgColor
        // eyeR
        dmsFaceLines[5].bounds = pathEyeDirR.bounds
        dmsFaceLines[5].position = centerpathEyeDirR
        dmsFaceLines[5].path = pathEyeDirR.cgPath
        dmsFaceLines[5].strokeColor = UIColor(rgb: 0x74E4A1).cgColor
        // box
        dmsFaceLines[6].bounds = pathOutBox.bounds
        dmsFaceLines[6].position = centerBox
        dmsFaceLines[6].path = pathOutBox.cgPath
        dmsFaceLines[6].strokeColor = UIColor.white.cgColor
        dmsFaceLines[6].transform = CATransform3DRotate(CATransform3DRotate(CATransform3DMakeRotation(-fp, 1, 0, 0), fy, 0, 1, 0), fr, 0, 0, 1)
    }
    private func updateESLines(_ line: Array<CGPoint>,
                               mouth: Bool,
                               eyeL: Bool, eyeLPct: Int, eyeLp: Int, eyeLy: Int,
                               eyeR: Bool, eyeRPct: Int, eyeRp: Int, eyeRy: Int,
                               fp: CGFloat, fr: CGFloat, fy: CGFloat) {
        if line.count < 68 {
            return
        }
        var pos1 = line[0]
        var pos2 = line[0]
        var center = line[0]
        for i in 0...35 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        center.x = (pos1.x + pos2.x)/2
        center.y = (pos1.y + pos2.y)/2
        let faceheight = pos2.y - pos1.y

        pos1 = line[49]
        pos2 = line[49]
        var centerMouth = line[49]
        for i in 48...67 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        centerMouth.x = (pos1.x + pos2.x)/2
        centerMouth.y = (pos1.y + pos2.y)/2

        pos1 = line[36]
        pos2 = line[36]
        var centerEyeL = line[36]
        for i in 36...41 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        centerEyeL.x = (pos1.x + pos2.x)/2
        centerEyeL.y = (pos1.y + pos2.y)/2

        pos1 = line[42]
        pos2 = line[42]
        var centerEyeR = line[42]
        for i in 42...47 {
            let p = line[i]
            if p.x < pos1.x {
                pos1.x = p.x
            }
            if p.y < pos1.y {
                pos1.y = p.y
            }
            if p.x > pos2.x {
                pos2.x = p.x
            }
            if p.y > pos2.y {
                pos2.y = p.y
            }
        }
        centerEyeR.x = (pos1.x + pos2.x)/2
        centerEyeR.y = (pos1.y + pos2.y)/2

        let labelwidth = faceheight / 5.0
        let labelheigh = labelwidth * 0.6
        leftEyeLabel.frame = CGRect.init(x: centerEyeL.x - labelwidth, y: centerEyeL.y + labelheigh/2, width: labelwidth, height: labelheigh)
        rightEyeLabel.frame = CGRect.init(x: centerEyeR.x + 0, y: centerEyeR.y + labelheigh/2, width: labelwidth, height: labelheigh)

        let path = UIBezierPath()
        path.lineWidth = 1
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        let pathMouth = UIBezierPath()
        pathMouth.lineWidth = 1
        pathMouth.lineCapStyle = .round
        pathMouth.lineJoinStyle = .round
        let pathEyeL = UIBezierPath()
        pathEyeL.lineWidth = 1
        pathEyeL.lineCapStyle = .round
        pathEyeL.lineJoinStyle = .round
        let pathEyeR = UIBezierPath()
        pathEyeR.lineWidth = 1
        pathEyeR.lineCapStyle = .round
        pathEyeR.lineJoinStyle = .round

        let pathFaceDir = UIBezierPath()
        pathFaceDir.lineWidth = 2
        pathFaceDir.lineCapStyle = .round
        pathFaceDir.lineJoinStyle = .round
        let pathEyeDirL = UIBezierPath()
        pathEyeDirL.lineWidth = 2
        pathEyeDirL.lineCapStyle = .round
        pathEyeDirL.lineJoinStyle = .round
        let pathEyeDirR = UIBezierPath()
        pathEyeDirR.lineWidth = 2
        pathEyeDirR.lineCapStyle = .round
        pathEyeDirR.lineJoinStyle = .round

        let pathOutBox = UIBezierPath()
        pathOutBox.lineWidth = 2
        pathOutBox.lineCapStyle = .round
        pathOutBox.lineJoinStyle = .round

        // face
        path.move(to: line[0])
        for i in 1...16 {
            path.addLine(to: line[i])
        }
        // brows
        path.move(to: line[17])
        for i in 18...21 {
            path.addLine(to: line[i])
        }
        path.move(to: line[22])
        for i in 23...26 {
            path.addLine(to: line[i])
        }
        let centerBrows = CGPoint(x: (line[19].x + line[24].x)/2, y: (line[19].y + line[24].y)/2)

        // nose
        path.move(to: line[27])
        for i in 28...30 {
            path.addLine(to: line[i])
        }
        path.move(to: line[31])
        for i in 32...35 {
            path.addLine(to: line[i])
        }

        // eye
        pathEyeL.move(to: line[36])
        for i in 37...41 {
            pathEyeL.addLine(to: line[i])
        }
        pathEyeL.addLine(to: line[36])
        pathEyeR.move(to: line[42])
        for i in 43...47 {
            pathEyeR.addLine(to: line[i])
        }
        pathEyeR.addLine(to: line[42])

        // mouth
        pathMouth.move(to: line[48])
        for i in 49...59 {
            pathMouth.addLine(to: line[i])
        }
        pathMouth.addLine(to: line[48])
        pathMouth.move(to: line[60])
        for i in 61...67 {
            pathMouth.addLine(to: line[i])
        }
        pathMouth.addLine(to: line[60])

        // directions
        let length = path.bounds.height
        //pathFaceDir, hide
        let pathMouthY = length * sin(-fp)
        let pathMouthX = length * sin(-fy)
        var MouthEnd = line[30]
        let centerPathMouth = CGPoint(x: MouthEnd.x + pathMouthX/2, y: MouthEnd.y + pathMouthY/2)
        pathFaceDir.move(to: MouthEnd)
        MouthEnd.x += pathMouthX
        MouthEnd.y += pathMouthY
        pathFaceDir.addLine(to: MouthEnd)
        //pathEyeLDir
        let pathEyeDirLY = length * sin(CGFloat(-eyeLp)/180.0)
        let pathEyeDirLX = length * sin(CGFloat(-eyeLy)/180.0)
        var pathEyeDirLEnd = CGPoint(x: (line[42].x + line[45].x)/2, y: (line[42].y + line[45].y)/2)
        let centerpathEyeDirL = CGPoint(x: pathEyeDirLEnd.x + pathEyeDirLX/2, y: pathEyeDirLEnd.y + pathEyeDirLY/2)
        pathEyeDirL.move(to: pathEyeDirLEnd)
        addPoint(pathEyeDirLEnd, size: 3, color: UIColor.white.cgColor)
        pathEyeDirLEnd.x += pathEyeDirLX
        pathEyeDirLEnd.y += pathEyeDirLY
        pathEyeDirL.addLine(to: pathEyeDirLEnd)

        // pathEye
        let pathEyeDirRY = length * sin(CGFloat(-eyeRp)/180.0)
        let pathEyeDirRX = length * sin(CGFloat(-eyeRy)/180.0)
        var pathEyeDirREnd = CGPoint(x: (line[36].x + line[39].x)/2, y: (line[36].y + line[39].y)/2)
        let centerpathEyeDirR = CGPoint(x: pathEyeDirREnd.x + pathEyeDirRX/2, y: pathEyeDirREnd.y + pathEyeDirRY/2)
        pathEyeDirR.move(to: pathEyeDirREnd)
        addPoint(pathEyeDirREnd, size: 3, color: UIColor.white.cgColor)
        pathEyeDirREnd.x += pathEyeDirRX
        pathEyeDirREnd.y += pathEyeDirRY
        pathEyeDirR.addLine(to: pathEyeDirREnd)
        // outbox
        let centerBox1 = CGPoint(x: (centerBrows.x + line[30].x)/2, y: (centerBrows.y + line[30].y)/2)
        let centerBox2 = CGPoint(x: (line[30].x + line[8].x)/2, y: (line[30].y + line[8].y)/2)
        let centerBox = CGPoint(x: (centerBox1.x + centerBox2.x)/2, y: (centerBox1.y + centerBox2.y)/2)
        let h_2 = sqrt((centerBrows.x - centerBox.x) * (centerBrows.x - centerBox.x) + (centerBrows.y - centerBox.y) * (centerBrows.y - centerBox.y)) * 1.1
        let w_2 = sqrt((line[17].x - line[26].x) * (line[17].x - line[26].x) + (line[17].y - line[26].y) * (line[17].y - line[26].y)) * 0.55
        let factor = CGFloat(0.7)
        let arcsize = CGFloat(2.0)
        let tlb = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y + h_2 * factor))
        let tl = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y + h_2))
        let tlr = CGPoint(x: (centerBox.x - w_2 * factor), y: (centerBox.y + h_2))
        let tlbb = CGPoint(x: tl.x, y: (tl.y - (tl.y - tlb.y)/arcsize))
        let tlrr = CGPoint(x: (tl.x + (tlr.x - tl.x)/arcsize), y: tl.y)

        let trl = CGPoint(x: (centerBox.x + w_2 * factor), y: (centerBox.y + h_2))
        let tr = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y + h_2))
        let trb = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y + h_2 * factor))
        let trbb = CGPoint(x: tr.x, y: (tr.y - (tr.y - trb.y)/arcsize))
        let trll = CGPoint(x: (tr.x + (trl.x - tr.x)/arcsize), y: tr.y)

        let blt = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y - h_2 * factor))
        let bl = CGPoint(x: (centerBox.x - w_2), y: (centerBox.y - h_2))
        let blr = CGPoint(x: (centerBox.x - w_2 * factor), y: (centerBox.y - h_2))
        let bltt = CGPoint(x: bl.x, y: (bl.y - (bl.y - blt.y)/arcsize))
        let blrr = CGPoint(x: (bl.x + (blr.x - bl.x)/arcsize), y: bl.y)

        let brl = CGPoint(x: (centerBox.x + w_2 * factor), y: (centerBox.y - h_2))
        let br = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y - h_2))
        let brt = CGPoint(x: (centerBox.x + w_2), y: (centerBox.y - h_2 * factor))
        let brtt = CGPoint(x: br.x, y: (br.y - (br.y - brt.y)/arcsize))
        let brll = CGPoint(x: (br.x + (brl.x - br.x)/arcsize), y: br.y)

        pathOutBox.move(to: tlb)
        pathOutBox.addLine(to: tlbb)
        pathOutBox.addCurve(to: tlrr, controlPoint1: tl, controlPoint2: tl)
        pathOutBox.addLine(to: tlr)
        pathOutBox.move(to: trl)
        pathOutBox.addLine(to: trll)
        pathOutBox.addCurve(to: trbb, controlPoint1: tr, controlPoint2: tr)
        pathOutBox.addLine(to: trb)
        pathOutBox.move(to: blt)
        pathOutBox.addLine(to: bltt)
        pathOutBox.addCurve(to: blrr, controlPoint1: bl, controlPoint2: bl)
        pathOutBox.addLine(to: blr)
        pathOutBox.move(to: brl)
        pathOutBox.addLine(to: brll)
        pathOutBox.addCurve(to: brtt, controlPoint1: br, controlPoint2: br)
        pathOutBox.addLine(to: brt)

        if dmsFaceLines.count != 8 {
            for layer in dmsFaceLines {
                layer.removeFromSuperlayer()
            }
            dmsFaceLines.removeAll()
        }
        if dmsFaceLines.count == 0 {
            let layer = CAShapeLayer()
            layer.isGeometryFlipped = false
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layer, below: dmsFacePoints[0])
            dmsFaceLines.append(layer)

            let layerMouth = CAShapeLayer()
            layerMouth.isGeometryFlipped = false
            layerMouth.fillColor = UIColor.clear.cgColor
            layerMouth.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layerMouth, below: dmsFacePoints[0])
            dmsFaceLines.append(layerMouth)

            let layerEyeL = CAShapeLayer()
            layerEyeL.isGeometryFlipped = false
            layerEyeL.fillColor = UIColor.clear.cgColor
            layerEyeL.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layerEyeL, below: dmsFacePoints[0])
            dmsFaceLines.append(layerEyeL)
            let layerEyeR = CAShapeLayer()
            layerEyeR.isGeometryFlipped = false
            layerEyeR.fillColor = UIColor.clear.cgColor
            layerEyeR.lineWidth = 0.8
            dmsFace.layer.insertSublayer(layerEyeR, below: dmsFacePoints[0])
            dmsFaceLines.append(layerEyeR)

            let layerPathMouth = CAShapeLayer()
            layerPathMouth.isGeometryFlipped = false
            layerPathMouth.fillColor = UIColor.clear.cgColor
            layerPathMouth.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathMouth, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathMouth)

            let layerPathEyeDirL = CAShapeLayer()
            layerPathEyeDirL.isGeometryFlipped = false
            layerPathEyeDirL.fillColor = UIColor.clear.cgColor
            layerPathEyeDirL.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathEyeDirL, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathEyeDirL)
            let layerPathEyeDirR = CAShapeLayer()
            layerPathEyeDirR.isGeometryFlipped = false
            layerPathEyeDirR.fillColor = UIColor.clear.cgColor
            layerPathEyeDirR.lineWidth = 2
            dmsFace.layer.insertSublayer(layerPathEyeDirR, below: dmsFacePoints[0])
            dmsFaceLines.append(layerPathEyeDirR)

            let layerOutBox = CAShapeLayer()
            layerOutBox.isGeometryFlipped = false
            layerOutBox.fillColor = UIColor.clear.cgColor
            layerOutBox.lineWidth = 2
            dmsFace.layer.insertSublayer(layerOutBox, below: dmsFacePoints[0])
            dmsFaceLines.append(layerOutBox)
        }
        let normalColor = UIColor(rgb: 0x5fa8d6).cgColor
        let warnColor = UIColor.init(rgb: 0xfe5000, a: 0.8).cgColor
        dmsFaceLines[0].bounds = path.bounds
        dmsFaceLines[0].position = center
        dmsFaceLines[0].path = path.cgPath
        dmsFaceLines[0].strokeColor = normalColor
        // mouth
        dmsFaceLines[1].bounds = pathMouth.bounds
        dmsFaceLines[1].position = centerMouth
        dmsFaceLines[1].path = pathMouth.cgPath
        dmsFaceLines[1].strokeColor = mouth ? warnColor : normalColor
        // eyes
        dmsFaceLines[2].bounds = pathEyeL.bounds
        dmsFaceLines[2].position = centerEyeL
        dmsFaceLines[2].path = pathEyeL.cgPath
        dmsFaceLines[2].strokeColor = eyeL ? normalColor : warnColor
        dmsFaceLines[3].bounds = pathEyeR.bounds
        dmsFaceLines[3].position = centerEyeR
        dmsFaceLines[3].path = pathEyeR.cgPath
        dmsFaceLines[3].strokeColor = eyeR ? normalColor : warnColor

        // direction
        dmsFaceLines[4].bounds = pathFaceDir.bounds
        dmsFaceLines[4].position = centerPathMouth
        dmsFaceLines[4].path = pathFaceDir.cgPath
        dmsFaceLines[4].strokeColor = UIColor.clear.cgColor
        // eyeL
        dmsFaceLines[5].bounds = pathEyeDirL.bounds
        dmsFaceLines[5].position = centerpathEyeDirL
        dmsFaceLines[5].path = pathEyeDirL.cgPath
        dmsFaceLines[5].strokeColor = UIColor(rgb: 0x74E4A1).cgColor
        // eyeR
        dmsFaceLines[6].bounds = pathEyeDirR.bounds
        dmsFaceLines[6].position = centerpathEyeDirR
        dmsFaceLines[6].path = pathEyeDirR.cgPath
        dmsFaceLines[6].strokeColor = UIColor(rgb: 0x74E4A1).cgColor
        // box
        dmsFaceLines[7].bounds = pathOutBox.bounds
        dmsFaceLines[7].position = centerBox
        dmsFaceLines[7].path = pathOutBox.cgPath
        dmsFaceLines[7].strokeColor = UIColor.white.cgColor
        dmsFaceLines[7].transform = CATransform3DRotate(CATransform3DRotate(CATransform3DMakeRotation(-fp, 1, 0, 0), fy, 0, 1, 0), fr, 0, 0, 1)
    }
    private func updateFacePoints(_ points: Array<CGPoint>, mouth: Bool, eye: Bool, fp: CGFloat, fr: CGFloat, fy: CGFloat, ep: CGFloat, er: CGFloat, ey: CGFloat) {

        for layer in dmsFacePoints {
            layer.removeFromSuperlayer()
        }
        dmsFacePoints.removeAll()
        for point in points {
            addPoint(point, size: 0.8, color: UIColor(rgb: 0xfff78e).cgColor)
        }

        updateLines(points, mouth: mouth, eye: eye, fp: fp, fr: fr, fy: fy, ep: ep, er: er, ey: ey)
    }
    private func updateESFacePoints(_ points: Array<CGPoint>,
                                    mouth: Bool,
                                    eyeL: Bool, eyeLPct: Int, eyeLp: Int, eyeLy: Int,
                                    eyeR: Bool, eyeRPct: Int, eyeRp: Int, eyeRy: Int,
                                    fp: CGFloat, fr: CGFloat, fy: CGFloat) {

        for layer in dmsFacePoints {
            layer.removeFromSuperlayer()
        }
        dmsFacePoints.removeAll()
        for point in points {
            addPoint(point, size: 0.8, color: UIColor(rgb: 0xfff78e).cgColor)
        }

        updateESLines(points, mouth: mouth,
                      eyeL: eyeL && (eyeLPct > 5), eyeLPct: eyeLPct, eyeLp: eyeLp, eyeLy: eyeLy,
                      eyeR: eyeR && (eyeRPct > 5), eyeRPct: eyeRPct, eyeRp: eyeLp, eyeRy: eyeRy,
                      fp: fp, fr: fr, fy: fy)
    }
}
