//
//  GeoFenceDrawingViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceDrawingViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceDrawingUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let composeGeoFenceUseCaseFactory: ComposeGeoFenceUseCaseFactory
    private let cleanGeoFenceUseCaseFactory: CleanGeoFenceUseCaseFactory
    private let saveGeoFenceUseCaseFactory: SaveGeoFenceUseCaseFactory
    private let viewControllerFactory: GeoFenceDrawingViewControllerFactory

    init(
        observer: Observer,
        userInterface: GeoFenceDrawingUserInterfaceView,
        viewControllerFactory: GeoFenceDrawingViewControllerFactory,
        composeGeoFenceUseCaseFactory: ComposeGeoFenceUseCaseFactory,
        cleanGeoFenceUseCaseFactory: CleanGeoFenceUseCaseFactory,
        saveGeoFenceUseCaseFactory: SaveGeoFenceUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.composeGeoFenceUseCaseFactory = composeGeoFenceUseCaseFactory
        self.saveGeoFenceUseCaseFactory = saveGeoFenceUseCaseFactory
        self.cleanGeoFenceUseCaseFactory = cleanGeoFenceUseCaseFactory

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

    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        observer.startObserving()

        locationManager.requestWhenInUseAuthorization()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension GeoFenceDrawingViewController {

}

extension GeoFenceDrawingViewController: GeoFenceDrawingIxResponder {

    func composeGeoFence(with data: Any) {
        composeGeoFenceUseCaseFactory.makeComposeGeoFenceUseCase(composedData: data).start()
    }

    func cleanGeoFence() {
        cleanGeoFenceUseCaseFactory.makeCleanGeoFenceUseCase().start()
    }

    func doneComposingGeoFence() {
        saveGeoFenceUseCaseFactory.makeSaveGeoFenceUseCase().start()
    }

    func nextStep() {
        let vc = viewControllerFactory.makeViewControllerForNextStep()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showLocationPicker() {
        let vc = viewControllerFactory.makeViewControllerForSearchingLocation()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    func editRange() {
        if let vc = viewControllerFactory.makeViewControllerForEditingRange() {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension GeoFenceDrawingViewController: ObserverForGeoFenceDrawingEventResponder {

    func received(newState: GeoFenceDrawingViewControllerState) {
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

protocol GeoFenceDrawingViewControllerFactory {
    func makeViewControllerForNextStep() -> UIViewController
    func makeViewControllerForSearchingLocation() -> UIViewController
    func makeViewControllerForEditingRange() -> UIViewController?
}
