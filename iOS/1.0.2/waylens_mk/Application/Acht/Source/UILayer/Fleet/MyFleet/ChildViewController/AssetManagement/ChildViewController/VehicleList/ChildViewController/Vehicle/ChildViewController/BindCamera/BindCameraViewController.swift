//
//  BindCameraViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BindCameraViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: BindCameraUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let bindCameraUseCaseFactory: BindCameraUseCaseFactory

    init(
        observer: Observer,
        userInterface: BindCameraUserInterfaceView,
        loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        bindCameraUseCaseFactory: BindCameraUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadCameraListUseCaseFactory = loadCameraListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.bindCameraUseCaseFactory = bindCameraUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Choose a Camera", comment: "Choose a Camera")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Finish", comment: "Finish"), style: .done, target: self, action: #selector(finishButtonTapped(_:)))
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

        loadCameraListUseCaseFactory.makeLoadCameraListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension BindCameraViewController {

    @objc func finishButtonTapped(_ sender: Any) {
        bindCameraUseCaseFactory.makeBindCameraUseCase().start()
    }

}

extension BindCameraViewController: BindCameraIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

}

extension BindCameraViewController: ObserverForBindCameraEventResponder {

    func received(newState: BindCameraViewControllerState) {
        if newState.dataSource.selectedIndexPath != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState.isSuccess {
            navigationController?.popViewController(animated: true)
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

protocol BindCameraViewControllerFactory {

}
