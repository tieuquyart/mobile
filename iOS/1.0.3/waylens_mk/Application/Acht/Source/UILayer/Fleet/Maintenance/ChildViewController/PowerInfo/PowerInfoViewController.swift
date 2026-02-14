//
//  PowerInfoViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class PowerInfoViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: PowerInfoUserInterfaceView
    private let viewControllerFactory: PowerInfoViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let generalUseCaseFactory: GeneralUseCaseFactory

    init(
        observer: Observer,
        userInterface: PowerInfoUserInterfaceView,
        viewControllerFactory: PowerInfoViewControllerFactory,
        generalUseCaseFactory: GeneralUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.generalUseCaseFactory = generalUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Vehicle Power Information", comment: "Vehicle Power Information")
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

private extension PowerInfoViewController {

}

extension PowerInfoViewController: PowerInfoIxResponder {

}

extension PowerInfoViewController: ObserverForPowerInfoEventResponder {

    func received(newState: PowerInfoViewControllerState) {
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

extension PowerInfoViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

extension PowerInfoViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: nil, remote: nil)).start()
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

protocol PowerInfoViewControllerFactory {
    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController
}
