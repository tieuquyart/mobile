//
//  CalibrationCalibrateViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationCalibrateViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CalibrationCalibrateUserInterfaceView
    private let viewControllerFactory: CalibrationCalibrateViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let countDownUseCaseFactory: CountDownUseCaseFactory
    private let judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory
    private let calibrateAgainUseCaseFactory: CalibrateAgainUseCaseFactory
    private let dmsClient: WLDmsClient

    private lazy var synthesizer: AVSpeechSynthesizer = { [weak self] in
        $0.delegate = self
        return $0
    }(AVSpeechSynthesizer())

    private lazy var audioSessionManager: AudioSessionManager = AudioSessionManager()

    private var hasFinshedFirstVoiceGuidance = false
    private var calibrateTimeoutTimer: Timer? = nil

    init(
        dmsClient: WLDmsClient,
        observer: Observer,
        userInterface: CalibrationCalibrateUserInterfaceView,
        countDownUseCaseFactory: CountDownUseCaseFactory,
        viewControllerFactory: CalibrationCalibrateViewControllerFactory,
        judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory,
        calibrateAgainUseCaseFactory: CalibrateAgainUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.dmsClient = dmsClient
        self.observer = observer
        self.userInterface = userInterface
        self.countDownUseCaseFactory = countDownUseCaseFactory
        self.viewControllerFactory = viewControllerFactory
        self.judgeDmsCameraPositionUseCaseFactory = judgeDmsCameraPositionUseCaseFactory
        self.calibrateAgainUseCaseFactory = calibrateAgainUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        dmsClient.connectionDelegate = self

        title = NSLocalizedString("", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update(for: WLBonjourCameraListManager.shared.currentCamera)
        synthesizer.delegate = self
        audioSessionManager.activeSessionForDmsCameraCalibration()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        userInterface.stopPreview()

        stopVoiceGuidance()
        synthesizer.delegate = nil
        audioSessionManager.restorePreviousCategoryAndOptions()
    }

}

//MARK: - Private

private extension CalibrationCalibrateViewController {

    func update(for camera: WLCameraDevice?) {
        guard let camera = camera else {
            return
        }

        if !dmsClient.isConnected() {
            dmsClient.connect()
        }

        camera.liveDataMonitor?.start(gps: true, dms: true)
        camera.liveDataMonitor?.delegate = self
        userInterface.preview(camera: camera)
    }

    func calibrateCompletionHandler(_ success: Bool) {
        calibrateTimeoutTimer?.invalidate()
        calibrateTimeoutTimer = nil

        HNMessage.dismiss()

        if success {
            let msg = NSLocalizedString("Make sure that the driver kept an ordinary driving position and look forward from tapping the Calib button to completing the calibration.", comment: "Make sure that the driver kept an ordinary driving position and look forward from tapping the Calib button to completing the calibration.")
            alert(title: nil, message: msg, action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("I am sure", comment: "I am sure"), style: .default) { [weak self] _ in
                    guard let self = self else {
                        return
                    }

                    self.alert(
                        title: NSLocalizedString("Calib Done", comment: "Calib Done"),
                        message: NSLocalizedString("Calibration is required every time the DMS camera is moved!", comment: "Calibration is required every time the DMS camera is moved!"),
                        action1: { () -> UIAlertAction in
                            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel) { _ in
                                self.parent?.flowGuide?.nextStep()
                            }
                    },
                        action2: nil
                    )
                }
            }) { [weak self] () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Not sure and calib again", comment: "Not sure and calib again"), style: .destructive) { _ in
                    self?.calibrateAgainUseCaseFactory.makeCalibrateAgainUseCase().start()
                }
            }
        }
        else {
            alertCalibrationFailed()
        }
    }

    func alertCalibrationFailed() {
        self.alert(title: nil, message: NSLocalizedString("Calib Failed", comment: "Calib Failed"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: .default) { _ in
                (self.parent?.flowGuide as? CalibrationGuide)?.backToFirstStep()
            }
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel) { _ in
                self.parent?.flowGuide?.nextStep()
            }
        }
    }

    @objc func startVoiceGuidance() {
        if synthesizer.isSpeaking {
            return
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startVoiceGuidance), object: nil)

        let stringVoice = NSLocalizedString("Look forward with the ordinary driving posture.", comment: "Look forward with the ordinary driving posture.")
        let utterance = AVSpeechUtterance(string: stringVoice)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "vi-VN")
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stopVoiceGuidance() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startVoiceGuidance), object: nil)
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }

}

extension CalibrationCalibrateViewController: CalibrationCalibrateIxResponder {

    func countDownForCalibration() {
        countDownUseCaseFactory.makeCountDownUseCase().start()
    }

    func backToPreviousStep() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension CalibrationCalibrateViewController: ObserverForCalibrationCalibrateEventResponder {

    func received(newState: CalibrationCalibrateViewControllerState) {
        userInterface.render(newState: newState)

        switch newState.viewState {
        case .available:
            if hasFinshedFirstVoiceGuidance {
                stopVoiceGuidance()
                countDownForCalibration()
            }
        case .positionInvalid:
            startVoiceGuidance()
        case .triggeredCalibration:
            stopVoiceGuidance()

            if let calibrationGuide = parent?.flowGuide as? CalibrationGuide {
                dmsClient.calibrateWith(
                    x: calibrationGuide.driverPosition.x,
                    y: calibrationGuide.driverPosition.y,
                    z: calibrationGuide.driverPosition.z,
                    completionHandler: { [weak self] success in
                        self?.calibrateCompletionHandler(success)
                    })

                HNMessage.show()

                calibrateTimeoutTimer?.invalidate()
                calibrateTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false, block: { [weak self] (timer) in
                    guard let self = self else {
                        return
                    }

                    guard HNMessage.isVisible() else {
                        return
                    }

                    HNMessage.dismiss()

                    self.calibrateTimeoutTimer?.invalidate()
                    self.calibrateTimeoutTimer = nil

                    self.alertCalibrationFailed()
                })
            }
        default:
            stopVoiceGuidance()
        }
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

extension CalibrationCalibrateViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        update(for: camera)
    }

}

extension CalibrationCalibrateViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        userInterface.preview(camera: camera)
    }

}

extension CalibrationCalibrateViewController: HNLiveDataMonitorDelegate {

    func onLiveES(dmsData: WLDmsData?) {
        judgeDmsCameraPositionUseCaseFactory.makeJudgeCameraPositionUseCase(dmsData: dmsData).start()
    }

    func onLive(obd: obd_raw_data_v2_t?) {}

    func onLive(acc: iio_raw_data_t?) {}

    func onLive(gps: CLLocation?) {}

    func onLive(dms: readsense_dms_data_v2_t?) {}
}

extension CalibrationCalibrateViewController: WLSocketClientConnectionDelegate {

    func socketClientDidConnect(_ client: WLSocketClient) {
        if let client = client as? WLDmsClient {
            client.getVersion()
        }
    }

    func socketClient(_ client: WLSocketClient, didDisconnectWithError err: Error?) {
        if err != nil {
            dmsClient.connect()
        }
    }

}

extension CalibrationCalibrateViewController: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        hasFinshedFirstVoiceGuidance = true
        if userInterface.canCalibrate {
            countDownForCalibration()
        }
        else {
            perform(#selector(startVoiceGuidance), with: nil, afterDelay: 2.0)
        }
    }

}

protocol CalibrationCalibrateViewControllerFactory {

}
