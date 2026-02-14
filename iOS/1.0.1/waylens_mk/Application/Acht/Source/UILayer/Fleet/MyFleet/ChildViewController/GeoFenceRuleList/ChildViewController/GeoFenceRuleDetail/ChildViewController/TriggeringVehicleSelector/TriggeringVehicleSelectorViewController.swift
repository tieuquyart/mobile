//
//  TriggeringVehicleSelectorViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleSelectorViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: TriggeringVehicleSelectorUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let saveGeoFenceRuleUseCaseFactory: SaveGeoFenceRuleUseCaseFactory

    init(
        observer: Observer,
        userInterface: TriggeringVehicleSelectorUserInterfaceView,
        loadVehicleListUseCaseFactory: LoadVehicleListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        saveGeoFenceRuleUseCaseFactory: SaveGeoFenceRuleUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadVehicleListUseCaseFactory = loadVehicleListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.saveGeoFenceRuleUseCaseFactory = saveGeoFenceRuleUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Triggering Vehicles", comment: "Triggering Vehicles")
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

        loadVehicleListUseCaseFactory.makeLoadVehicleListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension TriggeringVehicleSelectorViewController {

}

extension TriggeringVehicleSelectorViewController: TriggeringVehicleSelectorIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

    func saveCurrentState() {
        saveGeoFenceRuleUseCaseFactory.makeSaveGeoFenceRuleUseCase { [weak self] in
            guard let self = self else {
                return
            }

            self.navigationController?.dismissMyself(animated: true)
        }
        .start()
    }
}

extension TriggeringVehicleSelectorViewController: ObserverForTriggeringVehicleSelectorEventResponder {

    func received(newState: TriggeringVehicleSelectorViewControllerState) {
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

protocol TriggeringVehicleSelectorViewControllerFactory {

}
