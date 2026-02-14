//
//  CalibrationCameraOrientationViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationCameraOrientationViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CalibrationCameraOrientationUserInterfaceView
    private let viewControllerFactory: CalibrationCameraOrientationViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let configCameraVinMirrorsUseCaseFactory: ConfigCameraVinMirrorsUseCaseFactory

    init(
        observer: Observer,
        userInterface: CalibrationCameraOrientationUserInterfaceView,
        configCameraVinMirrorsUseCaseFactory: ConfigCameraVinMirrorsUseCaseFactory,
        viewControllerFactory: CalibrationCameraOrientationViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.configCameraVinMirrorsUseCaseFactory = configCameraVinMirrorsUseCaseFactory
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        userInterface.stopPreview()
    }

}

//MARK: - Private

private extension CalibrationCameraOrientationViewController {

    func update(for camera: WLCameraDevice?) {
        userInterface.preview(camera: camera)
    }

}

extension CalibrationCameraOrientationViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        userInterface.preview(camera: camera)

        // In some cases, such as user taps the invert botton to rotate the DMS camera picture, the camera will start recording again, resulting in DMS camera picture loss.
        if camera.recState == .recording {
            camera.stopRecord()
        }
    }

}

extension CalibrationCameraOrientationViewController: CalibrationCameraOrientationIxResponder {

    func nextStep() {
        parent?.flowGuide?.nextStep()
    }

    func invertCameraPicture() {
        configCameraVinMirrorsUseCaseFactory.makeConfigCameraVinMirrorsUseCase(with: []).start()
    }

}

extension CalibrationCameraOrientationViewController: ObserverForCalibrationCameraOrientationEventResponder {

    func received(newState: CalibrationCameraOrientationViewControllerState) {
        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

extension CalibrationCameraOrientationViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        update(for: camera)
    }

}

protocol CalibrationCameraOrientationViewControllerFactory {

}
