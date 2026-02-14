//
//  DataUsageViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DataUsageViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: DataUsageUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let fetchBillingDataUseCaseFactory: FetchBillingDataUseCaseFactory
    private let dataUsageViewControllerFactory: DataUsageViewControllerFactory
    private let fetchHistoricalBillingDataUseCaseFactory: FetchHistoricalBillingDataUseCaseFactory

    init(
        observer: Observer,
        userInterface: DataUsageUserInterfaceView,
        dataUsageViewControllerFactory: DataUsageViewControllerFactory,
        fetchBillingDataUseCaseFactory: FetchBillingDataUseCaseFactory,
        fetchHistoricalBillingDataUseCaseFactory: FetchHistoricalBillingDataUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.dataUsageViewControllerFactory = dataUsageViewControllerFactory
        self.fetchBillingDataUseCaseFactory = fetchBillingDataUseCaseFactory
        self.fetchHistoricalBillingDataUseCaseFactory = fetchHistoricalBillingDataUseCaseFactory
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchBillingDataUseCaseFactory.makeFetchBillingDataUseCase().start()
        fetchHistoricalBillingDataUseCaseFactory.makeFetchHistoricalBillingDataUseCase().start()
    }

}

//MARK: - Private

private extension DataUsageViewController {

}

extension DataUsageViewController: DataUsageIxResponder {

    func select(item: BillingData) {
        let vc = dataUsageViewControllerFactory.makeBillingDetailViewController(billingData: item)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension DataUsageViewController: ObserverForDataUsageEventResponder {

    func received(newState: DataUsageViewControllerState) {
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

protocol DataUsageViewControllerFactory {
    func makeBillingDetailViewController(billingData: BillingData) -> UIViewController
}
