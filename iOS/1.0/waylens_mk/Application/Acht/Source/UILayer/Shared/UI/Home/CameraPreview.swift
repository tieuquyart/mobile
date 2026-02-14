//
//  CameraPreview.swift
//  Acht
//
//  Created by Chester Shen on 7/5/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RxSwift
import WaylensFoundation
import WaylensCameraSDK
import WaylensVideoSDK

protocol CameraPreviewDelegate : NSObjectProtocol {
    func didTapOnPlan(_ preview: CameraPreview)
    func didTapOnPreview(_ preview: CameraPreview)
    func didEnterName(_ name: String?)
    func didTapLocation(_ preview: CameraPreview, location: WLLocation)
}

extension CameraPreviewDelegate {
    func didEnterName(_ name: String?) {
        // pass
    }
    func didTapLocation(_ preview: CameraPreview, location: WLLocation) {
        // pass
    }
    func didTapOnPlan(_ preview: CameraPreview) {}
}

enum HNCameraSetupState {
    case notSettedUp
    case settingUp
    case settedUp
}

class CameraPreview: UIViewController {
    @IBOutlet weak var nameTextField: HNTitleField!
    @IBOutlet weak var nameTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var overlayContainer: CircleView!
    @IBOutlet weak var contentArea: CircleView!
    @IBOutlet fileprivate weak var connectionStatusView: ConnectionStatusView!
    @IBOutlet weak var shadowOverlay: UIImageView!
    @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationBar: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusBar: UIStackView!
    @IBOutlet weak var gpsIcon: UIImageView!
    @IBOutlet weak var remoteIcon: UIImageView!
    @IBOutlet weak var obdIcon: UIImageView!
    @IBOutlet weak var batteryIcon: UIImageView!
    @IBOutlet weak var signalIcon: UIImageView!
    @IBOutlet weak var modeIcon: UIImageView!
    @IBOutlet weak var lensView: UIView!

    // Only used in Fleet app.
    @IBOutlet weak var eventButton: CameraPreviewEventButton?

    // Only used in Secure360 app.
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var dateTimeStackView: UIStackView?
    @IBOutlet weak var planButton: UIButton?

    private var hasSeen:Bool = false
    private var isLive: Bool = false
    private var wasLiveBeforeResignActive = false
    private var liveTimer: WLTimer?
    private var player: WLVideoPlayer?
    
    private enum ShadowOverlayStyle {
        case empty
        case blur
        case darkMask
        case error
        case innerShadow
    }
    private var lastShadowState: ShadowOverlayStyle = .empty

    private var disposeBag: DisposeBag?

    #if FLEET
    private lazy var eventObserver: CameraEventObserver = CameraEventObserver()
    #endif

    var isActive: Bool = false {
        didSet {
            player?.isActive = isActive
        }
    }
    
    var setupState: HNCameraSetupState = .settedUp {
        didSet {
            refreshUI()
        }
    }
    
