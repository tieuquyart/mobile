//
//  CalibrationAdjustCameraPositionViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class LoginFaceViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: LoginFaceUserInterfaceView
    private let viewControllerFactory: LoginFaceViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory

    init(
        observer: Observer,
        userInterface: LoginFaceUserInterfaceView,
        viewControllerFactory: LoginFaceViewControllerFactory,
        judgeDmsCameraPositionUseCaseFactory: JudgeDmsCameraPositionUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.judgeDmsCameraPositionUseCaseFactory = judgeDmsCameraPositionUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

//        title = NSLocalizedString("", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msgFaceImage"), object: nil)
//        title = "Đăng nhập bằng khuôn mặt"
        observer.startObserving()
    }
    
    @objc func showResult(_ notification: NSNotification) {

      if let result = notification.userInfo?["param"] as? Bool {
      // do something with your image
          if result {
              
              self.alert(message: "Gửi ảnh Thành công", okHandler: {self.navigationController?.popViewController(animated: true)})
          } else {
              self.alert(message:  "Gửi ảnh Thất bại", okHandler: {self.navigationController?.popViewController(animated: true)})
          }
      }
         
     }
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

private extension LoginFaceViewController {

    func update(for camera: WLCameraDevice?) {
        camera?.liveDataMonitor?.start(gps: true, dms: true)
        camera?.liveDataMonitor?.delegate = self
        userInterface.preview(camera: camera)
    }

}

extension LoginFaceViewController: LoginFaceIxResponder {

    func nextStep() {
        
        print("aaaaaaa")
        userInterface.screenShort()
        
        userInterface.stopPreview()
       
     //   contentView.player
        
     //  parent?.flowGuide?.nextStep()
    }
    
}

extension LoginFaceViewController: ObserverForLoginFaceViewEventResponder {

    func received(newState: LoginFaceViewControllerState) {
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

extension LoginFaceViewController : ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        update(for: camera)
    }

}

extension LoginFaceViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        userInterface.preview(camera: camera)
    }

}

extension LoginFaceViewController: HNLiveDataMonitorDelegate {

    func onLiveES(dmsData: WLDmsData?) {
        judgeDmsCameraPositionUseCaseFactory.makeJudgeCameraPositionUseCase(dmsData: dmsData).start()
    }

    func onLive(obd: obd_raw_data_v2_t?) {}

    func onLive(acc: iio_raw_data_t?) {}

    func onLive(gps: CLLocation?) {}

    func onLive(dms: readsense_dms_data_v2_t?) {
        
    }

}

protocol LoginFaceViewControllerFactory {

}
