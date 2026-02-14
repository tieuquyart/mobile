//
//  CalibrationInstallationPositionRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CalibrationInstallationPositionRootView: FlowStepRootView<CalibrationInstallationPositionContentView> {
    weak var ixResponder: CalibrationInstallationPositionIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "1. " + NSLocalizedString("Recommended installation position.", comment: "Recommended installation position")
        progressLabel.text = "1 / 5"
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

}

//MARK: - Private

private extension CalibrationInstallationPositionRootView {

    @objc
    private func actionButtonTapped() {
        ixResponder?.nextStep()
    }

}

extension CalibrationInstallationPositionRootView: CalibrationInstallationPositionUserInterface {

    func render(newState: CalibrationInstallationPositionViewControllerState) {

    }

}
