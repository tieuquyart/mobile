//
//  AddNewCameraViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class AddNewCameraViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: AddNewCameraUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let addNewCameraUseCaseFactory: AddNewCameraUseCaseFactory
    private let generalUseCaseFactory: GeneralUseCaseFactory

    init(
        observer: Observer,
        userInterface: AddNewCameraUserInterfaceView,
        addNewCameraUseCaseFactory: AddNewCameraUseCaseFactory,
        generalUseCaseFactory: GeneralUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.addNewCameraUseCaseFactory = addNewCameraUseCaseFactory
        self.generalUseCaseFactory = generalUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Add New Camera", comment: "Add New Camera")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: "Add"), style: .done, target: self, action: #selector(addButtonTapped))
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

private extension AddNewCameraViewController {

    @objc func addButtonTapped(_ sender: Any) {
        guard let sn = userInterface.sn, let password = userInterface.password else {
            alert(message: NSLocalizedString("Please input complete camera info.", comment: "Please input complete camera info."))
            return
        }

        addNewCameraUseCaseFactory.makeAddNewCameraUseCase(cameraSN: sn, password: password).start()
    }

    @objc func cancelButtonTapped(_ sender: Any) {
        dismissMyself(animated: true)
    }

}

extension AddNewCameraViewController: AddNewCameraIxResponder {

}

extension AddNewCameraViewController: ObserverForAddNewCameraEventResponder {

    func received(newState: AddNewCameraViewControllerState) {
        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState.isSuccess {
            dismissMyself(animated: true)
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

extension AddNewCameraViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        generalUseCaseFactory.makeGeneralUseCase(value: camera as Any).start()
    }

}

protocol AddNewCameraViewControllerFactory {

}
