//
//  AddNewPlateNumberViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewPlateNumberViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: AddNewPlateNumberUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let makeAddNewVehicleUseCase: (String?) -> UseCase

    init(
        observer: Observer,
        userInterface: AddNewPlateNumberUserInterfaceView,
        makeAddNewVehicleUseCase: @escaping (String?) -> UseCase,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.makeAddNewVehicleUseCase = makeAddNewVehicleUseCase
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Add New Plate Number", comment: "Add New Plate Number")

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

private extension AddNewPlateNumberViewController {

    @objc func addButtonTapped(_ sender: Any) {
        guard let plateNumber = userInterface.plateNumber else {
            alert(message: NSLocalizedString("Please input plate number.", comment: "Please input plate number."))
            return
        }

        alert(title: "Plate Number" + ": " + plateNumber, message: NSLocalizedString("The Plate Number can not be changed once the vehicle added to the fleet.\n\nSure to add the vehicle?", comment: "The Plate Number can not be changed once the vehicle added to the fleet.\n\nSure to add the vehicle?")
            , action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { [weak self] _ in
                self?.makeAddNewVehicleUseCase(plateNumber).start()
            })
        }

    }

    @objc func cancelButtonTapped(_ sender: Any) {
        dismissMyself(animated: true)
    }

}

extension AddNewPlateNumberViewController: AddNewPlateNumberIxResponder {

}

extension AddNewPlateNumberViewController: ObserverForAddNewPlateNumberEventResponder {

    func received(newState: AddNewPlateNumberViewControllerState) {
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

protocol AddNewPlateNumberViewControllerFactory {

}
