//
//  EventDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class EventDetailViewController: OverviewPlayerViewController<EventDetailHeaderView> {

    private var event: Event

    init(event: Event) {
        self.event = event
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.eventType?.description

        
     //   headerView.update(with: event)
        playerPanel.duration = TimeInterval(event.duration ?? 0)

        let camera = UnifiedCameraManager.shared.cameraForSN((event.cameraSn)!) ?? UnifiedCamera(dict: ["serialNumber" : event.cameraSn as Any])
        playerPanel.supportViewMode = camera.featureAvailability.isViewModeAvailable
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // hide close button when presented
        if navigationController?.presentingViewController == nil {
            navigationItem.leftBarButtonItem = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playVideo()
    }

    override func createPlayerPanel() -> PlayerPanel {
        let playerPanel = PlayerPanelCreator.createEventDetailPlayerPanel()
        playerPanel.playSource = .remotePlayback
        return playerPanel
    }

    override func createHeaderView() -> EventDetailHeaderView {
        let header = EventDetailHeaderView.createFromNib()!
        return header
    }

    override func configActionButton(_ button: UIButton) {
        button.setTitle(NSLocalizedString("Export the Video", comment: "Export the Video"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.backgroundColor = UIColor.semanticColor(.tint(.primary))
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: UIControl.Event.touchUpInside)
    }

    override func onPlay(_ play: Bool) {
        if play {
            playVideo()
        } else {
            playerPanel.stop()
        }
    }

}

//MARK: - Action

extension EventDetailViewController {

    @objc private func actionButtonTapped(_ sender: UIButton) {
        let clip = EditableClip(HNClip(event: event))
        presentExportClipSheet(clip, camera: nil, streamIndex: 0)
    }

}

//MARK: - Private

extension EventDetailViewController {

    private func playVideo() {
        guard let videoURL = event.url, videoURL != "" else {
            return
        }

        if playerPanel.playState == .paused {
            playerPanel.resume()
        } else {
            playerPanel.playSource = .remotePlayback
            playerPanel.setFacedown(false)
            playerPanel.playVideo(videoURL)
        }
    }

}
