//
//  DriverSelectorViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DriverSelectorViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: DriverSelectorUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let selectorFinishUseCaseFactory: SelectorFinishUseCaseFactory

    init(
        observer: Observer,
        userInterface: DriverSelectorUserInterfaceView,
        loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        selectorFinishUseCaseFactory: SelectorFinishUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadMemberListUseCaseFactory = loadMemberListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.selectorFinishUseCaseFactory = selectorFinishUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Choose a Driver", comment: "Choose a Driver")

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

        loadMemberListUseCaseFactory.makeLoadMemberListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension DriverSelectorViewController {

    @objc func finishButtonTapped(_ sender: Any) {
        selectorFinishUseCaseFactory.makeSelectorFinishUseCase().start()
    }

}

extension DriverSelectorViewController: DriverSelectorIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

}

extension DriverSelectorViewController: ObserverForDriverSelectorEventResponder {

    func received(newState: DriverSelectorViewControllerState) {
        if newState.dataSource.selectedIndexPath != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

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

protocol DriverSelectorViewControllerFactory {

}
