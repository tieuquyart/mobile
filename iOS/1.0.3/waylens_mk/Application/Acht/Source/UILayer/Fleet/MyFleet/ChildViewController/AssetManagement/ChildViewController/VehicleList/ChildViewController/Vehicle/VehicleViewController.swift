//
//  VehicleViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: VehicleUserInterfaceView
    private let initialLoadUseCaseFactory: InitialLoadUseCaseFactory
    private let unbindCameraUseCaseFactory: UnbindCameraUseCaseFactory
    private let profileViewControllerFactory: ProfileViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let vehicleViewControllerFactory: VehicleViewControllerFactory
    private let removeVehicleUseCaseFactory: RemoveVehicleUseCaseFactory

    init(
        observer: Observer,
        userInterface: VehicleUserInterfaceView,
        initialLoadUseCaseFactory: InitialLoadUseCaseFactory,
        unbindCameraUseCaseFactory: UnbindCameraUseCaseFactory,
        profileViewControllerFactory: ProfileViewControllerFactory,
        vehicleViewControllerFactory: VehicleViewControllerFactory,
        removeVehicleUseCaseFactory: RemoveVehicleUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.initialLoadUseCaseFactory = initialLoadUseCaseFactory
        self.unbindCameraUseCaseFactory = unbindCameraUseCaseFactory
        self.profileViewControllerFactory = profileViewControllerFactory
        self.vehicleViewControllerFactory = vehicleViewControllerFactory
        self.removeVehicleUseCaseFactory = removeVehicleUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        userInterface.clearsSelection()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension VehicleViewController {

}

extension VehicleViewController: VehicleIxResponder {

    func removeThisVehicle() {
        alert(title: nil, message: NSLocalizedString("Are you sure to remove the vehicle from your fleet?", comment: "Are you sure to remove the vehicle from your fleet?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove"), style: .destructive, handler: { [weak self] _ in
                self?.removeVehicleUseCaseFactory.makeRemoveVehicleUseCase().start()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in

            })
        }
    }

    func showDriverSelectionViewController() {
        let vc = vehicleViewControllerFactory.makeBindDriverViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showModelEditViewController() {
        let vc = profileViewControllerFactory.makeProfileInfoComposingViewController(with: .model(""))
        navigationController?.pushViewController(vc, animated: true)
    }

    func showCameraDetailViewController() {
        let vc = vehicleViewControllerFactory.makeCameraDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showCameraBindingViewController() {
        let vc = vehicleViewControllerFactory.makeBindCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func unbindCamera() {
        alert(title: nil, message: NSLocalizedString("Are you sure to unbind the camera to the vehicle?", comment: "Are you sure to unbind the camera to the vehicle?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Unbind", comment: "Unbind"), style: .destructive, handler: { [weak self] _ in
                self?.unbindCameraUseCaseFactory.makeUnbindCameraUseCase().start()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in

            })
        }
    }

}

extension VehicleViewController: ObserverForVehicleEventResponder {

    func received(newState: VehicleViewControllerState) {
        title = newState.vehicleProfile?.plateNo
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

protocol VehicleViewControllerFactory {
    func makeBindDriverViewController() -> UIViewController
    func makeBindCameraViewController() -> UIViewController
    func makeCameraDetailViewController() -> UIViewController
}
