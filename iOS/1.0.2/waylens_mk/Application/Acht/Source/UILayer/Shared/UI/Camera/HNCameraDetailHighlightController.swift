//
//  HNCameraDetailHighlightController.swift
//  Acht
//
//  Created by forkon on 2020/1/8.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif
import WaylensCameraSDK

class HNCameraDetailHighlightController {
    private lazy var videoExportManager: VideoExportManager = VideoExportManager()
    private var isSavingHighlightVideoToAlbum: Bool = false
    private weak var cameraDetailViewController: HNCameraDetailViewController?
    private var playerPanel: PlayerPanel? {
        return cameraDetailViewController?.playerPanel
    }
    private var highlightCardAutoDisappearTimer: Timer? = nil
    #if FLEET
    private var canHighlight: Bool = false
    #else
    private var canHighlight: Bool = true {
        didSet {
            if canHighlight != oldValue {
                if canHighlight {
                    showHighlightButton()
                } else {
                    hideHighlightButton()
                }
            }
        }
    }
    #endif
    private var _doneSavingAnimator: HighlightVideoDoneSavingAnimator?
    var doneSavingAnimator: HighlightVideoDoneSavingAnimator? {
        return _doneSavingAnimator
    }
    var streamIndex = Int32(0)

    enum HighlightState {
        case idle
        case userInited
        case confirmed
        case clipCreated
        case clipDisplayed
        case failed
    }
    var highlightState: HighlightState = .idle

    let defaultHighlightDuration: TimeInterval = 30

    init(cameraDetailViewController: HNCameraDetailViewController) {
        self.cameraDetailViewController = cameraDetailViewController
    }
    
    deinit {
        killHighlightCardAutoDisappearTimer()
    }

    func handleTimelineScroll(_ timeline: CameraTimeline) {
        guard let cameraDetailViewController = cameraDetailViewController else {
            return
        }

        let (_, time, segment) = timeline.currentIndexInfo()

        let clip = segment?.clip
        // update player highlight button according to current video type
        if time >= 0, cameraDetailViewController.isLocalSource, let clip = clip, clip.videoType == .buffered {
            canHighlight = true
        } else if playerPanel!.isPlayingOrPreparing(.localLive) && (cameraDetailViewController.camera?.monitoring ?? false) {
            canHighlight = true
        } else {
            canHighlight = false
        }
    }

    func handleHighlightButtonTapped() {
        guard let cameraDetailViewController = cameraDetailViewController,
            let playerPanel = playerPanel,
            let timeline = cameraDetailViewController.timeline else {
            return
        }

        fireHighlightCardAutoDisappearTimer()

        let camera = cameraDetailViewController.camera

        if playerPanel.isPlayingOrPreparing(.localLive) {
            MixpanelHelper.track(event: "Highlight on live")
            camera?.local?.liveMark()
        } else if playerPanel.playSource == .localPlayback {
            MixpanelHelper.track(event: "Highlight on buffred video")
            let (index, time, segment) = timeline.currentIndexInfo()
            if let index = index, time > 0, let clip = cameraDetailViewController.dataModel.clipWithIndex(index)?.rawClip, let startDate = segment?.clip?.startDate {
                highlightState = .userInited
                let now = Date(timeInterval: time, since: startDate)
                let before = min(now.timeIntervalSince(segment!.from), defaultHighlightDuration / 2)
                let after = min(segment!.to.timeIntervalSince(now), defaultHighlightDuration / 2)
                let midTime = clip.startTime + time
                camera?.local?.vdbClient.markClip(clip.clipID, in: WLVDBDomain(rawValue: UInt32(clip.clipType)), from: midTime - before, length: after + before, with: clip.vdbID)

                if let sn = camera?.sn, let targetSize = playerPanel.controlView.currentHighlightCard?.thumbnail?.bounds.size {
                    var size = targetSize
                    if size.height < 44 {
                        size = CGSize(width: 78, height: 44)
                    }
                    let rawRequest = VDBThumbnailRequest(cameraID: sn, clip: clip, pts: midTime - before, cache: true, ignorable: false)
                    let thumbnailRequest = ThumbnailCacheRequest(rawRequest: rawRequest, targetSize: size.scaled())
                    CacheManager.shared.thumbnailCache.get(thumbnailRequest).onSuccess({ (image) in
                        playerPanel.controlView.highlightCards.setImage(image)
                    })
                }

            }
        }
    }

