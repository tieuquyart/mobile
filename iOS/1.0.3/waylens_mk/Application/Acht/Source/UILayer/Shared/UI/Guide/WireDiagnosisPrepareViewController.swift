//
//  WireDiagnosisPrepareViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/10/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import RxSwift
import WaylensFoundation
import WaylensCameraSDK

class WireDiagnosisPrepareViewController: BlankBaseViewController {
    enum PrepareState {
        case none
        case versionLow
        case notViaWiFi
        case connecting
        case notViaDirectWire
        case notPoweredOn
        case prepared
    }
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepOneLabel: UILabel!
    @IBOutlet weak var stepTwoLabel: UILabel!

    private lazy var ssidHelper: IOS13SSIDHelper = IOS13SSIDHelper()

    @objc var camera: UnifiedCamera? {
        didSet {
            camera?.rx.observeWeakly(Bool.self, #keyPath(UnifiedCamera.local.isParking))
                .subscribe(onNext: { [weak self] _ in
                    if self?.isViewLoaded ?? false {
                        self?.refreshUI()
                    }
                }).disposed(by: disposeBag)
            camera?.rx.observeWeakly(Bool.self, #keyPath(UnifiedCamera.local.batteryInfo))
                .subscribe(onNext: { [weak self] _ in
                    if self?.isViewLoaded ?? false {
                        self?.refreshUI()
                    }
                }).disposed(by: disposeBag)
        }
    }
    
    var state: PrepareState = .none
    let disposeBag = DisposeBag()
    
    static func createViewController() -> WireDiagnosisPrepareViewController {
        let vc = WireDiagnosisPrepareViewController(nibName: "WireDiagnosisPrepareViewController", bundle: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initHeader(text: NSLocalizedString("Power Cord Test", comment: "Power Cord Test"), leftButton: true)
        
        actionButton.applyMainStyle()
        stepOneLabel.text = NSLocalizedString("Power off your vehicle", comment: "Power off your vehicle")
        stepTwoLabel.text = NSLocalizedString("Turn vehicle back on", comment: "Turn vehicle back on")
        let font = UIFont(name: "BeVietnamPro-Regular", size: 16)!
        
        stepOneLabel.font = font
        stepTwoLabel.font = font
        
        camera?.local?.setMountACCTrust(true)

        if #available(iOS 13.0, *) {
            ssidHelper.requestPermission()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onCameraListUpdated), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: UIApplication.didBecomeActiveNotification, object: nil)
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func currentState() -> PrepareState {
        if !(camera?.viaWiFi ?? false) {
            if WLBonjourCameraListManager.shared.hasConnectedCameraWiFi {
                return .connecting
            }
            else {
                return .notViaWiFi
            }
        }

        if camera?.featureAvailability.isPowerCordTestAvailable == false {
            return .versionLow
        }
        if camera?.local?.isParking == true {
            return .notPoweredOn
        }
        return .prepared
    }
    
    @objc func refreshUI() {
        state = currentState()
        stepsView.isHidden = true
        detailLabel.textAlignment = .natural
        detailLabel.font = UIFont(name: "BevietnamPro-Regular", size: 16)!
        switch state {
        case .notViaWiFi:
            detailLabel.text = NSLocalizedString("Please connect to your camera's Wi-Fi.", comment: "Please connect to your camera's Wi-Fi.")
            actionButton.isHidden = true
        case .connecting:
            detailLabel.text = NSLocalizedString("Connecting...", comment: "Connecting...")
            detailLabel.textAlignment = .center
            actionButton.isHidden = true
        case .notViaDirectWire:
            detailLabel.text = NSLocalizedString("Your camera is not powered by direct wire.", comment: "Your camera is not powered by direct wire.")
            actionButton.isHidden = true
        case .notPoweredOn:
            detailLabel.text = NSLocalizedString("Please power on your vehicle.", comment: "Please power on your vehicle.")
            actionButton.isHidden = true
        case .versionLow:
            detailLabel.text = NSLocalizedString("firmware_out_of_date", comment: "Firmware out of date.\nPlease update your camera's firmware.")
            actionButton.isHidden = true
        case .prepared:
            detailLabel.text = NSLocalizedString("pre_diagnosis_description", comment: "We'll walk you through the procedure to test the direct wire connection.\n\nIt takes two steps and a few seconds:")
            stepsView.isHidden = false
            actionButton.isHidden = false
            actionButton.setTitle(NSLocalizedString("Start", comment: "Start"), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onAction(_ sender: Any) {
        switch state {
        case .notViaWiFi:
            break
        case .prepared:
            let vc = WireDiagnosisViewController.createViewController()
            vc.camera = camera
            navigationController?.pushViewController(vc, animated: true)
        default:
            // will not be here
            break
        }
    }
    
    @objc func onCameraListUpdated() {
        let local = UnifiedCameraManager.shared.local
        if camera !== local  {
            camera = local
        }
        refreshUI()
    }
}
