//
//  NetworkDiagnosisViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/2/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class NetworkDiagnosisViewController: BlankBaseViewController {
    enum NetworkError {
        case simCardNotDetected
        case simCardWrongState
        case simCardNotSupported
        #if FLEET
        case simCardRefused
        #endif
        case dataPlanNotSubscribed
        case dataPlanExpired
        case dataPlanSuspended
        case cellularNetworkOutage 
        case cellularNetworkRoaming
        case cameraClientFailure
        case serverNotReachable
        
        var message: String {
            switch self {
            case .simCardNotDetected:
                return WLCopy.simCardNotDetected
            case .simCardWrongState:
                return NSLocalizedString("sim_card_wrong_state_message", comment: "SIM card's status incorrect. Check the SIM card, plug the cable back in and try again.")
            case .simCardNotSupported:
                return WLCopy.simCardNotSupported
                #if FLEET
            case .simCardRefused:
                return NSLocalizedString("Please contact the supplier for the cause of the network error.", comment: "Please contact the supplier for the cause of the network error.")
                #endif
            case .dataPlanNotSubscribed:
                return NSLocalizedString("data_plan_not_subscribed_message", comment: "No subscription. Please subscribe to a data plan for the camera.")
            case .dataPlanExpired:
                return NSLocalizedString("data_plan_expired_message", comment: "Subscription expired. Please renew or select a new subscription.")
            case .dataPlanSuspended:
                return NSLocalizedString("data_plan_suspended_message", comment: "Service suspended. You can purchase add-on to recover the service.")
            case .cellularNetworkOutage:
                return NSLocalizedString("cellular_network_outage_message", comment: "Cellular network is not available. Please move to another location and try again.")
            case .cellularNetworkRoaming:
                return NSLocalizedString("cellular_network_roaming_message", comment: "Sorry, roaming not supported.")
            case .cameraClientFailure:
                return NSLocalizedString("camera_client_failure_message", comment: "Connection failed. Try to long-press the button on camera dock to reboot.")
            case .serverNotReachable:
                return NSLocalizedString("server_not_reachable_message", comment: "The service is temporarily not available. Please try again later.")
            }
        }
    }
    enum NetworkState: Int {
        case none = 0
        case simCardChecking = 1
        case simCardError = 2
        case dataPlanChecking = 3
        case dataPlanError = 4
        case signalChecking = 5
        case signalError = 6
        case serverChecking = 7
        case serverError = 8
        case connected = 9
        
        var isChecking: Bool {
            switch self {
            case .simCardChecking, .dataPlanChecking, .signalChecking, .serverChecking:
                return true
            default:
                return false
            }
        }
        var isSuccess: Bool {
            return self == .connected
        }
        var isFailure: Bool {
            switch self {
            case .simCardError, .dataPlanError, .signalError, .serverError:
                return true
            default:
                return false
            }
        }
        var nextState: NetworkState? {
            return NetworkState(rawValue: self.rawValue + (self.rawValue % 2 == 1 ? 2 : 1))
        }
    }
    @IBOutlet weak var stateIcon: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var loadingIndicator: WLActivityIndicator!
    
    var messageVC: PreDiagnosisViewController?
    
    var camera: UnifiedCamera? {
        didSet {
            camera?.local?.settingsDelegate = self
            prepareTest()
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    var currentState: NetworkState = .none
    var nextState: NetworkState = .none
    var error: NetworkError? = nil
    var lteStatus: [AnyHashable: Any]?
    var subscriptionState: DataSubscription.State?
    var iccidResult: WLAPIResult?
    var lastRefreshTime: TimeInterval = 0
    var signalSearchingTimer: WLTimer?

    private var nextButton: UIButton? {
        return self.view.viewWithTag(888) as? UIButton
    }

    static func createViewController() -> NetworkDiagnosisViewController {
        func commonFunc() -> NetworkDiagnosisViewController {
            let vc = NetworkDiagnosisViewController(nibName: "NetworkDiagnosisViewController", bundle: nil)
            return vc
        }

        #if FLEET
        if
//            ([.fleetManager, .installer].contains(UserSetting.current.userProfile?.roles) == true)
//            ||
                !AccountControlManager.shared.isLogin
        {
            let vc = NetworkDiagnosisViewController(nibName: "NetworkDiagnosisViewController-FleetInstaller", bundle: nil)
            return vc
        }
        else {
            return commonFunc()
        }
        #else
        return commonFunc()
        #endif
    }

    deinit {
        messageVC?.removeSelfFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = NSLocalizedString("Network Test", comment: "Network Test")
        if camera == nil {
            camera = UnifiedCameraManager.shared.local
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStateAndUI()
    }

    override func applyTheme() {
        super.applyTheme()

        func commonFunc() {
            feedbackButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .normal)
        }

        #if FLEET
        if
//            (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                ||
                !AccountControlManager.shared.isLogin
        {
            feedbackButton.setTitleColor(UIColor.semanticColor(.label(.tertiary)), for: .normal)
        }
        else {
            commonFunc()
        }
        #else
        commonFunc()
        #endif

        actionButton.backgroundColor = UIColor.semanticColor(.tint(.primary))

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                loadingIndicator.isLight = true
            }
            else {
                loadingIndicator.isLight = false
            }

            refreshUI()
        }

    }

    func prepareTest() {
        lastRefreshTime = 0
        currentState = .none
        nextState = .simCardChecking
        iccidResult = nil
        error = nil
        lteStatus = nil
        camera?.local?.getLTEStatus()
    }
    
    func showMessage(_ message: String) {
        if messageVC == nil {
            messageVC = PreDiagnosisViewController.createViewController()
            messageVC?.addToViewController(self)
        }
        messageVC?.message = message
    }
    
    func getState() -> NetworkState {
        guard let camera = camera, camera.viaWiFi else {
            showMessage(NSLocalizedString("Please connect to your camera's Wi-Fi.", comment: "Please connect to your camera's Wi-Fi."))
            return .none
        }
        guard camera.supports4g else {
            showMessage(NSLocalizedString("Secure360 WiFi does not have Internet access.", comment: "Secure360 WiFi does not have Internet access."))
            return .none
        }
//        guard let version = camera.firmware, version.compare("1.10", options: .numeric) != ComparisonResult.orderedAscending else {
//            showMessage(NSLocalizedString("firmware_out_of_date", comment: "Firmware out of date.\nPlease update your camera's firmware."))
//            return .none
//        }

        #if !FLEET
        guard AccountControlManager.shared.isAuthed else {
            showMessage(NSLocalizedString("Log into your account.", comment: "Log into your account."))
            return .none
        }

        guard camera.remote?.ownerUserId == AccountControlManager.shared.keyChainMgr.userID else {
            showMessage(NSLocalizedString("Add camera to your account.", comment: "Add camera to your account."))
            return .none
        }
        #endif
        
        guard let lteStatus = lteStatus else {
            return .simCardChecking
        }
        if lteStatus["sim"] as? String != "READY" {
            // no sim; other
            if lteStatus["sim"] as? String == "SIM failure" {
                error = .simCardNotDetected
            } else {
                error = .simCardWrongState
            }
            return .simCardError
        }

        #if FLEET
        if camera.iccid == nil {
            return .simCardError
        }
        #else
        guard let iccidResult = iccidResult, iccidResult.error?.asAPIError != .networkError  else {
            camera.reportICCID { [weak self] (result) in
                self?.iccidResult = result
                self?.refreshStateAndUI()
            }
            return .simCardChecking
        }
        if !(iccidResult.isSuccess) {
            error = .simCardNotSupported
            return .simCardError
        }

        guard let subscriptionState = self.subscriptionState else {
            camera.updateSubscription { [weak self] (result) in
                if result.isSuccess {
                    self?.subscriptionState = camera.remote?.subscription?.state
                    self?.refreshStateAndUI()
                } else {
                    HNMessage.show(message: result.error?.localizedDescription)
                    self?.error = nil
                    self?.nextState = .dataPlanError
                    self?.refreshUI()
                }
            }
            return .dataPlanChecking
        }

        if subscriptionState != .inService && subscriptionState != .paid {
            if subscriptionState == .expired {
                error = .dataPlanExpired
            } else if subscriptionState == .none {
                error = .dataPlanNotSubscribed
            } else if subscriptionState == .suspended {
                error = .dataPlanSuspended
            }
            return .dataPlanError
        }
        #endif

        guard let ceregString = (lteStatus["cereg"] as? String)?.split(separator: ",").last, let cereg = Int(ceregString) else {
            error = .cellularNetworkOutage
            return .signalError
        }

        // cereg: [0 IDLE; 1 READY; 2 SEARCHING; 3 REFUESED; 4 UNKNOWN; 5 ROAMING]

        if cereg == 3 {
            // refused
            #if FLEET
            error = .simCardRefused
            #else
            error = .cellularNetworkOutage
            #endif
            return .signalError
        }

        if !((cereg == 1) || (cereg == 5)) {
            // searching
            return .signalChecking
        }

        guard let ip = (lteStatus["ip"] as? String)?.split(separator: ",").map( { $0.trimmingCharacters(in: .whitespaces) }) else {
            error = .cellularNetworkOutage
            return .signalError
        }
        if !(ip.count > 2 && ip[0].count > 0 && ip[1].count > 0 && ip[2].count > 0) {
            error = .cellularNetworkOutage
            return .signalError
        }
        if lteStatus["connected"] as? String != "yes" {
            if lteStatus["ping8888"] as? String != "yes" {
                error = .cameraClientFailure
            } else {
                error = .serverNotReachable
            }
            return .serverError
        }
        return .connected
    }
    
    func tryAddRow(checking: NetworkState, error: NetworkState, title: String) {
        var icon: UIView!
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.semanticColor(.label(.secondary))
        if currentState == checking {
            var indicatorStyle: UIActivityIndicatorView.Style = .gray

            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    indicatorStyle = .white
                }
            }

            let indicator = UIActivityIndicatorView(style: indicatorStyle)
            indicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            icon = indicator
            indicator.startAnimating()
            label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        } else if currentState == error {
            icon = UIImageView(image: #imageLiteral(resourceName: "icon_cross"))
        } else if currentState.rawValue > checking.rawValue {
            icon = UIImageView(image: #imageLiteral(resourceName: "icon_check"))
        } else {
            icon = UIView()
            label.textColor = UIColor.semanticColor(.label(.primary))
        }
        icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.spacing = 12
        stackView.addArrangedSubview(row)
    }
    
    func refreshStateAndUI() {
        let targetState = getState()
        if targetState == .signalChecking {
            if signalSearchingTimer == nil {
                signalSearchingTimer = WLTimer(reference: self, interval: 60, repeat: false, block: {
                    [weak self] in
                    if self?.currentState == .signalChecking {
                        self?.nextState = .signalError
                        self?.error = .cellularNetworkOutage
                        self?.refreshUI()
                    }
                })
            }
            if signalSearchingTimer?.isValid != true {
                signalSearchingTimer?.start()
            }
        } else {
            signalSearchingTimer?.stop()
        }
        if targetState == currentState {
            return
        } else if targetState.rawValue < currentState.rawValue {
            nextState = targetState
        } else {
            if let nextState = currentState.nextState, nextState.rawValue < targetState.rawValue {
                self.nextState = nextState
            } else {
                nextState = targetState
            }
        }
        refreshUI()
    }
    
    @objc func refreshUI() {
        let now = Date().timeIntervalSince1970
        let wait = lastRefreshTime + 0.8 - now
        if wait > 0 {
            perform(#selector(refreshUI), with: nil, afterDelay: wait)
            return
        }
        lastRefreshTime = now
        currentState = nextState
        stackView.arrangedSubviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        tryAddRow(checking: .simCardChecking, error: .simCardError, title: NSLocalizedString("SIM card", comment: "SIM card"))
        #if !FLEET
        tryAddRow(checking: .dataPlanChecking, error: .dataPlanError, title: NSLocalizedString("Data plan", comment: "Data plan"))
        #endif
        tryAddRow(checking: .signalChecking, error: .signalError, title: NSLocalizedString("Cellular network", comment: "Cellular network"))
        tryAddRow(checking: .serverChecking, error: .serverError, title: NSLocalizedString("Server connection", comment: "Server connection"))
        
        if currentState.isChecking {
            stateLabel.text = NSLocalizedString("Checking", comment: "Checking")
            stateIcon.image = nil
            loadingIndicator.startAnimating()
            detailLabel.text = NSLocalizedString("It may take a few seconds.", comment: "It may take a few seconds.")
            detailLabel.textColor = UIColor.semanticColor(.label(.primary))
            actionButton.isHidden = true
            feedbackButton.isHidden = true
            nextButton?.isHidden = true
        } else if currentState.isSuccess {
            stateLabel.text = NSLocalizedString("Connected", comment: "Connected")
            stateIcon.image = #imageLiteral(resourceName: "icon_success")
            loadingIndicator.stopAnimating()
            detailLabel.text = NSLocalizedString("Good to go.", comment: "Good to go.")
            detailLabel.textColor = UIColor.semanticColor(.label(.primary))
            actionButton.isHidden = false

            #if FLEET
            if parent?.flowGuide != nil {
                if
//                    (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                        ||
//                        
                        !AccountControlManager.shared.isLogin
                {
                    actionButton.setTitle(NSLocalizedString("Continue", comment: "Continue"), for: .normal)
                }
                else {
                    actionButton.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
                }
            } else {
                actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
            }
            #else
            actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
            #endif

            feedbackButton.isHidden = true
            nextButton?.isHidden = true
        } else {
            stateLabel.text = NSLocalizedString("Error", comment: "Error")
            stateIcon.image = #imageLiteral(resourceName: "icon_error")
            loadingIndicator.stopAnimating()
            detailLabel.text = error?.message ?? NSLocalizedString("Oops. Something is wrong.", comment: "Oops. Something is wrong.")
            detailLabel.textColor = UIColor.semanticColor(.label(.tertiary))
            actionButton.isHidden = false
            nextButton?.isHidden = false

            if currentState == .serverError {
                feedbackButton.isHidden = false
            }
            else {
                feedbackButton.isHidden = true
            }
        }

        #if FLEET
        if parent?.flowGuide == nil {
            nextButton?.isHidden = true
        }
        #endif

        if currentState.isChecking {
            refreshStateAndUI()
        }
    }
    
    @IBAction func onAction(_ sender: Any) {
        if currentState.isSuccess {
            #if FLEET
            if let flowGuide = parent?.flowGuide {
                flowGuide.nextStep()
            } else {
                navigationController?.popViewController(animated: true)
            }
            #else
            if let guideHelper = navigationController?.guideHelper {
                guideHelper.nextStep()
            } else {
                navigationController?.popViewController(animated: true)
            }
            #endif
        } else if currentState.isFailure {
            prepareTest()
            refreshStateAndUI()
        }
    }
    
    @IBAction func onFeedback(_ sender: Any) {
        let vc = FeedbackController.createViewController()
        vc.camera = camera
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        #if FLEET
        parent?.flowGuide?.nextStep(with: ["networkDiagnosisFailed" : (currentState.isFailure ? true : false)])
        #endif
    }

}

extension NetworkDiagnosisViewController: WLCameraSettingsDelegate {
    func onGetLTEStatus(_ status: [AnyHashable : Any]?) {
        lteStatus = status
        if isViewLoaded && currentState.isChecking {
            refreshStateAndUI()
        }
    }
}
