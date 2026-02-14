//
//  CameraDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraDetailViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CameraDetailUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let fetchCameraInfoUseCaseFactory: FetchCameraInfoUseCaseFactory
    private let toggleFirmwareVersionUseCaseFactory: ToggleFirmwareVersionUseCaseFactory

    init(
        observer: Observer,
        userInterface: CameraDetailUserInterfaceView,
        fetchCameraInfoUseCaseFactory: FetchCameraInfoUseCaseFactory,
        toggleFirmwareVersionUseCaseFactory: ToggleFirmwareVersionUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.fetchCameraInfoUseCaseFactory = fetchCameraInfoUseCaseFactory
        self.toggleFirmwareVersionUseCaseFactory = toggleFirmwareVersionUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Camera Detail", comment: "Camera Detail")
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

        fetchCameraInfoUseCaseFactory.makeFetchCameraInfoUseCase()?.start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension CameraDetailViewController {

}

extension CameraDetailViewController: CameraDetailIxResponder {

    func didTapFirmwareVersionRow() {
        toggleFirmwareVersionUseCaseFactory.makeToggleFirmwareVersionUseCase().start()
    }

}

extension CameraDetailViewController: ObserverForCameraDetailEventResponder {

    func received(newState: CameraDetailViewControllerState) {
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

protocol CameraDetailViewControllerFactory {

}
