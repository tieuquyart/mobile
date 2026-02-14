//
//  FinishRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

private let defaultRowHeight: CGFloat = 56.0

class FinishRootView: UIView {
    weak var ixResponder: FinishIxResponder?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        return titleLabel
    }()

    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        return subtitleLabel
    }()

    private lazy var button: UIButton = { [weak self] in
        let button = ButtonFactory.makeBigBottomButton("", color: UIColor.clear)

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }()

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: layoutMarginsGuide.layoutFrame)

        // bottom margin
        layoutFrameDivider.divideOriginalRect(atPercent: 0.095, from: .maxYEdge)

        button.frame = layoutFrameDivider.divide(atDistance: 50.0, from: .maxYEdge)

        layoutFrameDivider.divide(atDistance: 50.0, from: .maxYEdge)

        // top margin
        layoutFrameDivider.divideOriginalRect(atPercent: 0.18, from: .minYEdge)

        // left margin
        layoutFrameDivider.divideOriginalRect(atPercent: 0.095, from: .minXEdge)
        // right margin
        layoutFrameDivider.divideOriginalRect(atPercent: 0.095, from: .maxXEdge)

        imageView.sizeToFit()
        imageView.frame = layoutFrameDivider.divide(atDistance: imageView.frame.height, from: .minYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.025, from: .minYEdge)

        titleLabel.sizeToFit()
        titleLabel.frame = layoutFrameDivider.divide(atDistance: titleLabel.frame.height, from: .minYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.045, from: .minYEdge)

        subtitleLabel.frame.size = subtitleLabel.sizeThatFits(layoutFrameDivider.remainder.size)
        subtitleLabel.frame = layoutFrameDivider.divide(atDistance: subtitleLabel.frame.height, from: .minYEdge)
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

private extension FinishRootView {

    func setup() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(button)

        applyTheme()
    }

    @objc
    func buttonTapped() {
        ixResponder?.buttonTapped()
    }

}

extension FinishRootView: FinishUserInterface {

    func render(newState: FinishViewControllerConfig) {
        imageView.image = newState.icon
        titleLabel.text = newState.title
        subtitleLabel.text = newState.subtitle
        button.setTitle(newState.buttonTitle, for: .normal)
        setNeedsLayout()
    }

}

extension FinishRootView: Themed {

    func applyTheme() {
        titleLabel.textColor = UIColor.semanticColor(.label(.secondary))
        subtitleLabel.textColor = UIColor.semanticColor(.label(.primary))
        button.setBackgroundImageColor(UIColor.semanticColor(.tint(.primary)))
    }

}
