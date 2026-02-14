//
//  VehicleSelectorViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleSelectorViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: VehicleSelectorUserInterfaceView
    private let vehicleSelectorViewControllerFactory: VehicleSelectorViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let selectorFinishUseCaseFactory: SelectorFinishUseCaseFactory

    init(
        observer: Observer,
        userInterface: VehicleSelectorUserInterfaceView,
        vehicleSelectorViewControllerFactory: VehicleSelectorViewControllerFactory,
        loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        selectorFinishUseCaseFactory: SelectorFinishUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.vehicleSelectorViewControllerFactory = vehicleSelectorViewControllerFactory
        self.loadVehicleListUseCaseFactory = loadVehicleListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.selectorFinishUseCaseFactory = selectorFinishUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Choose a Plate Number", comment: "Choose a Plate Number")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Finish", comment: "Finish"), style: .done, target: self, action: #selector(finishButtonTapped(_:)))
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

        loadVehicleListUseCaseFactory.makeLoadVehicleListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension VehicleSelectorViewController {

    @objc func finishButtonTapped(_ sender: Any) {
        selectorFinishUseCaseFactory.makeSelectorFinishUseCase().start()
    }

}

extension VehicleSelectorViewController: VehicleSelectorIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func addNewPlateNumber() {
        let vc = vehicleSelectorViewControllerFactory.makeAddNewPlateNumberViewController().embedInNavigationController()

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension VehicleSelectorViewController: ObserverForVehicleSelectorEventResponder {

    func received(newState: VehicleSelectorViewControllerState) {
        if newState.dataSource.selectedItem?.vehicleID != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

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

protocol VehicleSelectorViewControllerFactory {
    func makeAddNewPlateNumberViewController() -> UIViewController
}