    weak var delegate: CameraPreviewDelegate?
    var camera: UnifiedCamera? {
        didSet {
            if camera !== oldValue {
                disposeBag = nil

                reset()

                if let camera = camera {
                    disposeBag = DisposeBag()
                    camera.rx.observeWeakly(WLCameraDevice.self, #keyPath(UnifiedCamera.local), options: [.new])
                        .subscribe(onNext: { (WLCameraDevice) in
                            WLCameraDevice?.getAttitude()
                        })
                        .disposed(by: disposeBag!)

                    #if FLEET
                    camera.remote?.onlineStatusChangeHandler = { [weak self] in
                        self?.refreshUI()
                    }
                    #endif
                }

            }
            refreshUI()
        }
    }

    static func createViewController() -> CameraPreview {
        #if FLEET
        let vc = UIStoryboard(name: "Home-Fleet", bundle: nil).instantiateViewController(withIdentifier: "CameraPreview")
        #else
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CameraPreview")
        #endif
        return vc as! CameraPreview
    }

    deinit {
        reset()
        NotificationCenter.default.removeObserver(self)
    }
    
    func initPlayer() {
        player = WLVideoPlayer(container: contentArea)
        player?.delegate = self
        player?.dewarpParams.rotate180Degrees = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        shadowOverlay.clipsToBounds = true
        timeLabel?.text = ""
        dateLabel?.text = ""
        addressLabel.text = ""
        liveTimer = WLTimer.init(reference: self, interval: 1.0, repeat: true, block: {
            [weak self] in
            self?.updateTime()
        })
        nameTextField.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapPreview(_:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        NotificationCenter.default.addObserver(self, selector: #selector(onResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastShadowState = .empty
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeTapIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        shadowOverlay.layer.cornerRadius = shadowOverlay.bounds.width * 0.5
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                refreshUI()
            }
        }
    }
    
    func refreshUI() {
        if !isViewLoaded {
            return
        }

        refreshShadowOverlay()
        nameTextField.allowEdit = false
        sloganLabel.isHidden = true
        nameTextFieldBottomConstraint.constant = 104

        if setupState == .notSettedUp {
            nameTextField.text = NSLocalizedString("Add Camera", comment: "Add Camera")
            nameTextField.isHidden = false
            planButton?.isHidden = true
            timeLabel?.isHidden = true
            dateLabel?.isHidden = true
            addButton.isHidden = false
            connectionStatusView.isHidden = true
            locationBar.isHidden = true
            statusBar.isHidden = true
            sloganLabel.isHidden = false
            eventButton?.isHidden = true
            nameTextFieldBottomConstraint.constant = 43
        } else if setupState == .settingUp {
            planButton?.isHidden = true
            addButton.isHidden = true
            timeLabel?.isHidden = true
            dateLabel?.isHidden = true
            eventButton?.isHidden = true

            if !(camera?.viaWiFi ?? false) { // not connected
                busyIndicator.startAnimating()
//                shadowOverlay.image = #imageLiteral(resourceName: "camera_blurred")
                nameTextField.isHidden = true
//                connectionIcon.image = nil
                connectionStatusView.isHidden = true
                sloganLabel.isHidden = true
            } else { // connected
                busyIndicator.stopAnimating()

                nameTextField.text = camera?.name

                if nameTextField.isHidden {
                    nameTextField.alpha = 0
                    nameTextField.isHidden = false
                    UIView.animate(withDuration: Constants.Animation.defaultDuration, delay: 1.0, options: [.curveEaseInOut], animations: {
                        self.nameTextField.alpha = 1.0
                    })
                }

                if camera?.local?.isSupportUpsideDown == true && sloganLabel.isHidden {
                    sloganLabel.text = NSLocalizedString("camera_setup_installation_mode_hint", comment: "camera setup installation mode hint")
                    sloganLabel.alpha = 0
                    sloganLabel.isHidden = false

                    UIView.animate(withDuration:  Constants.Animation.defaultDuration, delay: 1.0, options: [.curveEaseInOut], animations: {
                        self.sloganLabel.alpha = 1.0
                    })
                }

                connectionStatusView.isHidden = true
                if !isLive && isActive {
                    show()
                }
            }

            nameTextField.allowEdit = false
            locationBar.isHidden = true
            statusBar.isHidden = true
//            isReadyForShowingMessageBubble = false
        } else if setupState == .settedUp {
            addButton.isHidden = true
            nameTextField.text = camera?.name
            nameTextField.isHidden = false
            
            guard let camera = camera else {
                if isLive {
                    stopLocalLive()
                }
                connectionStatusView.isHidden = true
                return
            }

            if camera.needDewarp {
                player?.dewarpParams = WLVideoDewarpParams(
                    renderMode: .ball,
                    rotate180Degrees: camera.facedown,
                    showTimeStamp: false,
                    showGPS: false
                )
            } else {
                player?.dewarpParams.renderMode = .original
            }

            if let plan = camera.remote?.subscription {
                switch plan.state {
                case .inService, .paid, .suspended:
                    planButton?.setTitle(plan.usageDescription(), for: .normal)
                    planButton?.setTitleColor(plan.isRunningOut ? UIColor.semanticColor(.label(.tertiary)) : UIColor.semanticColor(.tint(.primary)), for: .normal)
                    planButton?.isHidden = false
                case .expired:
                    planButton?.setTitle(plan.state.displayName, for: .normal)
                    planButton?.setTitleColor(UIColor.semanticColor(.label(.tertiary)), for: .normal)
                    planButton?.isHidden = false
                default:
                    planButton?.isHidden = true
                }
            } else {
                planButton?.isHidden = true
            }

            statusBar.isHidden = false
            gpsIcon.updateGPS(gpsStatus: camera.gpsStatus)
            remoteIcon.isHidden = camera.remoteControlStatus != .on
            obdIcon.isHidden = camera.obdStatus != .on

            if #available(iOS 12.0, *) {
                batteryIcon.updateBattery(batteryStatus:camera.batteryStatus, showLevel: !(camera.powerSource == .directWire && camera.isCharging), charging: camera.isCharging, white: traitCollection.userInterfaceStyle == .dark)

                signalIcon.updateSignal(signalStatus: camera.cellSignalStatus, white: traitCollection.userInterfaceStyle == .dark)
            } else {
                batteryIcon.updateBattery(batteryStatus:camera.batteryStatus, showLevel: !(camera.powerSource == .directWire && camera.isCharging), charging: camera.isCharging, white: false)
                signalIcon.updateSignal(signalStatus: camera.cellSignalStatus)
            }

            modeIcon.updateMode(mode: camera.mode)

            if let street = camera.location?.description {
                locationBar.isHidden = false
                addressLabel.text = street
                if isActive {
                    locationBar.alpha = 1
                } else {
                    locationBar.alpha = 0
                }
            } else {
                locationBar.isHidden = true
            }

            if !isLive, let time = camera.remote?.lastActiveTime, time.timeIntervalSince1970 > 0, camera.supports4g, camera.isOffline {
                timeLabel?.isHidden = false
                dateLabel?.isHidden = false
                updateTime(time)
            } else if isLive {
                timeLabel?.isHidden = false
                dateLabel?.isHidden = false
            } else {
                dateLabel?.isHidden = true
                timeLabel?.isHidden = true
            }

            if camera.viaWiFi {
                showTapIndicator()
                connectionStatusView.isHidden = false
                connectionStatusView.connectionStatus = .viaWiFi
                if !isLive && isActive {
                    show()
                }
            } else if camera.via4G {
                connectionStatusView.isHidden = false
                connectionStatusView.connectionStatus = .via4G
                if isLive {
                    stopLocalLive()
                }
            } else { // offline
                connectionStatusView.isHidden = false
                connectionStatusView.connectionStatus = .offline
                if isLive {
                    stopLocalLive()
                }
                statusBar.isHidden = true
            }

            if !isLive && !hasSeen {
                if let urlString = camera.remote?.thumbnailUrl, let _ = URL(string: urlString) {
                    if player == nil {
                        initPlayer()
                    }

                    camera.remote?.getThumbnail(completion: { [weak self] (image) in
                        if let image = image, self?.camera?.remote?.thumbnailUrl == urlString  {
                            self?.player?.replaceCurrentItem(with: .image(image)).start()
                        }
                    })
                }
            }
        }
    }
    
