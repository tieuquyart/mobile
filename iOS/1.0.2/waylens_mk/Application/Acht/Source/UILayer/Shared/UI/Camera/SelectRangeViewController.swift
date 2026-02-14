//
//  SelectRangeViewController.swift
//  Acht
//
//  Created by Chester Shen on 3/6/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensPiedPiper
import WaylensFoundation
import WaylensCameraSDK

class SelectRangeViewController: BaseViewController {
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var timelineView: UICollectionView!
    @IBOutlet weak var timelineViewContainer: UIView!
    @IBOutlet var upperPanGesture: UIPanGestureRecognizer!
    @IBOutlet var lowerPanGesture: UIPanGestureRecognizer!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var upperOverlay: PassThroughView!
    @IBOutlet weak var lowerOverlay: PassThroughView!
    @IBOutlet weak var upperOverlayHeight: NSLayoutConstraint!
    @IBOutlet weak var lowerOverlayHeight: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: MonospacedLabel!
//    @IBOutlet weak var handleWidth: NSLayoutConstraint!
    
    @IBOutlet weak var handleTop: UIImageView!
    @IBOutlet weak var handleBottom: UIImageView!
    @IBOutlet weak var topEdge: UIView!
    @IBOutlet weak var bottomEdge: UIView!
    
    //    @IBOutlet weak var handleTrailingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var timeScaleBoard: HNScoreBoard!
    @IBOutlet weak var timeScaleContainer: UIView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var zoomLabel: UILabel!

    // used for vdb request, stream index
    public var streamIndex = Int32(0)

