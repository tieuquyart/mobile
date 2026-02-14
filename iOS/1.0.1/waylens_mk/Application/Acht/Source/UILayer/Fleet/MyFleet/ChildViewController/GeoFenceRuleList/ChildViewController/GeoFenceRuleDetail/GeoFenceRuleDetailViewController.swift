//
//  GeoFenceRuleDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceRuleDetailViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceRuleDetailUserInterfaceView
    private let loadGeoFenceUseCaseFactory: LoadGeoFenceUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let viewControllerFactory: GeoFenceRuleDetailViewControllerFactory
    private let removeGeoFenceRuleUseCaseFactory: RemoveGeoFenceRuleUseCaseFactory
    private let loadGeoFenceRuleUseCaseFactory: LoadGeoFenceRuleUseCaseFactory

    init(
        observer: Observer,
        userInterface: GeoFenceRuleDetailUserInterfaceView,
        viewControllerFactory: GeoFenceRuleDetailViewControllerFactory,
        loadGeoFenceUseCaseFactory: LoadGeoFenceUseCaseFactory,
        loadGeoFenceRuleUseCaseFactory: LoadGeoFenceRuleUseCaseFactory,
        removeGeoFenceRuleUseCaseFactory: RemoveGeoFenceRuleUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.loadGeoFenceUseCaseFactory = loadGeoFenceUseCaseFactory
        self.loadGeoFenceRuleUseCaseFactory = loadGeoFenceRuleUseCaseFactory
        self.removeGeoFenceRuleUseCaseFactory = removeGeoFenceRuleUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Edit", comment: "Edit"), style: .plain, actionBlock: { [weak self] (item) in
            guard let self = self else {
                return
            }

            let vc = viewControllerFactory.makeGeoFenceRuleComposingViewController()
            vc.modalPresentationStyle = .fullScreen
            (vc as? UINavigationController)?.delegate = self
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

        loadGeoFenceUseCaseFactory.makeLoadGeoFenceUseCase(geoFenceID: nil).start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadGeoFenceRuleUseCaseFactory.makeLoadGeoFenceRuleUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension GeoFenceRuleDetailViewController {

}

extension GeoFenceRuleDetailViewController: GeoFenceRuleDetailIxResponder {

    func showTriggeringVehicles() {
        let vc = viewControllerFactory.makeTriggeringVehicleListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func deleteGeoFenceRule() {
        alert(title: nil, message: NSLocalizedString("Are you sure to remove this geo-fence?", comment: "Are you sure to remove this geo-fence?"), action1: { [weak self] () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertAction.Style.destructive) { (_) in
                self?.removeGeoFenceRuleUseCaseFactory.makeRemoveGeoFenceRuleUseCase {
                    self?.navigationController?.popViewController(animated: true)
                }
                .start()
            }
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel, handler: nil)
        }
    }

}

extension GeoFenceRuleDetailViewController: ObserverForGeoFenceRuleDetailEventResponder {

    func received(newState: GeoFenceRuleDetailViewControllerState) {
        title = newState.rule?.name

        if newState.fence != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
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

extension GeoFenceRuleDetailViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.title = self.title
    }

}

protocol GeoFenceRuleDetailViewControllerFactory {
    func makeTriggeringVehicleListViewController() -> UIViewController
    func makeGeoFenceRuleComposingViewController() -> UIViewController
}
