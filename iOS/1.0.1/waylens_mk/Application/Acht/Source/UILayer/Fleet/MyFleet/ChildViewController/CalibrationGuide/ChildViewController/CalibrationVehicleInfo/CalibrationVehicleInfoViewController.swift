//
//  CalibrationVehicleInfoViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CalibrationVehicleInfoViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CalibrationVehicleInfoUserInterfaceView
    private let viewControllerFactory: CalibrationVehicleInfoViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory

    init(
        observer: Observer,
        userInterface: CalibrationVehicleInfoUserInterfaceView,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        viewControllerFactory: CalibrationVehicleInfoViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("", comment: "")
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

private extension CalibrationVehicleInfoViewController {

}

extension CalibrationVehicleInfoViewController: CalibrationVehicleInfoIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func nextStep(with selectedItems: [CalibrationVehicleInfoViewState.Element]) {
        let isRudderOnTheRight = selectedItems.contains(.right)

        if selectedItems.contains(.carOrSmallSuv) {
            (parent?.flowGuide as? CalibrationGuide)?.driverPosition = (x: 105, y: 38 * (isRudderOnTheRight ? 1 : -1), z: 88)
        }
        else if selectedItems.contains(.largeSuvOrPickup) {
            (parent?.flowGuide as? CalibrationGuide)?.driverPosition = (x: 125, y: 42 * (isRudderOnTheRight ? 1 : -1), z: 110)
        }
        else { // truck
            (parent?.flowGuide as? CalibrationGuide)?.driverPosition = (x: 115, y: 45 * (isRudderOnTheRight ? 1 : -1), z: 130)
        }

        parent?.flowGuide?.nextStep()
    }
}

extension CalibrationVehicleInfoViewController: ObserverForCalibrationVehicleInfoEventResponder {

    func received(newState: CalibrationVehicleInfoViewControllerState) {
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

protocol CalibrationVehicleInfoViewControllerFactory {

}
