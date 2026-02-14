//
//  VinMirrorViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VinMirrorViewController: BaseViewController, CameraRelated {
    var camera: UnifiedCamera? {
        didSet {
            updatepdateCameraVinMirrorsUseCaseFactory.makeUpdateCameraVinMirrorsUseCase().start()
        }
    }

    private let observer: Observer
    private let cameraObserver: CameraObserverForVinMirror
    private let userInterface: VinMirrorUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let updatepdateCameraVinMirrorsUseCaseFactory: UpdateCameraVinMirrorsUseCaseFactory
    private let configCameraVinMirrorsUseCaseFactory: ConfigCameraVinMirrorsUseCaseFactory

    init(
        observer: Observer,
        cameraObserver: CameraObserverForVinMirror,
        userInterface: VinMirrorUserInterfaceView,
        updatepdateCameraVinMirrorsUseCaseFactory: UpdateCameraVinMirrorsUseCaseFactory,
        configCameraVinMirrorsUseCaseFactory: ConfigCameraVinMirrorsUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.cameraObserver = cameraObserver
        self.userInterface = userInterface
        self.updatepdateCameraVinMirrorsUseCaseFactory = updatepdateCameraVinMirrorsUseCaseFactory
        self.configCameraVinMirrorsUseCaseFactory = configCameraVinMirrorsUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Vin Mirror", comment: "Vin Mirror")
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
        cameraObserver.startObserving()
    }

}

//MARK: - Private

private extension VinMirrorViewController {

}

extension VinMirrorViewController: VinMirrorIxResponder {

    func select(vinMirrors: [VinMirror]) {
        configCameraVinMirrorsUseCaseFactory.makeConfigCameraVinMirrorsUseCase(with: vinMirrors).start()
    }

}

extension VinMirrorViewController: ObserverForVinMirrorEventResponder {

    func received(newState: VinMirrorViewControllerState) {
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

extension VinMirrorViewController: CameraObserverForVinMirrorEventResponder {

    func received(newVinMirrors: [VinMirror]) {
        updatepdateCameraVinMirrorsUseCaseFactory.makeUpdateCameraVinMirrorsUseCase().start()
    }

}

protocol VinMirrorViewControllerFactory {

}
