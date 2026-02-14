//
//  CameraViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CameraUserInterfaceView
    private let initialLoadUseCaseFactory: InitialLoadUseCaseFactory
    private let removeCameraUseCaseFactory: RemoveCameraUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let activateCameraSimCardUseCaseFactory: ActivateCameraSimCardUseCaseFactory
    private let toggleFirmwareVersionUseCaseFactory: ToggleFirmwareVersionUseCaseFactory

    init(
        observer: Observer,
        userInterface: CameraUserInterfaceView,
        initialLoadUseCaseFactory: InitialLoadUseCaseFactory,
        removeCameraUseCaseFactory: RemoveCameraUseCaseFactory,
        activateCameraSimCardUseCaseFactory: ActivateCameraSimCardUseCaseFactory,
        toggleFirmwareVersionUseCaseFactory: ToggleFirmwareVersionUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.initialLoadUseCaseFactory = initialLoadUseCaseFactory
        self.removeCameraUseCaseFactory = removeCameraUseCaseFactory
        self.activateCameraSimCardUseCaseFactory = activateCameraSimCardUseCaseFactory
        self.toggleFirmwareVersionUseCaseFactory = toggleFirmwareVersionUseCaseFactory
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

        initialLoadUseCaseFactory.makeInitialLoadUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension CameraViewController {

}

extension CameraViewController: CameraIxResponder {

    func gotoSetup() {
        SetupGuide(
            scene: .vehicleSetup,
            presenter: VehicleSetupGuidePresenter()
        ).start()
    }

    func activateCamera() {
        alert(title: nil, message: NSLocalizedString("After the camera is activated, the camera will start billing. Are you sure to activate this camera?", comment: "After the camera is activated, the camera will start billing. Are you sure to activate this camera?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Activate", comment: "Activate"), style: .default, handler: { [weak self] _ in
                self?.activateCameraSimCardUseCaseFactory.makeActivateCameraSimCardUseCase().start()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in

            })
        }
    }

    func removeCamera() {
        alert(title: nil, message: NSLocalizedString("Are you sure you want to remove this camera from your fleet?\n\nIf removed, your camera will be deactivated.", comment: "Are you sure you want to remove this camera from your fleet?\nIf removed, your camera will be deactivated."), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove"), style: .destructive, handler: { [weak self] _ in
                self?.removeCameraUseCaseFactory.makeRemoveCameraUseCase().start()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in

            })
        }
    }

    func didTapFirmwareVersionRow() {
        toggleFirmwareVersionUseCaseFactory.makeToggleFirmwareVersionUseCase().start()
    }

}

extension CameraViewController: ObserverForCameraEventResponder {

    func received(newState: CameraViewControllerState) {
        title = newState.cameraProfile?.cameraSn
        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState == .doneRemoving {
            navigationController?.popViewController(animated: true)
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

protocol CameraViewControllerFactory {

}
