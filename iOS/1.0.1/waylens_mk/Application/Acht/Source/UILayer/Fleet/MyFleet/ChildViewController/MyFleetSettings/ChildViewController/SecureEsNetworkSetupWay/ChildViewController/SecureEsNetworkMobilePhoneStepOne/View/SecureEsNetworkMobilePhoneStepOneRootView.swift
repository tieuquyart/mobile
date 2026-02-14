//
//  SecureEsNetworkMobilePhoneStepOneRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMobilePhoneStepOneRootView: FlowStepRootView<UITextView> {
    weak var ixResponder: SecureEsNetworkMobilePhoneStepOneIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "1. " + NSLocalizedString("Please connect your phone to camera Wi-Fi.", comment: "Please connect your phone to camera Wi-Fi.")
        progressLabel.text = ""

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        contentView.isEditable = false
        contentView.font = UIFont.font(forStyle: .headline(attribute: .regular))
        contentView.text = NSLocalizedString("You can find the Wi-Fi name and Wi-Fi password on the screen of the camera.\n\nUse your phone to connect to the camera's Wi-Fi.", comment: "You can find the Wi-Fi name and Wi-Fi password on the screen of the camera.\n\nUse your phone to connect to the camera's Wi-Fi.")
    }

    override func applyTheme() {
        super.applyTheme()

        contentView.textColor = UIColor.semanticColor(.label(.secondary))
    }

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepOneRootView {

    @objc
    func actionButtonTapped() {
        ixResponder?.nextStep()
    }
}

extension SecureEsNetworkMobilePhoneStepOneRootView: SecureEsNetworkMobilePhoneStepOneUserInterface {

    func render(newState: SecureEsNetworkMobilePhoneStepOneViewControllerState) {

    }

}