    func updateTime(_ time:Date? = nil) {
        if let time = time { // history
            timeLabel?.text = time.toString(format: .timeSec12)
            dateLabel?.text = time.toHumanizedDateString()
        } else { // live
            dateLabel?.text = ""
            timeLabel?.text = Date().toString(format: .timeSec12)
        }
        
        if (dateLabel?.text == nil) || (dateLabel?.text?.isEmpty == true) {
            dateTimeStackView?.spacing = 0.0
        } else {
            dateTimeStackView?.spacing = 8.0
        }
    }
    
    func hide() {
        isActive = false
        if isLive {
            stopLocalLive()
        }
        camera?.local?.liveDataMonitor?.stop()
        if !locationBar.isHidden && locationBar.alpha == 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.locationBar.alpha = 0
            })
        }
    }
    
    func show() {
        isActive = true
        if camera?.viaWiFi ?? false {
            playLocalLive(camera?.local?.getLivePreviewAddress())
            camera?.local?.liveDataMonitor?.start(gps: true, dms: false)

            #if FLEET
            if setupState == .settedUp, let localCamera = camera?.local {
                eventObserver.observe(localCamera) { [weak self] (eventCount) in
                    self?.eventButton?.numberOfEvents = eventCount
                    self?.eventButton?.isHidden = ((eventCount > 0) ? false : true)
                }
            }
            #endif
        }
        if !locationBar.isHidden && locationBar.alpha == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.locationBar.alpha = 1
            })
        }
    }
    
    private func reset() {
        hide()
        hasSeen = false
        isLive = false
        isActive = false
        contentArea.alpha = 0
        player?.shutdown()
        nameTextField.textColor = UIColor.semanticColor(.label(.secondary))

        #if FLEET
        eventObserver.stopObserve()
        #endif
    }
    
    private func refreshShadowOverlay() {
        var style: ShadowOverlayStyle = .innerShadow
        if setupState == .settingUp && !(camera?.viaWiFi ?? false) {
            style = .blur
        } else if setupState == .settedUp {
            if let message = camera?.messageManager.messages.first, message.level == .error {
                style = .error
            }
        }
        if style == lastShadowState {
            return
        }
        var targetImage: UIImage? = nil
        var targetBackgroundColor: UIColor = .clear
        switch style {
        case .innerShadow:
            targetImage = #imageLiteral(resourceName: "home_camera Inner shadow_n")
        case .blur:
            targetImage = #imageLiteral(resourceName: "camera_blurred")
        case .error:
            targetImage = #imageLiteral(resourceName: "home_camera_inner_shadow_error")
        case .darkMask:
            targetImage = nil
            targetBackgroundColor = UIColor.semanticColor(.background(.mask))
        default:
            break
        }
        if lastShadowState != .empty {
            UIView.transition(
                with: shadowOverlay,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    self.shadowOverlay.image = targetImage
                    self.shadowOverlay.backgroundColor = targetBackgroundColor
            })
        } else {
            shadowOverlay.image = targetImage
            shadowOverlay.backgroundColor = targetBackgroundColor
        }
        lastShadowState = style
    }
    
    private func showTapIndicator() {
        if !Tip.preview.isShown {
            let tapIndicator = UIImageView(image: #imageLiteral(resourceName: "tap_gesture"))
            shadowOverlay.addSubview(tapIndicator)
            tapIndicator.frame = shadowOverlay.bounds
            tapIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tapIndicator.contentMode = .center
            Tip.preview.didShow()
        }
    }
    
    private func removeTapIndicator() {
        if let tapIndicator = shadowOverlay.subviews.first {
            tapIndicator.removeFromSuperview()
        }
    }
    
    private func playLocalLive(_ url:String?) {
        guard let urlstring = url, let url = URL(string: urlstring)  else {
            return
        }

        if player == nil {
            initPlayer()
        }
//        if camera?.needDewarp ?? false {
//            player?.dewarpParams.renderMode = .ball
//        } else {
            player?.dewarpParams.renderMode = .original
//        }

        if !isLive {
            isLive = true
            player?.dewarpParams.rotate180Degrees = camera?.facedown ?? false
            player?.replaceCurrentItem(with: .mjpegPreview(url: url)).start()
            liveTimer?.start()

            if setupState == .settedUp {
                dateLabel?.isHidden = false
                timeLabel?.isHidden = false
            }
        }
    }
    
    private func stopLocalLive() {
        isLive = false
        player?.shutdownAndKeepCurrentFrameImage()
        liveTimer?.stop()
        camera?.remote?.thumbnailTime = Date()
    }
    
    @IBAction func onTapPlan(_ sender: Any) {
        delegate?.didTapOnPlan(self)
    }
    
    @objc func onTapPreview(_ sender: Any) {
        delegate?.didTapOnPreview(self)
    }

    @IBAction func onAdd(_ sender: Any) {
        Log.info("add camera")
        delegate?.didTapOnPreview(self)
    }
    
    @IBAction func onTapLocation(_ sender: Any) {
        if let location = camera?.location {
            delegate?.didTapLocation(self, location: location)
        }
    }

    @IBAction func eventButtonTapped(_ sender: Any) {
        delegate?.didTapOnPreview(self)
    }
    
    // MARK: - Notifications
    @objc func onResignActive() {
        wasLiveBeforeResignActive = isLive
        if isLive {
            stopLocalLive()
        }
    }
    
    @objc func onBecomeActive() {
        if wasLiveBeforeResignActive, let url = camera?.local?.getLivePreviewAddress() {
            playLocalLive(url)
        }
    }
}

