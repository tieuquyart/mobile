//
//  GeoFenceDraftBoxViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceDraftBoxViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceDraftBoxUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: GeoFenceDraftBoxUserInterfaceView,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Draft Box", comment: "Draft Box")
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

private extension GeoFenceDraftBoxViewController {

}

extension GeoFenceDraftBoxViewController: GeoFenceDraftBoxIxResponder {

    func select(indexPath: IndexPath) {

    }

}

extension GeoFenceDraftBoxViewController: ObserverForGeoFenceDraftBoxEventResponder {

    func received(newState: GeoFenceDraftBoxViewControllerState) {
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

protocol GeoFenceDraftBoxViewControllerFactory {

}
