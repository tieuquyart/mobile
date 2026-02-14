//
//  OverviewLiveViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

class OverviewLiveViewController: OverviewPlayerViewController<OverviewLiveHeaderView> {
    private var camera: UnifiedCamera
    private var driver: Driver

    private var voiceController: VoiceController? = nil
    private var triggerVoiceTimer: Timer? = nil
    
    
    private lazy var microphoneStatusView: MicrophoneStatusView = {
        let microphoneStatusView = MicrophoneStatusView.createFromNib()!
        microphoneStatusView.translatesAutoresizingMaskIntoConstraints = false
        microphoneStatusView.layer.cornerRadius = 10.0
        microphoneStatusView.layer.masksToBounds = true
        return microphoneStatusView
    }()

    init(driver: Driver) {
        self.driver = driver

        if let camera = UnifiedCameraManager.shared.cameraForSN(driver.vehicle.cameraSN) {
            self.camera = camera
        }
        else {
            let cameraDict: [String : Any] = [
                "serialNumber" : driver.vehicle.cameraSN,
                "isOnline" : driver.vehicle.state == .offline ? false : true
            ]
            self.camera = UnifiedCamera(dict: cameraDict)
        }

        super.init()
    }
    
    
  

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        title = NSLocalizedString("Live", comment: "Live")

        headerView.update(with: driver)

        navigationItem.leftBarButtonItem = nil

        driver.fetchAndUpdateInfo { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.headerView.update(with: strongSelf.driver)
        }

        playerPanel.supportViewMode = camera.featureAvailability.isViewModeAvailable
        
        if driver.statistics.coordinate.count >= 2 {
            let latitude = driver.statistics.coordinate[1]
            let longitude = driver.statistics.coordinate[0]
           
//            self.mapViewCustom.setMapView(gpsLatitude: latitude , gpsLongitude: longitude)
            self.mapViewCustom.setMapView3(latitude, longitude, driver.vehicle.state, self)
        }
        
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stop()

        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        shutdown()
    }

    override func createPlayerPanel() -> PlayerPanel {
        let playerPanel = PlayerPanelCreator.createOverviewLivePlayerPanel()
        playerPanel.playSource = .remoteLive
        playerPanel.controlView.isHidden = true
        return playerPanel
    }

    override func createHeaderView() -> OverviewLiveHeaderView {
        let header = OverviewLiveHeaderView.createFromNib()!
        header.callHandler = { [unowned self] in
            guard let number = URL(string: "tel://" + (self.driver.phoneNumber ?? "")) else {
                return
            }
            UIApplication.shared.open(number)
        }
        return header
    }

    override func configActionButton(_ button: UIButton) {
        button.setTitle(NSLocalizedString("Hold to Talk", comment: "Hold to Talk"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.backgroundColor = UIColor.semanticColor(.tint(.primary))
        button.addTarget(self, action: #selector(actionButtonTouchDown(_:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(actionButtonTouchUp(_:)), for: [UIControl.Event.touchUpInside, UIControl.Event.touchUpOutside, UIControl.Event.touchCancel])
        button.isHidden = true
    }

    override func onPlay(_ play: Bool) {
        if playerPanel.isPlayingOrPreparing(.remoteLive) {
            stop()
            return
        }

        playerPanel.playState = .buffering
        camera.remote?.startLive(completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            if result.isSuccess {
                strongSelf.camera.remote?.getLiveStatus(progress: { (status) in
                    self?.playerPanel.updateStatusOverlay(withLiveStatus: status)
                    if status == .streaming, let playUrl = strongSelf.camera.remote?.liveUrl  {
                        strongSelf.playerPanel.setFacedown(strongSelf.camera.facedown)
                        strongSelf.playerPanel.playRemoteLive(playUrl)
                        if strongSelf.playerPanel.refreshSpeedTimer == nil {
                            strongSelf.playerPanel.refreshSpeedTimer = WLTimer(reference: strongSelf, interval: 1.0, repeat: true, block: {
                                let kbps = (strongSelf.camera.remote?.uploadingSpeedBitps ?? 0) / 8000
                                strongSelf.playerPanel.refreshSpeed(kbps: kbps)
                                // refresh sigal status
                            })
                        }
                    } else if status.shouldStop {
                        strongSelf.playerPanel.stop()
                        strongSelf.camera.remote?.stopLive()
                    }
                })
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Live stream failed", comment: "Live stream failed"))
                self?.playerPanel.stop()
                self?.playerPanel.playState = .error
            }
        })
    }

    override func playerDidChange(_ state: HNPlayState) {
        switch state {
        case .unloaded, .error, .stopped, .completed:
            actionButton.isHidden = true

            if let voiceController = voiceController, !voiceController.status.isIdle {
                microphoneStatusView.removeFromSuperview()
                voiceController.endStreaming(with: camera)
            }
        default:
            actionButton.isHidden = false
        }

        switch state {
        case .buffering, .playing:
            playerPanel.controlView.isHidden = false
        default:
            playerPanel.controlView.isHidden = true
        }
    }

}

//MARK: - Private

private extension OverviewLiveViewController {

    func stop() {
        triggerVoiceTimer?.invalidate()
        triggerVoiceTimer = nil

        playerPanel.refreshSpeed(kbps: 0)
        playerPanel.refreshSpeedTimer?.stop()
        playerPanel.stop()
        camera.remote?.stopLive()
        playerPanel.updateStatusOverlay()

        voiceController?.endStreaming(with: camera)
    }

    func shutdown() {
        playerPanel.shutdown()
    }

    func showMicrophoneStatusView() {
        if !microphoneStatusView.isDescendant(of: view) {
            view.addSubview(microphoneStatusView)
        }

        microphoneStatusView.widthAnchor.constraint(equalToConstant: 140.0).isActive = true
        microphoneStatusView.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
        microphoneStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        microphoneStatusView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -50.0).isActive = true

        microphoneStatusView.isHidden = false
        view.bringSubviewToFront(microphoneStatusView)
    }
}

