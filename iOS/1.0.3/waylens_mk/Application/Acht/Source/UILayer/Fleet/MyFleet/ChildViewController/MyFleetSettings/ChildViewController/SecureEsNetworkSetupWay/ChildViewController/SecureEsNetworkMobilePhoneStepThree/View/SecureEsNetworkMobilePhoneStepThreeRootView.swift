//
//  SecureEsNetworkMobilePhoneStepThreeRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMobilePhoneStepThreeRootView: FlowStepRootView<UITextView> {
    weak var ixResponder: SecureEsNetworkMobilePhoneStepThreeIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "3. " + NSLocalizedString("Connect the camera to the mobile phone's WiFi.", comment: "Connect the camera to the mobile phone's WiFi.")
        progressLabel.text = ""

        actionButton.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        contentView.isEditable = false
        contentView.font = UIFont(name: "BeVietnamPro-Regular", size: 12.0)
        contentView.text = NSLocalizedString("The SSID and Password has been save on the camera successfully.\n\nTurn on the hotspot of the mobile phone, then the camera will connect to the WiFi automatically.\n\nYou can turn on the hotspot through:\nSettings > Cellular or Settings > Personal Hotspot.", comment: "The SSID and Password has been save on the camera successfully.\nTurn on the hotspot of the mobile phone, then the camera will connect to the WiFi automatically.\n\nYou can turn on the hotspot through:\nSettings > Cellular or Settings > Personal Hotspot.")
    }

    override func applyTheme() {
        super.applyTheme()

        contentView.textColor = UIColor.black
    }

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepThreeRootView {

    @objc
    func actionButtonTapped() {
        ixResponder?.doneAndGoBack()
    }
}

extension SecureEsNetworkMobilePhoneStepThreeRootView: SecureEsNetworkMobilePhoneStepThreeUserInterface {

    func render(newState: SecureEsNetworkMobilePhoneStepThreeViewControllerState) {

    }

}
