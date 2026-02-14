//
//  GeoFenceRuleTypeAndScopeViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceRuleTypeAndScopeViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceRuleTypeAndScopeUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let editGeoFenceRuleUseCaseFactory: EditGeoFenceRuleUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let saveGeoFenceRuleUseCaseFactory: SaveGeoFenceRuleUseCaseFactory
    private let viewControllerFactory: GeoFenceRuleTypeAndScopeViewControllerFactory

    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))

    init(
        observer: Observer,
        userInterface: GeoFenceRuleTypeAndScopeUserInterfaceView,
        viewControllerFactory: GeoFenceRuleTypeAndScopeViewControllerFactory,
        editGeoFenceRuleUseCaseFactory: EditGeoFenceRuleUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        saveGeoFenceRuleUseCaseFactory: SaveGeoFenceRuleUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.editGeoFenceRuleUseCaseFactory = editGeoFenceRuleUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.saveGeoFenceRuleUseCaseFactory = saveGeoFenceRuleUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Type and Scope", comment: "Type and Scope")
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

        if previousViewControllerInNavigationStack == nil {
            navigationItem.leftBarButtonItem = cancelButton
        }
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension GeoFenceRuleTypeAndScopeViewController {

    @objc
    func cancelButtonTapped() {
        navigationController?.dismissMyself(animated: true)
    }
}

extension GeoFenceRuleTypeAndScopeViewController: GeoFenceRuleTypeAndScopeIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func nextStep() {
        let vc = viewControllerFactory.makeViewControllerForNextStep()
        navigationController?.pushViewController(vc, animated: true)
    }

    func changeRule(using ruleReducer: @escaping GeoFenceRuleReducer) {
        editGeoFenceRuleUseCaseFactory.makeEditGeoFenceRuleUseCase(ruleReducer).start()
    }

    func saveGeoFenceRule() {
        saveGeoFenceRuleUseCaseFactory.makeSaveGeoFenceRuleUseCase(completion: {[weak self] in
            self?.navigationController?.dismissMyself(animated: true)
            })
            .start()
    }

}

extension GeoFenceRuleTypeAndScopeViewController: ObserverForGeoFenceRuleTypeAndScopeEventResponder {

    func received(newState: GeoFenceRuleTypeAndScopeViewControllerState) {
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

protocol GeoFenceRuleTypeAndScopeViewControllerFactory {
    func makeViewControllerForNextStep() -> UIViewController
}
