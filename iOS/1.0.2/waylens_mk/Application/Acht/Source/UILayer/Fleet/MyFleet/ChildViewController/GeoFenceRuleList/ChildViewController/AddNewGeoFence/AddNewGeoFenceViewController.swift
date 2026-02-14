//
//  AddNewGeoFenceViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewGeoFenceViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: AddNewGeoFenceUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let editGeoFenceRuleUseCaseFactory: EditGeoFenceRuleUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let viewControllerFactory: AddNewGeoFenceViewControllerFactory
    private let checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory: CheckIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory?
    private let checkIfExistSameNameGeoFenceRuleUseCaseFactory: CheckIfExistSameNameGeoFenceRuleUseCaseFactory

    private var isFirstAppeared = true

    init(
        observer: Observer,
        userInterface: AddNewGeoFenceUserInterfaceView,
        editGeoFenceRuleUseCaseFactory: EditGeoFenceRuleUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory: CheckIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory?,
        checkIfExistSameNameGeoFenceRuleUseCaseFactory: CheckIfExistSameNameGeoFenceRuleUseCaseFactory,
        viewControllerFactory: AddNewGeoFenceViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.editGeoFenceRuleUseCaseFactory = editGeoFenceRuleUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory = checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory
        self.checkIfExistSameNameGeoFenceRuleUseCaseFactory = checkIfExistSameNameGeoFenceRuleUseCaseFactory
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
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

        if isFirstAppeared {
            checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory?.makeCheckIfReachLimitOfGeoFenceRuleQuantityUseCase { [weak self] (isReached, error) in
                guard let self = self else {
                    return
                }

                if let error = error {
                    self.alert(title: nil, message: error.localizedDescription, action1: { () -> UIAlertAction in
                        return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in
                            self.dismissMyself(animated: true)
                        })
                    })
                }
                else {
                    if isReached {
                        let message = NSLocalizedString("The number of Geo-fences has reached the limit (32), no more can be added at the moment.", comment: "The number of Geo-fences has reached the limit (32), no more can be added at the moment.")
                        self.alert(title: nil, message: message, action1: { () -> UIAlertAction in
                            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in
                                self.dismissMyself(animated: true)
                            })
                        })
                    }
                    else {
                        self.userInterface.beginEditingName()
                    }
                }
            }.start()

            isFirstAppeared = false
        }
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension AddNewGeoFenceViewController {

    @objc
    func cancelButtonTapped() {
        dismissMyself(animated: true)
    }

}

extension AddNewGeoFenceViewController: AddNewGeoFenceIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func changeRule(using ruleReducer: @escaping (inout GeoFenceRuleForEdit) -> ()) {
        editGeoFenceRuleUseCaseFactory.makeEditGeoFenceRuleUseCase(ruleReducer).start()
    }

    func nextStep() {
        checkIfExistSameNameGeoFenceRuleUseCaseFactory.makeCheckIfExistSameNameGeoFenceRuleUseCase { [weak self] (isExisted, error) in
            guard let self = self else {
                return
            }

            if let error = error {
                self.alert(title: nil, message: error.localizedDescription, action1: { () -> UIAlertAction in
                    return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in

                    })
                })
            }
            else {
                if isExisted {
                    let message = NSLocalizedString("The zone name has been used.", comment: "The zone name has been used.")
                    self.alert(title: nil, message: message, action1: { () -> UIAlertAction in
                        return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in

                        })
                    })
                }
                else {
                    if let vc = self.viewControllerFactory.makeNextStepViewController() {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }.start()
    }

}

extension AddNewGeoFenceViewController: ObserverForAddNewGeoFenceEventResponder {

    func received(newState: AddNewGeoFenceViewControllerState) {
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

protocol AddNewGeoFenceViewControllerFactory {
    func makeNextStepViewController() -> UIViewController?
}
