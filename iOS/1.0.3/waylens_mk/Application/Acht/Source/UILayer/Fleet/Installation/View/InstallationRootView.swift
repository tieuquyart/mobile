//
//  InstallationRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class InstallationRootView: UIView {
    weak var ixResponder: InstallationIxResponder?

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "setup_guide_1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var button: UIButton = { [weak self] in
        let button = ButtonFactory.makeBigBottomButton(NSLocalizedString("Start Installation Test", comment: "Start Installation Test"), color: UIColor.black)

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var secondaryButton: UIButton = { [weak self] in
        let button = ButtonFactory.makeBigBottomButton(NSLocalizedString("Installation Guide for Secure360", comment: "Installation Guide for Secure360"), color: UIColor.clear)
        button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 12)

        button.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)

        return button
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .center
        textView.font = UIFont(name: "BeVietnamPro-Regular", size: 16)!
        textView.isEditable = false

        textView.text = NSLocalizedString("Please follow the installation guide to install the camera correctly.\n\nAnd power on your vehicle.", comment: "Please follow the installation guide to install the camera correctly.\n\nAnd power on your vehicle.")

        return textView
    }()

    init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bounds)

        layoutFrameDivider.divide(atDistance: layoutMargins.left, from: .minXEdge)
        layoutFrameDivider.divide(atDistance: layoutMargins.right, from: .maxXEdge)

        // bottom margin
        layoutFrameDivider.divideOriginalRect(atPercent: 0.04, from: .maxYEdge)

        button.frame = layoutFrameDivider.divide(atDistance: 50.0, from: .maxYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.064, from: .maxYEdge)

        secondaryButton.sizeToFit()
        secondaryButton.frame = layoutFrameDivider.divide(atDistance: secondaryButton.frame.height, from: .maxYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.036, from: .maxYEdge)

        imageView.frame = layoutFrameDivider.divideOriginalRect(atPercent: 0.44, from: .maxYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.06, from: .maxYEdge)

        // image view left padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.06, from: .minXEdge)
        // image view right padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.06, from: .maxXEdge)
        // image view top padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.08, from: .minYEdge)

        textView.frame = layoutFrameDivider.remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
}

//MARK: - Private

private extension InstallationRootView {

    func setup() {
        addSubview(textView)
        addSubview(imageView)
        addSubview(secondaryButton)
        addSubview(button)
        applyTheme()
    }

    @objc
    func buttonTapped() {
        ixResponder?.buttonTapped()
    }

    @objc
    func secondaryButtonTapped() {
        ixResponder?.secondaryButtonTapped()
    }

}

extension InstallationRootView: InstallationUserInterface {

    func render(newState: InstallationViewControllerState) {

    }

}

extension InstallationRootView {

    func applyTheme() {
        textView.textColor = UIColor.black
        secondaryButton.setTitleColor(UIColor.black, for: .normal)
    }

}
