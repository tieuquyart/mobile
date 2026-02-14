//
//  BindDriverViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BindDriverViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: BindDriverUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let bindDriverUseCaseFactory: BindDriverUseCaseFactory

    init(
        observer: Observer,
        userInterface: BindDriverUserInterfaceView,
        loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        bindDriverUseCaseFactory: BindDriverUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadMemberListUseCaseFactory = loadMemberListUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.bindDriverUseCaseFactory = bindDriverUseCaseFactory
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

private extension BindDriverViewController {

    @objc func finishButtonTapped(_ sender: Any) {
        bindDriverUseCaseFactory.makeBindDriverUseCase().start()
    }

}

extension BindDriverViewController: BindDriverIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
    }

}

extension BindDriverViewController: ObserverForBindDriverEventResponder {

    func received(newState: BindDriverViewControllerState) {
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

protocol BindDriverViewControllerFactory {

}