    let showScale = false
    let autoPlay = true
    let requestThumbnailInterval = 0.1
    var timelineViewHeight: CGFloat = 0
    var overlayMargin: CGFloat = 80
    var minHeight: CGFloat = 56
    var maxHeight: CGFloat {
        return timelineViewHeight - 2 * overlayMargin
    }
    var lastPoint: CGPoint = .zero
    //    var lastPinchScale: CGFloat = 1
    var scale: CGFloat = 8
    var lastScale: CGFloat = 8
    var clip: HNClip!
    var camera: UnifiedCamera!
    var exportDestination: ExportDestination!
    var dataModel = SelectRangeTimeLineDataSource()
    var playerPanel = PlayerPanelCreator.createSelectRangePlayerPanel()
    var playline = UIView()
    var minOverlayHeight: CGFloat = 0
    var animationTimer: WLTimer?
    var animationScaleStep: CGFloat = 0
    var lastPinchScale: CGFloat = 1.0
    var overlayHeight: CGFloat {
        get {
            return upperOverlayHeight.constant
        }
        
        set {
            let height = min((timelineView.bounds.height - minHeight)/2, max(minOverlayHeight, newValue))
            upperOverlayHeight.constant = height
            lowerOverlayHeight.constant = height
            if newValue > overlayMargin {
                durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .medium)
            } else {
                durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 25, weight: .medium)
            }
            timelineView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: height, right: 0)
        }
    }
    
    var selectedDuration: TimeInterval = 30 {
        didSet {
            durationLabel?.text = selectedDuration.toString(.hms)
        }
    }
    var selectedStart: TimeInterval = 0 {
        didSet {
            let date = clip.startDate.addingTimeInterval(selectedStart)
            startTimeLabel?.text = date.toString(format: .timeSec12)
        }
    }
    var selectedEnd: TimeInterval = 0 {
        didSet {
            let date = clip.startDate.addingTimeInterval(selectedEnd)
            endTimeLabel?.text = date.toString(format: .timeSec12)
        }
    }
    var currentPlaytime: TimeInterval = 0 {
        didSet {
            let h = timelineViewHeight - overlayHeight - CGFloat(currentPlaytime - selectedStart) * pointsPerSecond
            playline.frame = CGRect(x: 0, y: h-0.5, width: timelineView.bounds.width, height: 1)
            if playerPanel.playState != .playing {
                tryUpdateThumbnail(clip: clip, time: currentPlaytime)
            }
        }
    }
    var startPlayTime: TimeInterval = 0
    enum PanningState {
        case none
        case upper
        case lower
    }
    var panningState: PanningState = .none {
        didSet {
            if panningState == oldValue {
                return
            }
            if panningState == .upper {
                lowerPanGesture.isEnabled = false
                upperPanGesture.isEnabled = true
                timelineView.isScrollEnabled = false
            } else if panningState == .lower {
                lowerPanGesture.isEnabled = true
                upperPanGesture.isEnabled = false
                timelineView.isScrollEnabled = false
            } else {
                lowerPanGesture.isEnabled = true
                upperPanGesture.isEnabled = true
                timelineView.isScrollEnabled = true
            }
            if panningState != .none {
                checkButton.hideAnimated()
            } else {
                checkButton.showAnimated()
            }
        }
    }
    var isUserScrolling = false
    var refreshTimer: WLTimer?
    var lastThumbnailRequestTime: Date?
    var shouldAnimate: Bool = false
    var isWarning: Bool = false
    var layout: CameraTimeLineLayout!
    enum ScaleChange {
        case none
        case zoomIn
        case zoomOut
    }
    
    static func createViewController(clip: HNClip, camera: UnifiedCamera, exportDestination: ExportDestination) -> SelectRangeViewController {
        let vc = UIStoryboard(name: "CameraDetail", bundle: nil).instantiateViewController(withIdentifier: "SelectRangeViewController") as! SelectRangeViewController
        vc.clip = clip
        vc.camera = camera
        vc.exportDestination = exportDestination
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedStart = max(0, selectedStart)
        selectedDuration = min(selectedDuration, clip.duration - selectedStart)
        selectedEnd = selectedStart + selectedDuration
        timelineView.register(UINib(nibName:CameraTimeLineLayout.supplementaryThumbnail, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryThumbnail, withReuseIdentifier: CameraTimeLineLayout.supplementaryThumbnail)
        layout = timelineView.collectionViewLayout as? CameraTimeLineLayout
        layout.isHeaderEnabled = false
        layout.bufferedRatio = 1.0
//        handleWidth.constant = layout.thumbnailWidth + 2
//        handleTrailingSpace.constant = layout.thumbnailRightSpace - 1
        dataModel.camera = camera
        dataModel.clip = clip
        timelineView.dataSource = dataModel
        layout.dataSource = dataModel
        timelineView.delegate = self
        
        camera.local?.vdbClient.delegate = self
        
        playerPanel.addToParentViewController(self, superView: playerContainer)
        playerPanel.delegate = self
        playerPanel.supportViewMode = clip.needDewarp
        
        editView.insertSubview(playline, at: 0)
        playline.backgroundColor = UIColor.semanticColor(.tint(.primary))
        currentPlaytime = selectedStart
        refreshTimer = WLTimer(reference: self, interval: 0.1, repeat: true, block: { [weak self] in
            guard let this = self else { return }
            this.refreshCurrentPlaytime()
        })
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        zoomLabel.isHidden = true
        timeScaleContainer.isHidden = true
        timeScaleBoard.font = UIFont.systemFont(ofSize: 45)
        timeScaleBoard.textColor = UIColor.semanticColor(.label(.secondary))
        tipLabel.isHidden = true
        title = NSLocalizedString("Select Range", comment: "Select Range")
        animationTimer = WLTimer(reference: self, interval: 0.05, repeatTimes: 5, block: { [weak self] in
            self?.animateScale()
        })        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if timelineView.bounds.height > 0 && timelineView.bounds.height != timelineViewHeight {
            timelineViewHeight = timelineView.bounds.height
            onTimelineHeightChanged()
        } else if timelineView.bounds.width != layout.collectionViewBoundsSize.width {
            layout.collectionViewBoundsSize = view.bounds.size
            layout.invalidateLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.local?.vdbClient.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playClip(clip, playTime: selectedStart)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerPanel.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerPanel.shutdown()
    }
    
    func refreshCurrentPlaytime() {
        currentPlaytime = min(selectedStart + selectedDuration, playerPanel.currentPlayTime)
    }
    
    func onTimelineHeightChanged() {
//        minHeight = ceil((timelineView.bounds.height - approximateOverlayMargin * 2) / 8)
//        overlayMargin = (timelineView.bounds.height - 8 * minHeight) / 2
        changeToProperScale()
    }
    
    var pointsPerSecond: CGFloat {
        return minHeight / CGFloat(scale)
    }
    
    var secondsPerPoint: TimeInterval {
        return TimeInterval(scale) / TimeInterval(minHeight)
    }
    
    func changeToProperScale(animated: Bool = false) {
        var expectedHeight = CGFloat(selectedDuration) * pointsPerSecond
        var _scale = scale
        while expectedHeight * 2 < maxHeight && _scale > 1.001  {
            let tmp = _scale
            _scale = max(1, _scale / 2)
            expectedHeight *= (tmp / _scale)
        }
        while expectedHeight - maxHeight >= -0.001 {
            _scale = _scale * 2
            expectedHeight = expectedHeight / 2
        }
        if scale != _scale {
            lastScale = scale
            scale = _scale
        }
        if animated {
            showTimeScale()
        }
        onScaleChanged(animated: animated, reload: !animated)
    }
    
    func shouldChangeScale() -> ScaleChange {
        let selectedHeight = timelineView.bounds.height - 2 * overlayHeight
        if selectedHeight - maxHeight >= -0.001 {
            return .zoomOut
        }
        if selectedHeight - minHeight <= 0.001 && scale > 1.001 {
            return .zoomIn
        }
        return .none
    }
    
    func warnScaleChange(_ change: ScaleChange) {
        let on = change != .none
        if on == isWarning {
            return
        }
        isWarning = on
        UIView.animate(withDuration: 0.3) {
            self.upperOverlay.backgroundColor = on ? UIColor.semanticColor(.fill(.primary)).withAlphaComponent(0.8) : UIColor.semanticColor(.fill(.secondary))
            self.lowerOverlay.backgroundColor = on ? UIColor.semanticColor(.fill(.primary)).withAlphaComponent(0.8) : UIColor.semanticColor(.fill(.secondary))
            if on {
                self.bottomEdge.backgroundColor = UIColor.semanticColor(.fill(.primary))
                self.topEdge.backgroundColor = UIColor.semanticColor(.fill(.primary))
                self.handleBottom.image = #imageLiteral(resourceName: "handle_bottom_s")
                self.handleTop.image = #imageLiteral(resourceName: "handle_top_s")
            } else {
                if self.panningState != .lower {
                    self.bottomEdge.backgroundColor = UIColor.semanticColor(.fill(.septenary))
                    self.handleBottom.image = #imageLiteral(resourceName: "handle_bottom")
                }
                if self.panningState != .upper {
                    self.topEdge.backgroundColor = UIColor.semanticColor(.fill(.septenary))
                    self.handleTop.image = #imageLiteral(resourceName: "handle_top")
                }
            }
        }
        if change == .zoomIn {
            showTip(message: NSLocalizedString("Release to zoom in", comment: "Release to zoom in"))
        } else if change == .zoomOut {
            showTip(message: NSLocalizedString("Release to zoom out", comment: "Release to zoom out"))
        } else {
            hideTip()
        }
    }
    
    func showTip(message: String) {
        tipLabel.text = message
        tipLabel.alpha = 0
        tipLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.tipLabel.alpha = 1
//            self.checkButton.alpha = 0
        }
    }
    
    func hideTip() {
        if !tipLabel.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.tipLabel.alpha = 0
//                self.checkButton.alpha = 1
            }) { (completed) in
                if completed {
                    self.tipLabel.isHidden = true
                }
            }
        }
    }
    
    func animateScale() {
        guard let layout = timelineView.collectionViewLayout as? CameraTimeLineLayout, let count = animationTimer?.remainingCount else { return }
        scale += animationScaleStep
        layout.durationUnit = TimeInterval(scale) / TimeInterval(minHeight) * Double(layout.thumbnailHeight)
        if count == 0 { // animating completed, reload thumbnails
            layout.regenerateThumbnail = true
            timelineView.reloadData()
        } else { // animating, just relayout current thumbnails
            layout.invalidateLayout()
        }
    }
    
    func onScaleChanged(animated: Bool=false, reload: Bool=false) {
        guard let layout = timelineView.collectionViewLayout as? CameraTimeLineLayout else { return }
        if animated {
            shouldAnimate = true
            animationScaleStep = (scale - lastScale) / 5
            scale = lastScale
            layout.regenerateThumbnail = false
            layout.durationUnit = secondsPerPoint * Double(layout.thumbnailHeight)
            animationTimer?.remainingCount = 5
            animationTimer?.start()
        } else {
            layout.durationUnit = secondsPerPoint * Double(layout.thumbnailHeight)
            if reload {
                timelineView.reloadData()
            } else {
                layout.invalidateLayout()
            }
        }
    }
    
    func approximate(_ number: CGFloat) -> Int {
        return Int(number+0.001)
    }
    
    func showTimeScale() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTimeScale), object: nil)
        perform(#selector(hideTimeScale), with: nil, afterDelay: 1.5)
        if showScale {
            timeScaleBoard.text = "×\(approximate(lastScale))"
            if timeScaleContainer.isHidden {
                timeScaleContainer.alpha = 0
                timeScaleContainer.isHidden = false
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.timeScaleContainer.alpha = 1
            }) { (completed) in
                if completed {
                    if self.approximate(self.scale) != self.approximate(self.lastScale) {
                        self.timeScaleBoard.setText("×\(self.approximate(self.scale))", fromBottom: self.scale < self.lastScale)
                    }
                }
            }
        } else {
            let ratio = scale / lastScale
            if ratio > 0.99 && ratio < 1.01 {
                return
            }
            zoomLabel.text = scale < lastScale ? NSLocalizedString("Zoom in", comment: "Zoom in") : NSLocalizedString("Zoom out", comment: "Zoom out")
            if zoomLabel.isHidden {
                zoomLabel.alpha = 0
                zoomLabel.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.zoomLabel.alpha = 1
                })
            }
        }
    }
    
    @objc func hideTimeScale() {
        if showScale {
            UIView.animate(withDuration: 0.3, animations: {
                self.timeScaleContainer.alpha = 0
            }) { (completed) in
                if completed {
                    self.timeScaleContainer.isHidden = true
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.zoomLabel.alpha = 0
            }, completion: { (completed) in
                if completed {
                    self.zoomLabel.isHidden = true
                }
            })
        }
    }
    
    func shrink(offset: CGFloat) -> CGFloat {
        let old = overlayHeight
        overlayHeight = overlayHeight + offset
        let t = timelineView.bounds.height - 2 * overlayHeight
        selectedDuration = TimeInterval(t * CGFloat(scale) / minHeight)
        return overlayHeight - old
    }
    
    func contentOffsetFrom(startTime: TimeInterval) -> CGFloat {
        let selectedHeight = CGFloat(selectedDuration) * pointsPerSecond
        let offset = CGFloat(clip.duration - startTime) * pointsPerSecond - timelineView.contentInset.top - selectedHeight
        return offset
    }
    
    @IBAction func onPanUpper(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            topEdge.backgroundColor = UIColor.semanticColor(.fill(.primary))
            handleTop.image = #imageLiteral(resourceName: "handle_top_s")
            panningState = .upper
            lastPoint = sender.location(in: editView)
            pausePlayer()
            currentPlaytime = selectedStart + selectedDuration
        case .changed:
            let point = sender.location(in: editView)
            let limit = 0.5 * (timelineView.bounds.height - CGFloat(clip.duration - selectedStart) * pointsPerSecond)
            var delta = point.y - lastPoint.y
            let h = max(overlayHeight + delta, limit)
            delta = shrink(offset: h - overlayHeight)
            selectedEnd = selectedStart + selectedDuration
            currentPlaytime = selectedEnd
            let offset = contentOffsetFrom(startTime: selectedStart)
            timelineView.contentOffset = CGPoint(x: 0, y: offset)
            lastPoint = point
            warnScaleChange(shouldChangeScale())
        case .cancelled, .ended:
            topEdge.backgroundColor = UIColor.semanticColor(.fill(.septenary))
            handleTop.image = #imageLiteral(resourceName: "handle_top")
            panningState = .none
            if shouldChangeScale() != .none {
                changeToProperScale(animated: true)
            }
            if autoPlay {
                playClip(clip, playTime: selectedStart)
            }
//            playerPanel.videoPlayer?.shutdown()
        default:
            break
        }
    }
    
    @IBAction func onPanLower(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            bottomEdge.backgroundColor = UIColor.semanticColor(.fill(.primary))
            handleBottom.image = #imageLiteral(resourceName: "handle_bottom_s")
            panningState = .lower
            selectedEnd = selectedStart + selectedDuration
            lastPoint = sender.location(in: editView)
            pausePlayer()
            currentPlaytime = selectedStart
        case .changed:
            let point = sender.location(in: editView)
            let limit = 0.5 * (timelineView.bounds.height - CGFloat(selectedEnd) * pointsPerSecond)
            var delta = lastPoint.y - point.y
            let h = max(overlayHeight + delta, limit)
            delta = shrink(offset: h - overlayHeight)
            selectedStart = selectedEnd - selectedDuration
            currentPlaytime = selectedStart
            let offset = contentOffsetFrom(startTime: selectedStart)
            timelineView.contentOffset = CGPoint(x: 0, y: offset)
            lastPoint = point
            warnScaleChange(shouldChangeScale())
        case .cancelled, .ended:
            bottomEdge.backgroundColor = UIColor.semanticColor(.fill(.septenary))
            handleBottom.image = #imageLiteral(resourceName: "handle_bottom")
            panningState = .none
            if shouldChangeScale() != .none {
                changeToProperScale(animated: true)
            }
            if autoPlay {
                playClip(clip, playTime: selectedStart)
            }
        default:
            break
        }
    }
    
    @IBAction func onPinch(_ sender: UIPinchGestureRecognizer) {
        guard let layout = timelineView.collectionViewLayout as? CameraTimeLineLayout else { return }
        switch sender.state {
        case .began:
            lastPinchScale = sender.scale
            layout.regenerateThumbnail = false
        case .changed:
            let ratio = sender.scale / lastPinchScale
            let expectedHeight = CGFloat(selectedDuration) * pointsPerSecond * ratio
            if scale >= ratio && expectedHeight < maxHeight && expectedHeight > minHeight {
                lastScale = scale
                scale /= ratio
                showTimeScale()
                onScaleChanged(animated: false, reload: false)
            }
            lastPinchScale = sender.scale
        case .ended:
            layout.regenerateThumbnail = true
            onScaleChanged(animated: false, reload: true)
            break
//            let selectedHeight = CGFloat(selectedDuration) * pointsPerSecond
//            if sender.scale > 1.5 {
//                if scale >= 2 && selectedHeight * 2 < maxHeight {
//                    lastScale = scale
//                    scale = scale / 2
//                    onScaleChanged(animated: true)
//                }
//            } else if sender.scale < 0.75 {
//                if selectedHeight / 2 > minHeight {
//                    lastScale = scale
//                    scale = scale * 2
//                    onScaleChanged(animated: true)
//                }
//            }
        default:
            return
        }
    }

    @IBAction func onCheck(_ sender: Any) {
        let vc = ExportSessionViewController.createViewController(
            clip: EditableClip(clip, offset: selectedStart, duration: selectedDuration),
            camera: camera,
            streamIndex: streamIndex,
            exportDestination: exportDestination
        )
        self.navigationController?.pushViewController(vc, animated: true)

//        presentExportClipSheet(EditableClip(clip, offset: selectedStart, duration: selectedDuration), camera: self.camera)
    }
    
    func playClip(_ clip:HNClip?, playTime:Double=0) {
        guard let clip = clip else {
            print("clip not found")
            return
        }
        if playerPanel.playSource != .localPlayback {
            playerPanel.playSource = .localPlayback
        }
        startPlayTime = playTime
        playerPanel.duration = clip.duration
        playerPanel.startDate = clip.startDate
        if let rawClip = clip.rawClip {
            playerPanel.playState = .buffering
            playerPanel.setFacedown(clip.facedown)
            if rawClip.isMP4(forStream: streamIndex) {
                camera?.local?.clipsAgent.vdb?.getMP4(forClip: rawClip.clipID,
                                                             in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                             from: rawClip.startTime + playTime,
                                                             length: 30*60.0,
                                                             stream: streamIndex,
                                                             withTag: 1000,
                                                             andID: rawClip.vdbID)
            } else {
                camera?.local?.clipsAgent.vdb?.getHLSForClip(rawClip.clipID,
                                                                    in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                                    from: rawClip.startTime + playTime,
                                                                    length: 30*60.0,
                                                                    stream: streamIndex,
                                                                    withTag: 1000,
                                                                    andID: rawClip.vdbID)
            }
        } else {
            playerPanel.setFacedown(clip.facedown)
            playerPanel.playVideo(clip.url, playbackTime: startPlayTime, startOffset: 0)
        }
    }
    
    func pausePlayer() {
        playerPanel.pause()
        refreshTimer?.stop()
    }
    
    private func tryUpdateThumbnail(clip: HNClip, time:TimeInterval) {
        let now = Date()
        if lastThumbnailRequestTime == nil || now.timeIntervalSince(lastThumbnailRequestTime!) > requestThumbnailInterval {
            requestThumbnail(clip: clip, time: time, canBeIgnored: true)
            lastThumbnailRequestTime = now
        }
    }
    
    private func requestThumbnail(clip:HNClip, time:TimeInterval = 0, canBeIgnored:Bool = false) {
        guard let camera = camera else {
            return
        }

        if let rawClip = clip.rawClip {
            _ = camera.local?.vdbManager?.getThumbnail(forClip: rawClip, atTime: rawClip.startTime+time, ignorable: canBeIgnored, cache: true, completion: { [weak self](result) in
                if result.isSuccess, let thumbnail = result.value as? WLVDBThumbnail, let image = UIImage(data: thumbnail.imageData) {
                    self?.playerPanel.setFacedown(clip.facedown)
                    self?.playerPanel.rawThumbnail = image
                }
            })
        } else if let t = clip.thumbnailUrl, let url = URL(string: t) {
            CacheManager.shared.imageFetcher.get(url).onSuccess { [weak self] (image) in
                self?.playerPanel.setFacedown(clip.facedown)
                self?.playerPanel.rawThumbnail = image
            }
        }
    }
}