extension CameraPreview: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let name = textField.text {
            textField.text = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if textField.text != "" {
                delegate?.didEnterName(textField.text!)
            }
        } else {
            delegate?.didEnterName(nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            return nameTextField.allowEdit
        }
        return true
    }
    
}

extension CameraPreview: WLVideoPlayerDelegate {

    func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState) {
        switch state {
        case .playing, .paused:
            if !hasSeen {
                hasSeen = true
                contentArea.alpha = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentArea.alpha = 1
                })
            }
//            refreshShadowOverlay()
        default:
            break
        }
    }
}

extension CameraPreview: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: lensView) == true {
            return true
        }
        return false
    }
}


fileprivate class ConnectionStatusView: UIButton {
    
    fileprivate enum Status {
        case viaWiFi
        case via4G
        case offline
    }
    
    var connectionStatus: Status = .viaWiFi {
        didSet {
            update()
        }
    }
    
    private func update() {
        let fontSize: CGFloat = 14.0
        
        isUserInteractionEnabled = false
        backgroundColor = UIColor.semanticColor(.background(.maskLight))
        tintColor = UIColor.white
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
        contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 14.0, bottom: 6.0, right: 14.0)
        
        switch connectionStatus {
        case .viaWiFi:
            setImage(nil, for: .normal)
            setTitle(NSLocalizedString("live_wifi", comment: "Live"), for: .normal)
            setTitleColor(UIColor.white, for: .normal)
            
            imageTitleSpace = 0.0
        case .via4G:
            titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)

            setImage(nil, for: .normal)
            setTitle(NSLocalizedString("4G", comment: "4G"), for: .normal)
            setTitleColor(UIColor.semanticColor(.fill(.senary)), for: .normal)

            imageTitleSpace = 0.0
        case .offline:
            setImage(#imageLiteral(resourceName: "offline_icon"), for: .normal)
            setTitle(NSLocalizedString("Offline", comment: "Offline"), for: .normal)
            setTitleColor(UIColor.white, for: .normal)
            
            imageTitleSpace = 4.0
        }
        
        sizeToFit()
        layoutIfNeeded()
        layer.cornerRadius = frame.height / 2
    }
    
}