    func handleHighlightCardTapped() {
        guard let cameraDetailViewController = cameraDetailViewController else {
            return
        }

        killHighlightCardAutoDisappearTimer()

        if !isSavingHighlightVideoToAlbum {
            let (index, time, _) = cameraDetailViewController.timeline!.currentIndexInfo()
            if let index = index, time >= 0, let clip = cameraDetailViewController.dataModel.clipWithIndex(index), let _ = clip.rawClip {

                isSavingHighlightVideoToAlbum = true

                let initialProgress: Float = 0.05
                playerPanel?.controlView.highlightCards.setHighlightCardState(.savingClip(progress: initialProgress))
                playerPanel?.pause()

                videoExportManager.exportClip(clip, from: cameraDetailViewController.camera!, streamIndex: self.streamIndex, progress: {[weak self] (progress) in                    self?.playerPanel?.controlView.highlightCards.setHighlightCardState(.savingClip(progress: max(initialProgress, progress)))
                    }, success: {[weak self] in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.isSavingHighlightVideoToAlbum = false
                        strongSelf.showHighlightButtonIfNeeded()
                        strongSelf.playerPanel?.controlView.highlightCards.setHighlightCardState(.waitForUserOperation)

                        // Using animation to show where the highlight video was saved.
                        if let tabBar = AppViewControllerManager.tabBarController?.tabBar, let albumTabIndex = AppViewControllerManager.tabBarController?.albumTabIndex {
                            if strongSelf._doneSavingAnimator == nil {
                                strongSelf._doneSavingAnimator = HighlightVideoDoneSavingAnimator(
                                    tabBar: tabBar,
                                    indexOfTargetTabBarItem: albumTabIndex
                                )
                            }

                            strongSelf.playerPanel!.controlView.currentHighlightButton!.isHighlighted = true
                            strongSelf.doneSavingAnimator?.perform(
                                in: cameraDetailViewController.view,
                                viewWillBeDropped: strongSelf.playerPanel!.controlView.currentHighlightButton!,
                                completion: { _ in
                                    HNMessage.showSuccess(message: NSLocalizedString("Video Saved in Album", comment: "Video Saved in Album"))
                            })
                            strongSelf.playerPanel!.controlView.currentHighlightButton!.isHighlighted = false
                        }

                }) {[weak self] in
                    self?.isSavingHighlightVideoToAlbum = false
                    self?.showHighlightButtonIfNeeded()
                    self?.playerPanel?.controlView.highlightCards.setHighlightCardState(.waitForUserOperation)

                    HNMessage.showError(message: NSLocalizedString("Saving video failed!", comment: "Saving video failed!"))
                }
            }
        } else { // Cancel export.
            isSavingHighlightVideoToAlbum = false
            videoExportManager.cancel()

            showHighlightButtonIfNeeded()
            playerPanel?.controlView.highlightCards.setHighlightCardState(.waitForUserOperation)
        }
    }

    func showHighlightCard() {
        playerPanel?.showHighlightCard()
    }

    private func showHighlightButtonIfNeeded() {
        if !isSavingHighlightVideoToAlbum && canHighlight {
            playerPanel?.showHighlightButton(true)
        } else {
            playerPanel?.hideHighlightCard()
        }
    }

    private func showHighlightButton() {
        if !isSavingHighlightVideoToAlbum {
            playerPanel?.showHighlightButton(true)
        }
    }


    private func hideHighlightButton() {
        if !isSavingHighlightVideoToAlbum {
            playerPanel?.showHighlightButton(false)
        }
    }

    private func fireHighlightCardAutoDisappearTimer() {
        killHighlightCardAutoDisappearTimer()

        highlightCardAutoDisappearTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(highlightCardAutoDisappearTimerAction), userInfo: nil, repeats: false)
    }

    private func killHighlightCardAutoDisappearTimer() {
        highlightCardAutoDisappearTimer?.invalidate()
        highlightCardAutoDisappearTimer = nil
    }

    @objc private func highlightCardAutoDisappearTimerAction() {
        showHighlightButtonIfNeeded()
        highlightCardAutoDisappearTimer = nil
    }
}
