//
//  CalibrationInstallationPositionViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CalibrationInstallationPositionViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CalibrationInstallationPositionUserInterfaceView
    private let viewControllerFactory: CalibrationInstallationPositionViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: CalibrationInstallationPositionUserInterfaceView,
        viewControllerFactory: CalibrationInstallationPositionViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        initHeader(text: NSLocalizedString("", comment: ""), leftButton: true)
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

private extension CalibrationInstallationPositionViewController {

}

extension CalibrationInstallationPositionViewController: CalibrationInstallationPositionIxResponder {

    func nextStep() {
        parent?.flowGuide?.nextStep()
    }

}

extension CalibrationInstallationPositionViewController: ObserverForCalibrationInstallationPositionEventResponder {

    func received(newState: CalibrationInstallationPositionViewControllerState) {
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

protocol CalibrationInstallationPositionViewControllerFactory {

}
