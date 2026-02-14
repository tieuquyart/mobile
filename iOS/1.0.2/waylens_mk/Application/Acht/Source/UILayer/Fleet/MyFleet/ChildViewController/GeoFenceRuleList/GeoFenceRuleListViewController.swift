//
//  GeoFenceRuleListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceRuleListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceRuleListUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadGeoFenceRuleListUseCaseFactory: LoadGeoFenceRuleListUseCaseFactory
    private let viewControllerFactory: GeoFenceRuleListViewControllerFactory

    init(
        observer: Observer,
        userInterface: GeoFenceRuleListUserInterfaceView,
        loadGeoFenceRuleListUseCaseFactory: LoadGeoFenceRuleListUseCaseFactory,
        viewControllerFactory: GeoFenceRuleListViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase
        self.viewControllerFactory = viewControllerFactory
        self.loadGeoFenceRuleListUseCaseFactory = loadGeoFenceRuleListUseCaseFactory

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Geo-fencing", comment: "Geo-fencing")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: "Add"), style: UIBarButtonItem.Style.plain, actionBlock: { [weak self] (barButton) in
            guard let self = self else {
                return
            }

            let vc = viewControllerFactory.makeGeoFenceRuleComposingViewController().embedInNavigationController()
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        })
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

        loadGeoFenceRuleListUseCaseFactory.makeLoadGeoFenceRuleListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension GeoFenceRuleListViewController {

}

extension GeoFenceRuleListViewController: GeoFenceRuleListIxResponder {

    func select(indexPath: IndexPath) {
        let vc = viewControllerFactory.makeViewController(for: indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension GeoFenceRuleListViewController: ObserverForGeoFenceRuleListEventResponder {

    func received(newState: GeoFenceRuleListViewControllerState) {
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

extension GeoFenceRuleListViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.title = NSLocalizedString("Add New Zone", comment: "Add New Zone")
    }

}

protocol GeoFenceRuleListViewControllerFactory {
    func makeViewController(for indexPath: IndexPath) -> UIViewController
    func makeGeoFenceRuleComposingViewController() -> UIViewController
}
