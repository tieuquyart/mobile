//
//  TriggeringVehicleListScopeAllStateView.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListScopeAllStateView: UIView, Themed {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12.0
        return stackView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = NSLocalizedString("All vehicles in the fleet will trigger this geo-fence", comment: "All vehicles in the fleet will trigger this geo-fence")
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Fleet image")
        return imageView
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
        backgroundColor = UIColor.semanticColor(.background(.secondary))
        label.textColor = UIColor.semanticColor(.label(.secondary))
    }

    private func setup() {
        addSubview(stackView)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(imageView)

        label.widthAnchor.constraint(equalToConstant: 200.0).isActive = true

        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        applyTheme()
    }

}
