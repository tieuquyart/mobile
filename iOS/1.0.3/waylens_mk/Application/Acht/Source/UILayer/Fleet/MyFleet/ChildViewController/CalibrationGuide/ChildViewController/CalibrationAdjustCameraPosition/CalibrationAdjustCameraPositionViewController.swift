//
//  CalibrationAdjustCameraPositionViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationAdjustCameraPositionViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: CalibrationAdjustCameraPositionUserInterfaceView
    private let viewControllerFactory: CalibrationAdjustCameraPositionViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory

    init(
        observer: Observer,
        userInterface: CalibrationAdjustCameraPositionUserInterfaceView,
        viewControllerFactory: CalibrationAdjustCameraPositionViewControllerFactory,
        judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.judgeDmsCameraPositionUseCaseFactory = judgeDmsCameraPositionUseCaseFactory
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
        
    //    NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msgFaceImage"), object: nil)

        observer.startObserving()
    }

    func alert(val : String) {
        
        let refreshAlert = UIAlertController(title: "Thông báo", message: val, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
              print("Handle Ok logic here")
            self.navigationController?.popViewController(animated: true)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
            self.navigationController?.popViewController(animated: true)
        }))

        present(refreshAlert, animated: true, completion: nil)
        
    }
    
//    @objc func showResult(_ notification: NSNotification) {
//
//      if let result = notification.userInfo?["param"] as? Bool {
//      // do something with your image
//          if result {
//
//              self.alert(val: "Gửi ảnh Thành công")
//          } else {
//              self.alert(val:  "Gửi ảnh Thất bại")
//          }
//      }
//
//     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update(for: WLBonjourCameraListManager.shared.currentCamera)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        userInterface.stopPreview()
    }

}

//MARK: - Private

private extension CalibrationAdjustCameraPositionViewController {

    func update(for camera: WLCameraDevice?) {
        camera?.liveDataMonitor?.start(gps: true, dms: true)
        camera?.liveDataMonitor?.delegate = self
        userInterface.preview(camera: camera)
    }

}

extension CalibrationAdjustCameraPositionViewController: CalibrationAdjustCameraPositionIxResponder {

    func nextStep() {

        
        parent?.flowGuide?.nextStep()
    }
    
}

extension CalibrationAdjustCameraPositionViewController: ObserverForCalibrationAdjustCameraPositionEventResponder {

    func received(newState: CalibrationAdjustCameraPositionViewControllerState) {
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

extension CalibrationAdjustCameraPositionViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        update(for: camera)
    }

}

extension CalibrationAdjustCameraPositionViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        userInterface.preview(camera: camera)
    }

}

extension CalibrationAdjustCameraPositionViewController: HNLiveDataMonitorDelegate {

    func onLiveES(dmsData: WLDmsData?) {
        judgeDmsCameraPositionUseCaseFactory.makeJudgeCameraPositionUseCase(dmsData: dmsData).start()
    }

    func onLive(obd: obd_raw_data_v2_t?) {}

    func onLive(acc: iio_raw_data_t?) {}

    func onLive(gps: CLLocation?) {}

    func onLive(dms: readsense_dms_data_v2_t?) {
        
    }

}

protocol CalibrationAdjustCameraPositionViewControllerFactory {

}
