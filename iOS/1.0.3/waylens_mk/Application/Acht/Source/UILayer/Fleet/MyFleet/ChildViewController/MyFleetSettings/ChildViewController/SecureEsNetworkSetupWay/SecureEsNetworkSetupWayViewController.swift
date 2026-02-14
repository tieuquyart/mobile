//
//  SecureEsNetworkSetupWayViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkSetupWayViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: SecureEsNetworkSetupWayUserInterfaceView
    private let viewControllerFactory: SecureEsNetworkSetupWayViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: SecureEsNetworkSetupWayUserInterfaceView,
        viewControllerFactory: SecureEsNetworkSetupWayViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("SecureES Network", comment: "SecureES Network")

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

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.white
    }

}

//MARK: - Private

private extension SecureEsNetworkSetupWayViewController {

    @objc
    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

}

extension SecureEsNetworkSetupWayViewController : SecureEsNetworkSetupWayIxResponder {

    func select(setupWay: SecureEsNetworkSetupWay) {
        let vc = viewControllerFactory.makeViewController(for: setupWay)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension SecureEsNetworkSetupWayViewController: ObserverForSecureEsNetworkSetupWayEventResponder {

    func received(newState: SecureEsNetworkSetupWayViewControllerState) {
        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK") , style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

protocol SecureEsNetworkSetupWayViewControllerFactory {
    func makeViewController(for setupWay: SecureEsNetworkSetupWay) -> UIViewController
}
