//
//  CameraTypeSelectionViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraTypeSelectionViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CameraTypeSelectionUserInterfaceView
    private let viewControllerFactory: CameraTypeSelectionViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: CameraTypeSelectionUserInterfaceView,
        viewControllerFactory: CameraTypeSelectionViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
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

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension CameraTypeSelectionViewController {

}

extension CameraTypeSelectionViewController: CameraTypeSelectionIxResponder {

    func select(cameraType: CameraType) {
        if let vc = viewControllerFactory.makeViewController(for: cameraType) {
            switch vc {
            case is UINavigationController:
                wl.present(vc, animated: true, completion: nil)
            default:
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            SetupGuide(
                scene: .installerGuide,
                presenter: InstallerSetupGuidePresenter()
            ).start()
        }
    }

}

extension CameraTypeSelectionViewController: ObserverForCameraTypeSelectionEventResponder {

    func received(newState: CameraTypeSelectionViewControllerState) {
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

protocol CameraTypeSelectionViewControllerFactory {
    func makeViewController(for cameraType: CameraType) -> UIViewController?
}
