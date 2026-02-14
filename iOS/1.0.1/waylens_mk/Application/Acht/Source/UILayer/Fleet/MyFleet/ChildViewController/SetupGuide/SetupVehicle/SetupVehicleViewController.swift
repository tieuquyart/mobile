//
//  SetupVehicleViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SetupVehicleViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: SetupVehicleUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let profileViewControllerFactory: ProfileViewControllerFactory
    private let addNewVehicleViewControllerFactory: SetupVehicleViewControllerFactory
    private let updateVehicleProfileUseCaseFactory: UpdateVehicleProfileUseCaseFactory
    private let bindCameraUseCaseFactory: BindCameraUseCaseFactory
    private let bindDriverUseCaseFactory: BindDriverUseCaseFactory
    private let makeAddNewCameraViewController: () -> UIViewController

    private var bindingTaskCount: Int = 0

    init(
        observer: Observer,
        userInterface: SetupVehicleUserInterfaceView,
        addNewVehicleViewControllerFactory: SetupVehicleViewControllerFactory,
        makeAddNewCameraViewController: @escaping () -> UIViewController,
        profileViewControllerFactory: ProfileViewControllerFactory,
        loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        updateVehicleProfileUseCaseFactory: UpdateVehicleProfileUseCaseFactory,
        bindCameraUseCaseFactory: BindCameraUseCaseFactory,
        bindDriverUseCaseFactory: BindDriverUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.addNewVehicleViewControllerFactory = addNewVehicleViewControllerFactory
        self.makeAddNewCameraViewController = makeAddNewCameraViewController
        self.loadCameraListUseCaseFactory = loadCameraListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase
        self.updateVehicleProfileUseCaseFactory = updateVehicleProfileUseCaseFactory
        self.profileViewControllerFactory = profileViewControllerFactory
        self.bindCameraUseCaseFactory = bindCameraUseCaseFactory
        self.bindDriverUseCaseFactory = bindDriverUseCaseFactory

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Setup", comment: "Setup")
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

        loadCameraListUseCaseFactory.makeLoadCameraListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension SetupVehicleViewController {

    @objc func cancelButtonTapped(_ sender: Any) {
        dismissMyself(animated: true)
    }

}

extension SetupVehicleViewController: SetupVehicleIxResponder {

    func selectCamera(at indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func gotoPlateNumberComposing() {
        let vc = profileViewControllerFactory.makeProfileInfoComposingViewController(with: .plateNumber(""))
        navigationController?.pushViewController(vc, animated: true)
    }

    func gotoVehicleModelComposing() {
        let vc = profileViewControllerFactory.makeProfileInfoComposingViewController(with: .model(""))
        navigationController?.pushViewController(vc, animated: true)
    }

    func gotoDriverSelector() {
        let vc = addNewVehicleViewControllerFactory.makeDriverSelectorViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func gotoAddNewCamera() {
        let vc = makeAddNewCameraViewController()

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }
        
        present(vc, animated: true, completion: nil)
    }

    func updateVehicle() {
        updateVehicleProfileUseCaseFactory.makeUpdateVehicleProfileUseCase().start()
    }

}

extension SetupVehicleViewController: ObserverForSetupVehicleEventResponder {

    func received(newState: SetupVehicleViewControllerState) {
        userInterface.render(newState: newState)

        (parent?.flowGuide as? SetupGuide)?.vehicle = newState.vehicleProfile
        (parent?.flowGuide as? SetupGuide)?.camera = newState.selectedCamera
        (parent?.flowGuide as? SetupGuide)?.driver = newState.selectedDriver

        if newState.viewState.activityIndicatingState == .doneSaving {
            if newState.selectedDriver != nil && newState.vehicleProfile.driverID != newState.selectedDriver?.driverID {
                bindingTaskCount += 1
                bindDriverUseCaseFactory.makeBindDriverUseCase().start()
            }

            if newState.selectedCamera != nil {
                bindingTaskCount += 1
                bindCameraUseCaseFactory.makeBindCameraUseCase().start()
            }

            if newState.selectedDriver == nil && newState.selectedCamera == nil {
                HNMessage.dismiss(withDelay: 1.0)
                parent?.flowGuide?.nextStep()
            }
        }
        else if newState.viewState.activityIndicatingState == .doneBinding {
            bindingTaskCount -= 1

            if bindingTaskCount <= 0 {
                HNMessage.dismiss(withDelay: 1.0)
                parent?.flowGuide?.nextStep()
            }
        }

        switch (newState.bindDriverFailed, newState.bindCameraFailed) {
        case (true, true):
            HNMessage.dismiss()

            self.topMostViewController.alert(title: nil, message: NSLocalizedString("Vehicle Added. But it failed when it was bound to the vehicle and assigned to the driver. Please bind and assign again manually.", comment: "Vehicle Added. But it failed when it was bound to the vehicle and assigned to the driver. Please bind and assign again manually."), action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in

                })
            })
        case (true, false):
            HNMessage.dismiss()

            self.topMostViewController.alert(title: nil, message: NSLocalizedString("Vehicle Added. But it failed when it was assigned to the driver.\nPlease assign again manually.", comment: "Vehicle Added. But it failed when it was assigned to the driver.\nPlease assign again manually."), action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                    self?.parent?.flowGuide?.nextStep()
                })
            })
        case (false, true):
            HNMessage.dismiss()

            self.topMostViewController.alert(title: nil, message: NSLocalizedString("Vehicle Added. But it failed when it was bound to the camera.\nPlease bind again manually.", comment: "Vehicle Added. But it failed when it was bound to the camera.\nPlease bind again manually."), action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in

                })
            })
        default:
            break
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState == .saving {
                HNMessage.show(message: activityIndicatingState.message)
            }
            else if activityIndicatingState == .doneSaving {
                HNMessage.showSuccess(message: activityIndicatingState.message)
            }
        }
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }

    func received(newSelectedDriver: FleetMember?) {
        if navigationController?.topViewController != self {
            navigationController?.popViewController(animated: true)
        }
    }

    func received(newVehicleProfile: VehicleProfile?) {
        if navigationController?.topViewController != self {
            navigationController?.popViewController(animated: true)
        }
    }
}

protocol SetupVehicleViewControllerFactory {
    func makeDriverSelectorViewController() -> UIViewController
}