extension SelectRangeViewController: TimeLineCollectionViewDelegate {
    func layoutDidPrepare() {
        let contentHeight = layout.contentHeight
        minOverlayHeight = max((timelineView.bounds.height - contentHeight) / 2 + 0.1, overlayMargin)
        let selectedHeight = CGFloat(selectedDuration) * pointsPerSecond
        self.overlayHeight = (self.timelineView.bounds.height - selectedHeight) / 2
        let offset = self.contentOffsetFrom(startTime: self.selectedStart)
        self.timelineView.contentOffset = CGPoint(x: 0, y: offset)
        if shouldAnimate {
            shouldAnimate = false
            UIView.animate(withDuration: 0.3) {
                self.editView.layoutIfNeeded()
                self.currentPlaytime = TimeInterval(self.currentPlaytime)
            }
            warnScaleChange(.none)
        } else {
            self.currentPlaytime = TimeInterval(currentPlaytime)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        playerPanel.pause()
        currentPlaytime = selectedStart
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && isUserScrolling {
            isUserScrolling = false
            if autoPlay {
                playClip(clip, playTime: selectedStart)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isUserScrolling {
            isUserScrolling = false
            if autoPlay {
                playClip(clip, playTime: selectedStart)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if panningState != .none {
            // pass
        } else if isUserScrolling { // dragging
            let tmp = clip.duration - TimeInterval(scrollView.contentOffset.y + timelineViewHeight - overlayHeight) * secondsPerPoint
            selectedStart = max(0, min(clip.duration - selectedDuration, tmp))
            selectedEnd = selectedStart + selectedDuration
            currentPlaytime = selectedStart
        }
    }
}

extension SelectRangeViewController: HNPlayerPanelDelegate {
    func playerDidChange(_ state: HNPlayState) {
        if state == .playing {
            refreshTimer?.start()
        } else {
            refreshTimer?.stop()
        }
        if state == .completed && panningState == .none {
            refreshCurrentPlaytime()
            let currentPos = playerPanel.currentPlayTime
            if currentPos < selectedEnd - 1 { // continue to play next segment, 1 second tolerance
                playClip(clip, playTime: currentPos)
//                playerPanel.videoPlayer?.duration = selectedEnd - currentPos
            } else if autoPlay { // restart
                playClip(clip, playTime: selectedStart)
            }
        }
    }
    
    func onPlay(_ play: Bool) {
        if play {
            if currentPlaytime - selectedEnd >= -0.01 {
                currentPlaytime = selectedStart
            }
            playClip(clip, playTime: currentPlaytime)
        } else {
            pausePlayer()
        }
    }
}

extension SelectRangeViewController: WLVDBDynamicRequestDelegate {
    func onGetPlayURL(_ url: String?, time: Double, tag: Int32) {
        if url == nil {
            NSLog("get nil play url")
            return
        }
        NSLog("onGetPlayURL: " + url!)
        if playerPanel.playState == .buffering {
            playerPanel.playVideo(url, playbackTime: startPlayTime, startOffset: startPlayTime)
            playerPanel.videoPlayer?.duration = selectedEnd - startPlayTime
        }
    }
}
