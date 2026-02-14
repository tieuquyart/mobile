//
//  ActivateCameraViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ActivateCameraViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: ActivateCameraUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let activateCameraSimCardUseCaseFactory: ActivateCameraSimCardUseCaseFactory

    init(
        observer: Observer,
        userInterface: ActivateCameraUserInterfaceView,
        activateCameraSimCardUseCaseFactory: ActivateCameraSimCardUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.activateCameraSimCardUseCaseFactory = activateCameraSimCardUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Activate", comment: "Activate")
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

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension ActivateCameraViewController {

}

extension ActivateCameraViewController: ActivateCameraIxResponder {

    func select(indexPath: IndexPath) {

    }

    func nextStep() {
        activateCameraSimCardUseCaseFactory.makeActivateCameraSimCardUseCase().start()
    }
}

extension ActivateCameraViewController: ObserverForActivateCameraEventResponder {

    func received(newState: ActivateCameraViewControllerState) {
        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState == .doneActivating {
            parent?.flowGuide?.nextStep()
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

protocol ActivateCameraViewControllerFactory {

}
