//
//  CameraListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import XLPagerTabStrip



class CameraListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CameraListUserInterfaceView
    private let loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory
    private let cameraListViewControllerFactory: CameraListViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: CameraListUserInterfaceView,
        loadCameraListUseCaseFactory: LoadCameraListUseCaseFactory,
        cameraListViewControllerFactory: CameraListViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadCameraListUseCaseFactory = loadCameraListUseCaseFactory
        self.cameraListViewControllerFactory = cameraListViewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Devices", comment: "Devices")
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

        loadCameraListUseCaseFactory.makeLoadCameraListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension CameraListViewController {

}

extension CameraListViewController: CameraListIxResponder {

    func selectCamera(at index: Int) {
        let vc = cameraListViewControllerFactory.makeCameraViewController(with: index)
        navigationController?.pushViewController(vc, animated: true)
    }

    func addNewCamera() {
        let vc = cameraListViewControllerFactory.makeAddNewCameraViewController().embedInNavigationController()

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }
        
        present(vc, animated: true, completion: nil)
    }
    
}

extension CameraListViewController: ObserverForCameraListEventResponder {

    func received(newState: CameraListViewControllerState) {
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

protocol CameraListViewControllerFactory {
    func makeCameraViewController(with selectedIndex: Int) -> UIViewController
    func makeAddNewCameraViewController() -> UIViewController
}