class CameraPreviewEventButton: UIButton {

    override var intrinsicContentSize: CGSize {
        if var titleSize = attributedTitle(for: UIControl.State.normal)?.size() {
            titleSize.width += 40.0
            titleSize.height += 6.0
            return titleSize
        }
        return super.intrinsicContentSize
    }

    var numberOfEvents: Int = 0 {
        didSet {
            let numberString = (numberOfEvents >= 1000 ? "999+" : "\(numberOfEvents)")
            let attributedString = String(format: NSLocalizedString("xx events in last 24 hours", comment: "%@ events in last 24 hours"), numberString).wl.mutableAttributed(with:
                [
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
                    NSAttributedString.Key.foregroundColor : UIColor.white
                ]
            )
            attributedString.addAttributes( // style number string
                [
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium),
                    NSAttributedString.Key.baselineOffset : -1.5,
                    NSAttributedString.Key.foregroundColor : UIColor.white
                ],
                range: NSRange(location: 0, length: numberString.count)
            )

            set(image: #imageLiteral(resourceName: "btn_settings_list_next"), attributedTitle: attributedString, at: UIButton.Position.left, width: 12.0, state: UIControl.State.normal)
            titleEdgeInsets.bottom = 5.0
            invalidateIntrinsicContentSize()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        layer.cornerRadius = 4.0
        layer.masksToBounds = true

        backgroundColor = UIColor.semanticColor(.tint(.primary))
        tintColor = UIColor.white

        numberOfEvents = 0
    }
}
