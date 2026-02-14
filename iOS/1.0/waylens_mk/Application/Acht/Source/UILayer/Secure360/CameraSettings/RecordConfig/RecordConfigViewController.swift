//
//  RecordConfigViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class RecordConfigViewController: BaseViewController, CameraRelated {
    var camera: UnifiedCamera? {
        didSet {
            updateCameraRecordConfigListUseCaseFactory.makeUpdateCameraRecordConfigListUseCase().start()
            updateCameraRecordConfigUseCaseFactory.makeUpdateCameraRecordConfigUseCase().start()
        }
    }

    private let observer: Observer
    private let cameraObserver: CameraObserverForRecordConfig
    private let userInterface: RecordConfigUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let updateCameraRecordConfigListUseCaseFactory: UpdateCameraRecordConfigListUseCaseFactory
    private let applyCameraRecordConfigUseCaseFactory: ApplyCameraRecordConfigUseCaseFactory
    private let updateCameraRecordConfigUseCaseFactory: UpdateCameraRecordConfigUseCaseFactory

    init(
        observer: Observer,
        cameraObserver: CameraObserverForRecordConfig,
        userInterface: RecordConfigUserInterfaceView,
        updateCameraRecordConfigListUseCaseFactory: UpdateCameraRecordConfigListUseCaseFactory,
        updateCameraRecordConfigUseCaseFactory: UpdateCameraRecordConfigUseCaseFactory,
        applyCameraRecordConfigUseCaseFactory: ApplyCameraRecordConfigUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.cameraObserver = cameraObserver
        self.userInterface = userInterface
        self.updateCameraRecordConfigListUseCaseFactory = updateCameraRecordConfigListUseCaseFactory
        self.updateCameraRecordConfigUseCaseFactory = updateCameraRecordConfigUseCaseFactory
        self.applyCameraRecordConfigUseCaseFactory = applyCameraRecordConfigUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Record Config", comment: "Record Config")
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
        cameraObserver.startObserving()
    }

}

//MARK: - Private

private extension RecordConfigViewController {

}

extension RecordConfigViewController: RecordConfigIxResponder {

    func select(recordConfig: String, bitrateFactor: Int, forceCodec: Int) {
        applyCameraRecordConfigUseCaseFactory.makeApplyCameraRecordConfigUseCase(recordConfig: recordConfig, bitrateFactor: bitrateFactor, forceCodec: forceCodec).start()
    }

}

extension RecordConfigViewController: ObserverForRecordConfigEventResponder {

    func received(newState: RecordConfigViewControllerState) {
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

extension RecordConfigViewController: CameraObserverForRecordConfigEventResponder {

    func received(newRecordConfigList: [WLEvcamRecordConfigListItem]) {
        updateCameraRecordConfigListUseCaseFactory.makeUpdateCameraRecordConfigListUseCase().start()
    }

    func received(newRecordConfig: WLCameraRecordConfig) {
        updateCameraRecordConfigUseCaseFactory.makeUpdateCameraRecordConfigUseCase().start()
    }

}

protocol RecordConfigViewControllerFactory {

}
