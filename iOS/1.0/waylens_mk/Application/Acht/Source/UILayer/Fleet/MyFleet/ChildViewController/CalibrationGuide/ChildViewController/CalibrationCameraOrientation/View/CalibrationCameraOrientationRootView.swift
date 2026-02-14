//
//  CalibrationCameraOrientationRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class CalibrationCameraOrientationRootView: FlowStepRootView<CalibrationCameraOrientationContentView> {
    weak var ixResponder: CalibrationCameraOrientationIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "2. " + NSLocalizedString("Make sure that the video is upright.", comment: "Make sure that the video is upright.")
        progressLabel.text = "2 / 5"
        contentView.invertButton.addTarget(self, action: #selector(invertButtonTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
}

//MARK: - Private

private extension CalibrationCameraOrientationRootView {

    @objc
    func actionButtonTapped() {
        ixResponder?.nextStep()
    }

    @objc
    func invertButtonTapped() {
        ixResponder?.invertCameraPicture()
    }
}

extension CalibrationCameraOrientationRootView: CalibrationCameraOrientationUserInterface {

    func render(newState: CalibrationCameraOrientationViewControllerState) {

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
