//
//  VehicleListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: VehicleListUserInterfaceView
    private let loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory
    private let vehicleListViewControllerFactory: VehicleListViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: VehicleListUserInterfaceView,
        loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory,
        vehicleListViewControllerFactory: VehicleListViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadVehicleListUseCaseFactory = loadVehicleListUseCaseFactory
        self.vehicleListViewControllerFactory = vehicleListViewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Vehicles", comment: "Vehicles")
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

private extension VehicleListViewController {

}

extension VehicleListViewController: VehicleListIxResponder {

    func selectVehicle(at index: Int) {
        let vc = vehicleListViewControllerFactory.makeVehicleViewController(with: index)
        navigationController?.pushViewController(vc, animated: true)
    }

    func addNewVehicle() {
        let vc = vehicleListViewControllerFactory.makeAddNewVehicleViewController().embedInNavigationController()

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }

        present(vc, animated: true, completion: nil)
    }
    
}

extension VehicleListViewController: ObserverForVehicleListEventResponder {

    func received(newState: VehicleListViewControllerState) {
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

protocol VehicleListViewControllerFactory {
    func makeVehicleViewController(with vehicleIndex: Int) -> UIViewController
    func makeAddNewVehicleViewController() -> UIViewController
}
