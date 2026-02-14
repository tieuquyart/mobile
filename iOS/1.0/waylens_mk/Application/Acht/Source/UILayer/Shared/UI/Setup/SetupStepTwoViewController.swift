//
//  SetupStepTwoViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import RxSwift
import WaylensFoundation
import WaylensCameraSDK

class SetupStepTwoViewController: BlankBaseViewController {
    private var isViewAppeared: Bool = false
    private lazy var ssidHelper: IOS13SSIDHelper = IOS13SSIDHelper()

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var guideLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = NSLocalizedString("Camera Setup", comment: "Camera Setup")
        
        #if FLEET
        guideLabel.text = NSLocalizedString("connect_device_description_fleet", comment: "")
        #else
        guideLabel.text = NSLocalizedString("connect_device_description", comment: "")
        #endif

        if #available(iOS 13.0, *) {
            ssidHelper.requestPermission()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(showLocalNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)

        refreshUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if FLEET
        checkIfConnectedValid(camera: WLBonjourCameraListManager.shared.currentCamera)
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func applyTheme() {
        super.applyTheme()

        actionButton.backgroundColor = UIColor.semanticColor(.tint(.primary))
    }

    @objc @IBAction func onConnect(_ sender: Any) {
        if WLBonjourCameraListManager.shared.hasConnectedCameraWiFi, let currentCamera = WLBonjourCameraListManager.shared.currentCamera {
            gotoNextStep(for: currentCamera)
        }
        else {
            let alert = UIAlertController(
                title: NSLocalizedString("Please open System Settings app and select Wi-Fi", comment: "Please open System Settings app and select Wi-Fi"),
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

}

private extension SetupStepTwoViewController {

    func refreshUI() {
        if WLBonjourCameraListManager.shared.hasConnectedCameraWiFi {
            actionButton.setTitle(NSLocalizedString("Continue", comment: "Continue"), for: .normal)
        }
        else {
            actionButton.setTitle(NSLocalizedString("Go to Wi-Fi Settings", comment: "Go to Wi-Fi Settings"), for: .normal)
        }
    }

    func dismissAlertControllerIfNeeded() {
        if presentedViewController is UIAlertController {
            dismiss(animated: true, completion: nil)
        }
    }

    func gotoStepThree() {
        dismissAlertControllerIfNeeded()
        HNMessage.dismiss()
        performSegue(withIdentifier: "showStepThree", sender: nil)
    }

    func gotoInstallationModeSetup() {
        dismissAlertControllerIfNeeded()
        HNMessage.dismiss()
        let vc = HNCSInstallationModeViewController.createViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func gotoNextStep(for camera: WLCameraDevice) {
        func commonFunc() {
            if camera.productSerie == WLProductSerie.saxhorn {
                gotoStepThree()
            }
            else {
                HNMessage.show()

                camera.getApiVersion { [weak self] (apiVersion) in
                    guard let strongSelf = self else {
                        return
                    }

                    if apiVersion.isNewerOrSameVersion(to: "1.13.06") {
                        camera.getSupportUpsideDown({ (isSupportedUpsideDown) in
                            if isSupportedUpsideDown {
                                strongSelf.gotoInstallationModeSetup()
                            } else {
                                strongSelf.gotoStepThree()
                            }
                        })
                    } else {
                        strongSelf.gotoStepThree()
                    }
                }
            }
        }

        #if FLEET
        if !checkIfConnectedValid(camera: camera) {
            return
        }

        if UnifiedCamera(local: camera, remote: nil).featureAvailability.isMultiInstallationModesAvailable == false {
            gotoStepThree()
        }
        else {
            commonFunc()
        }

        #else
        commonFunc()
        #endif
    }

    @objc func handleCurrentDeviceDidChangeNotification() {
        if let currentCamera = WLBonjourCameraListManager.shared.currentCamera {
            // Delay for retrieving camera status info.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.gotoNextStep(for: currentCamera)
            }
        }
    }

    @objc func handleApplicationDidBecomeActiveNotification() {
        refreshUI()

        if WLBonjourCameraListManager.shared.hasConnectedCameraWiFi {
            // See `handleCurrentDeviceDidChangeNotification` function.
        }
        else {
            showNoConnectionAlert()
        }
    }

    @objc func showLocalNotification() {
        NotificationsManager().scheduleReturnToAppNotification()
    }

    #if FLEET
    @discardableResult
    func checkIfConnectedValid(camera: WLCameraDevice?) -> Bool {
        guard let flowGuide = parent?.flowGuide as? SetupGuide, flowGuide.scene == .vehicleSetup else {
            return true
        }

        if let camera = camera, flowGuide.camera?.cameraSn == camera.sn {
            return true
        } else {
            alert(message: NSLocalizedString("Please connect camera (S/N)", comment: "Please connect camera (S/N)") + ": " + ((parent?.flowGuide as? SetupGuide)?.camera?.cameraSn ?? ""))
            return false
        }
    }
    #endif

}

extension WLCameraDevice {

    fileprivate struct AssociatedKeys {
        static var apiVersionSubscription: UInt8 = 8
        static var isSupportedUpsideDownSubscription: UInt8 = 8
        static var disposeBag: UInt8 = 8
    }

    private var disposeBag: DisposeBag? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag
        }
    }

    private var apiVersionSubscription: Disposable? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.apiVersionSubscription, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.apiVersionSubscription) as? Disposable
        }
    }

    private var isSupportedUpsideDownSubscription: Disposable? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isSupportedUpsideDownSubscription, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isSupportedUpsideDownSubscription) as? Disposable
        }
    }

    func getApiVersion(_ completion: @escaping (String) -> Void) {
        if let apiVersion = apiVersion {
            completion(apiVersion)
        } else {
            apiVersionSubscription = rx.observeWeakly(String.self, #keyPath(WLCameraDevice.apiVersion))
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] (apiVersion) in
                    if self?.apiVersionSubscription != nil, let apiVersion = apiVersion {
                        completion(apiVersion)
                        self?.apiVersionSubscription = nil
                    }
                })

            if disposeBag == nil {
                disposeBag = DisposeBag()
            }
            apiVersionSubscription?.disposed(by: disposeBag!)
        }
    }

    func getSupportUpsideDown(_ completion: @escaping (Bool) -> Void) {
        if let isSupportedUpsideDown = isSupportUpsideDown {
            completion(isSupportedUpsideDown.boolValue)
        } else {
            isSupportedUpsideDownSubscription = rx.observeWeakly(NSNumber.self, #keyPath(WLCameraDevice.isSupportUpsideDown))
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] (isSupportedUpsideDown) in
                    if self?.isSupportedUpsideDownSubscription != nil, let isSupportedUpsideDown = isSupportedUpsideDown {
                        completion(isSupportedUpsideDown.boolValue)
                        self?.isSupportedUpsideDownSubscription = nil
                    }
                })

            if disposeBag == nil {
                disposeBag = DisposeBag()
            }
            isSupportedUpsideDownSubscription?.disposed(by: disposeBag!)

            getSupportUpsideDown()
        }
    }

}
