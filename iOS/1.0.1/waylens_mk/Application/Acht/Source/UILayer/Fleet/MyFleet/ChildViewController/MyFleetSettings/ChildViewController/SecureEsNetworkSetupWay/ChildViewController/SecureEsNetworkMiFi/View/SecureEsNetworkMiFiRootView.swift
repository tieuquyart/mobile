//
//  SecureEsNetworkMiFiRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMiFiRootView: FlowStepRootView<UITextView> {
    weak var ixResponder: SecureEsNetworkMiFiIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = SecureEsNetworkSetupWay.throughMiFiHotspot.description
        progressLabel.text = ""

        actionButton.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        contentView.isEditable = false
        contentView.font = UIFont.font(forStyle: .headline(attribute: .regular))
        contentView.text = NSLocalizedString("Step 1: Make sure that the MiFi hotspot is powered on.\n\nStep 2: Power on the camera, the camera will connect to the MiFi Hotspots automatically. Please make sure that the MiFi hotspot is the one included in the package.", comment: "Step 1: Make sure that the MiFi hotspot is powered on.\n\nStep 2: Power on the camera, the camera will connect to the MiFi Hotspots automatically. Please make sure that the MiFi hotspot is the one included in the package.")
    }

    override func applyTheme() {
        super.applyTheme()

        contentView.textColor = UIColor.semanticColor(.label(.secondary))
    }

}

//MARK: - Private

private extension SecureEsNetworkMiFiRootView {

    @objc
    func actionButtonTapped() {
        ixResponder?.doneAndGoBack()
    }
}

extension SecureEsNetworkMiFiRootView: SecureEsNetworkMiFiUserInterface {

    func render(newState: SecureEsNetworkMiFiViewControllerState) {

    }

}
