//
//  TriggeringVehicleListScopeSpecificEmptyStateView.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListScopeSpecificEmptyStateView: UIView {

    let button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.black
        button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)

        let buttonHeight: CGFloat = 40.0
        button.layer.cornerRadius = buttonHeight / 2
        button.layer.masksToBounds = true

        button.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)

        button.widthAnchor.constraint(equalToConstant: 140.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true

        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12.0
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        label.text = NSLocalizedString("No triggering vehicle", comment: "No triggering vehicle")
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        label.text = NSLocalizedString("Please select the vehicles trigger this geo-fence when entering.", comment: "Please select the vehicles trigger this geo-fence when entering.")
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.black
        subtitleLabel.textColor = UIColor.lightGray
    }

    private func setup() {
        addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(button)

        titleLabel.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        subtitleLabel.widthAnchor.constraint(equalToConstant: 220.0).isActive = true

        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        applyTheme()
    }

}
