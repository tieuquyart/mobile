//
//  SecureEsNetworkMobilePhoneStepTwoRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SecureEsNetworkMobilePhoneStepTwoRootView: FlowStepRootView<HotspotInfoInputView> {
    weak var ixResponder: SecureEsNetworkMobilePhoneStepTwoIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = "2. " + NSLocalizedString("Input the SSID and password of the hotspot.", comment: "Input the SSID and password of the hotspot.")
        progressLabel.text = ""

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.isEnabled = false

        contentView.inputValidationHandler = { [weak self] isValid in
            self?.actionButton.isEnabled = isValid
        }
    }

    override func applyTheme() {
        super.applyTheme()
    }

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepTwoRootView {

    @objc
    func actionButtonTapped() {
        if let ssid = contentView.ssidField.text, let password = contentView.passwordField.text {
            ixResponder?.nextStep(with: ssid, password: password)
        }
    }
}

extension SecureEsNetworkMobilePhoneStepTwoRootView: SecureEsNetworkMobilePhoneStepTwoUserInterface {

    func render(newState: SecureEsNetworkMobilePhoneStepTwoViewControllerState) {
        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                HNMessage.dismiss()
            } else {
                HNMessage.show(message: activityIndicatingState.message)
            }
        }
    }

}

class HotspotInfoInputView: UIView {

    let ssidField: UITextField = {
        $0.placeholder = NSLocalizedString("SSID", comment: "SSID")
        $0.borderStyle = .roundedRect
        $0.returnKeyType = .next
        $0.keyboardType = .asciiCapable
        $0.clearButtonMode = .whileEditing
        return $0
    }(UITextField())

    let passwordField: UITextField = {
        $0.placeholder = NSLocalizedString("Password", comment: "Password")
        $0.borderStyle = .roundedRect
        $0.returnKeyType = .done
        $0.keyboardType = .asciiCapable
        $0.clearButtonMode = .whileEditing
        return $0
    }(UITextField())

    var inputValidationHandler: ((_ isValid: Bool) -> ())? = nil

    private var warningLabel: UILabel = {
        $0.numberOfLines = 0
        $0.font = UIFont(name: "BeVietnamPro-Regular", size: 14.0)
        $0.text = "ⓘ " + NSLocalizedString("Please make sure the SSID and password you input are completely correct. Including case, punctuation and numbers.", comment: "Please make sure the SSID and password you input are completely correct. Including case, punctuation and numbers.")
        return $0
    }(UILabel())

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bounds)

        let width = layoutFrameDivider.remainder.width
        let arrangeViews: [UIView] = [ssidField, passwordField, warningLabel]

        arrangeViews.forEach { (v) in
            v.frame.size.width = width
            v.frame.size.height = 40.0
        }

        warningLabel.frame.size = warningLabel.sizeThatFits(CGSize(width: width, height: layoutFrameDivider.remainder.height))

        let padding: CGFloat = 20.0

        var originY: CGFloat = 0.0
        arrangeViews.forEach { (v) in
            v.frame.origin.x = layoutFrameDivider.remainder.minX
            v.frame.origin.y = originY
            originY += v.frame.height
            originY += padding
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    func applyTheme() {
        warningLabel.textColor = UIColor.black
    }

    private func setup() {
        ssidField.delegate = self
        passwordField.delegate = self

        addSubview(ssidField)
        addSubview(passwordField)
        addSubview(warningLabel)

        applyTheme()
    }

    private func notifyValidation() {
        let characterSet = CharacterSet.whitespacesAndNewlines
        if ssidField.text?.trimmingCharacters(in: characterSet).isEmpty == false && passwordField.text?.trimmingCharacters(in: characterSet).isEmpty == false {
            inputValidationHandler?(true)
        }
        else {
            inputValidationHandler?(false)
        }
    }

}

extension HotspotInfoInputView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ssidField {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            passwordField.resignFirstResponder()
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        notifyValidation()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        notifyValidation()
    }

}
