//
//  CalibrationAdjustCameraPositionRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationAdjustCameraPositionRootView: FlowStepRootView<CalibrationAdjustCameraPositionContentView> {
    weak var ixResponder: CalibrationAdjustCameraPositionIxResponder?
    let config = ApplyCameraConfigMK()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "4. " + NSLocalizedString("Adjust the camera position.", comment: "Adjust the camera position.")
        progressLabel.text = "4 / 5"
        actionButton.setTitle(NSLocalizedString("Ready to Calib", comment: "Ready to Calib"), for: .normal)
     
       
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
}

//MARK: - Private

private extension CalibrationAdjustCameraPositionRootView {

    @objc
    private func actionButtonTapped() {
        ixResponder?.nextStep()
    }
    
}

extension CalibrationAdjustCameraPositionRootView: CalibrationAdjustCameraPositionUserInterface {
//    func screenShort() {
//
//
//        if let image = self.contentView.player.getRawImageView().image {
//            if let stringBase64 =  ImageConverter().imageToBase64(image) {
//
//               // config.camera =   UnifiedCameraManager.shared.local
//                print("stringBase64",stringBase64)
//               // config.buildImage(dict: ["imgBase64" : stringBase64])
//                config.camera =   UnifiedCameraManager.shared.local
//                print("stringBase64",stringBase64)
//                config.buildImage(dict: ["imgBase64" : stringBase64])
//            }
//        }
//
//
//    }
//

    func render(newState: CalibrationAdjustCameraPositionViewControllerState) {
        if newState.isCameraPositionValid {
            contentView.maskImageView.image = #imageLiteral(resourceName: "valid")
            actionButton.isEnabled = true
        }
        else {
            contentView.maskImageView.image = #imageLiteral(resourceName: "Invalid")
            actionButton.isEnabled = false
        }
    }

    func preview(camera: WLCameraDevice?) {
        guard let camera = camera else {
            return
        }
        
        contentView.player.replaceCurrentItem(with: .mjpegPreview(url: URL(string: camera.getLivePreviewAddress())!)).start()
    }

    func stopPreview() {
        contentView.player.shutdown()
    }

}
