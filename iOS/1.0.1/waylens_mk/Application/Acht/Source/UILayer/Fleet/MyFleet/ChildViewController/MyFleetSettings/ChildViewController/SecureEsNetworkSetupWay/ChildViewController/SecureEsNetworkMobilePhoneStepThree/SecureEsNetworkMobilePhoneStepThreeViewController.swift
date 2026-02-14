//
//  SecureEsNetworkMobilePhoneStepThreeViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMobilePhoneStepThreeViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: SecureEsNetworkMobilePhoneStepThreeUserInterfaceView
    private let viewControllerFactory: SecureEsNetworkMobilePhoneStepThreeViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: SecureEsNetworkMobilePhoneStepThreeUserInterfaceView,
        viewControllerFactory: SecureEsNetworkMobilePhoneStepThreeViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("SecureES Network", comment: "SecureES Network")
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

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepThreeViewController {

}

extension SecureEsNetworkMobilePhoneStepThreeViewController: SecureEsNetworkMobilePhoneStepThreeIxResponder {

    func doneAndGoBack() {
        dismiss(animated: true, completion: nil)
    }

}

extension SecureEsNetworkMobilePhoneStepThreeViewController: ObserverForSecureEsNetworkMobilePhoneStepThreeEventResponder {

    func received(newState: SecureEsNetworkMobilePhoneStepThreeViewControllerState) {
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

protocol SecureEsNetworkMobilePhoneStepThreeViewControllerFactory {

}
