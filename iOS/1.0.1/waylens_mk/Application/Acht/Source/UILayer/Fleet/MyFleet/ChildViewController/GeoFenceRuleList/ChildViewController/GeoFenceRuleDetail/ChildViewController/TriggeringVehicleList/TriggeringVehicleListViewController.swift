//
//  TriggeringVehicleListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: TriggeringVehicleListUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory
    private let viewControllerFactory: TriggeringVehicleListViewControllerFactory
    private let loadGeoFenceRuleUseCaseFactory: LoadGeoFenceRuleUseCaseFactory

    init(
        observer: Observer,
        userInterface: TriggeringVehicleListUserInterfaceView,
        viewControllerFactory: TriggeringVehicleListViewControllerFactory,
        loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory,
        loadGeoFenceRuleUseCaseFactory: LoadGeoFenceRuleUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.loadVehicleListUseCaseFactory = loadVehicleListUseCaseFactory
        self.loadGeoFenceRuleUseCaseFactory = loadGeoFenceRuleUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Triggering Vehicles", comment: "Triggering Vehicles")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editBarButtonTapped))
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

        loadGeoFenceRuleUseCaseFactory.makeLoadGeoFenceRuleUseCase().start()
        loadVehicleListUseCaseFactory.makeLoadVehicleListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension TriggeringVehicleListViewController {

    func showEditViewController() {
        let vc = viewControllerFactory.makeViewControllerForEdit().embedInNavigationController()
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc
    func editBarButtonTapped() {
        showEditViewController()
    }

}

extension TriggeringVehicleListViewController: TriggeringVehicleListIxResponder {

    func addItems() {
        showEditViewController()
    }

    func select(indexPath: IndexPath) {

    }

}

extension TriggeringVehicleListViewController: ObserverForTriggeringVehicleListEventResponder {

    func received(newState: TriggeringVehicleListViewControllerState) {
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

extension TriggeringVehicleListViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.title = self.title
    }

}

protocol TriggeringVehicleListViewControllerFactory {
    func makeViewControllerForEdit() -> UIViewController
}