//MARK: - Action

extension OverviewLiveViewController {

    @IBAction func actionButtonTouchDown(_ sender: UIButton) {
        actionButton.setTitle(NSLocalizedString("Release to End", comment: "Release to End"), for: .normal)

        triggerVoiceTimer?.invalidate()
        triggerVoiceTimer = nil

        triggerVoiceTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(triggerVoiceTimerFired), userInfo: nil, repeats: false)
    }

    @IBAction func actionButtonTouchUp(_ sender: UIButton) {
        actionButton.setTitle(NSLocalizedString("Hold to Talk", comment: "Hold to Talk"), for: .normal)

        triggerVoiceTimer?.invalidate()
        triggerVoiceTimer = nil

        voiceController?.endStreaming(with: camera)
    }

    @objc func triggerVoiceTimerFired() {
        if voiceController == nil {
            voiceController = VoiceController(licenseKey: AppConfig.AccessKeys.wowzaLicenseKey)
            voiceController?.delegate = self
        }

        if voiceController?.status.isIdle == true {
            showMicrophoneStatusView()
            microphoneStatusView.titleLabel.text = NSLocalizedString("Connecting...", comment: "Connecting...")

            voiceController?.startStreaming(with: camera).onSuccess({ _ in

            }).onFailure({ [weak self] (error) in
                Log.error("Tackback Error: \(error.localizedDescription)")
                self?.alert(message: NSLocalizedString("Failed to start talkback, please try again.", comment: "Failed to start talkback, please try again."))
            })
        }
    }

    @objc func handleAppDidEnterBackgroundNotification() {
        stop()
        shutdown()
    }

}

//MARK: - VoiceControllerDelegate

extension OverviewLiveViewController: VoiceControllerDelegate {

    #if arch(x86_64) || arch(i386)
    #else
    func voiceController(_ voiceController: VoiceController, statusDidChange newStatus: VoiceControllerStatus, error: Error?) {
        showMicrophoneStatusView()

        switch newStatus.state {
        case .running:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Speaking, please.", comment: "Speaking, please.")
        case .stopping:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Stopping...", comment: "Stopping...")
        case .buffering:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Buffering...", comment: "Buffering...")
        case .idle, .ready:
            microphoneStatusView.isHidden = true
        default:
            break
        }

        if let error = error {
            Log.error("Tackback Error: \(error.localizedDescription)")
            alert(message: NSLocalizedString("Failed to start talkback, please try again.", comment: "Failed to start talkback, please try again."))
        }

    }
    #endif

}
