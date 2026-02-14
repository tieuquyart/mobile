//
//  CalibrationCalibrateRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationCalibrateRootView: FlowStepRootView<CalibrationCalibrateContentView> {
    weak var ixResponder: CalibrationCalibrateIxResponder?

    private(set) var canCalibrate: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "5. " + NSLocalizedString("Calibrate the camera.", comment: "Calibrate the camera.")
        progressLabel.text = "5 / 5"
        actionButton.isHidden = true
        contentView.goBackButton.addTarget(self, action: #selector(goBackButtonTapped), for: .touchUpInside)
    }
}

//MARK: - Private

private extension CalibrationCalibrateRootView {

    @objc
    private func goBackButtonTapped() {
        ixResponder?.backToPreviousStep()
    }
    
}

extension CalibrationCalibrateRootView: CalibrationCalibrateUserInterface {

    func render(newState: CalibrationCalibrateViewControllerState) {
        canCalibrate = (newState.viewState == .available)
        contentView.render(newState: newState.viewState)
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
