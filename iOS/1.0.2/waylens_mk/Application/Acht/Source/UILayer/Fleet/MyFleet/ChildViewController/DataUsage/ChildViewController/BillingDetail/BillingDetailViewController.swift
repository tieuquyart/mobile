//
//  BillingDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingDetailViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: BillingDetailUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: BillingDetailUserInterfaceView,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Data Usage", comment: "Data Usage")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        
        observer.startObserving()
    }

}

//MARK: - Private

private extension BillingDetailViewController {

}

extension BillingDetailViewController: BillingDetailIxResponder {

    func select(indexPath: IndexPath) {

    }

}

extension BillingDetailViewController: ObserverForBillingDetailEventResponder {

    func received(newState: BillingDetailViewControllerState) {
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

protocol BillingDetailViewControllerFactory {

}
