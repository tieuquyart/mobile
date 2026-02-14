//
//  SecureEsNetworkMobilePhoneStepTwoViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMobilePhoneStepTwoViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: SecureEsNetworkMobilePhoneStepTwoUserInterfaceView
    private let viewControllerFactory: SecureEsNetworkMobilePhoneStepTwoViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let addSsidToCameraUseCaseFactory: AddSsidToCameraUseCaseFactory

    init(
        observer: Observer,
        userInterface: SecureEsNetworkMobilePhoneStepTwoUserInterfaceView,
        addSsidToCameraUseCaseFactory: AddSsidToCameraUseCaseFactory,
        viewControllerFactory: SecureEsNetworkMobilePhoneStepTwoViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.addSsidToCameraUseCaseFactory = addSsidToCameraUseCaseFactory
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

private extension SecureEsNetworkMobilePhoneStepTwoViewController {

}

extension SecureEsNetworkMobilePhoneStepTwoViewController: SecureEsNetworkMobilePhoneStepTwoIxResponder {

    func nextStep(with ssid: String, password: String) {
        addSsidToCameraUseCaseFactory.makeAddSsidToCameraUseCase(ssid: ssid, password: password).start()
    }

}

extension SecureEsNetworkMobilePhoneStepTwoViewController: ObserverForSecureEsNetworkMobilePhoneStepTwoEventResponder {

    func received(newState: SecureEsNetworkMobilePhoneStepTwoViewControllerState) {
        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState.isSuccess {
            alert(message: NSLocalizedString("The SSID and password has been successfully saved in the camera.\nPlease disconnect the phone from the camera WiFi and the camera will automatically connect to the hotspot.", comment: "The SSID and password has been successfully saved in the camera.\nPlease disconnect the phone from the camera WiFi and the camera will automatically connect to the hotspot.")) { () -> UIAlertAction in
                return UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
                    self?.dismiss(animated: true, completion: nil)
                }
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
}

protocol SecureEsNetworkMobilePhoneStepTwoViewControllerFactory {
    func makeViewControllerForNextStep() -> UIViewController
}
