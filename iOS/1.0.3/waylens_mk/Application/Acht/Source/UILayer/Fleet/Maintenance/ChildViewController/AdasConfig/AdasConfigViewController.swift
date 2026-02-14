//
//  AdasConfigViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK
import IQKeyboardManagerSwift

class AdasConfigViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: AdasConfigUserInterfaceView
    private let viewControllerFactory: AdasConfigViewControllerFactory
    private let generalUseCaseFactory: GeneralUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let applyCameraAdasConfigUseCaseFactory: ApplyCameraAdasConfigUseCaseFactory

    init(
        observer: Observer,
        userInterface: AdasConfigUserInterfaceView,
        viewControllerFactory: AdasConfigViewControllerFactory,
        generalUseCaseFactory: GeneralUseCaseFactory,
        applyCameraAdasConfigUseCaseFactory: ApplyCameraAdasConfigUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.generalUseCaseFactory = generalUseCaseFactory
        self.applyCameraAdasConfigUseCaseFactory = applyCameraAdasConfigUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("ADAS Settings", comment: "ADAS Settings")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
    }
    
    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension AdasConfigViewController {

}

extension AdasConfigViewController: AdasConfigIxResponder {

    func configAdas(value: String?, for key: AnyKeyPath) {
        applyCameraAdasConfigUseCaseFactory.makeApplyCameraAdasConfigUseCase(key: key, value: value).start()
    }

}

extension AdasConfigViewController: ObserverForAdasConfigEventResponder {

    func received(newState: AdasConfigViewControllerState) {
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

extension AdasConfigViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: nil, remote: nil)).start();
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start();

        if camera == nil {
            navigationController?.popToRootViewController(animated: true)
        }
    }

}

extension AdasConfigViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: nil, remote: nil)).start()
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

protocol AdasConfigViewControllerFactory {

}
