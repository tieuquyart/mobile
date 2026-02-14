//
//  CalibrationRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FlowStepRootView<ContentViewType: UIView>: UIView, Themed {

    var title: String? {
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
        get {
            return titleLabel.text
        }
    }

    private(set) var contentView: ContentViewType!

    private(set) var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        return label
    }()

    private var contentContainingView: UIView = {
        let view = UIView()
        return view
    }()

    private(set) var  actionButton: UIButton = {
        let button = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.color(fromHex: ConstantMK.blueButton))
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

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
        layoutFrameDivider.divideOriginalRect(atPercent: 0.04, from: .maxYEdge)

        progressLabel.frame = layoutFrameDivider.divide(atDistance: 44.0, from: .maxYEdge)
        actionButton.frame = layoutFrameDivider.divide(atDistance: 50.0, from: .maxYEdge)

        // top margin
        layoutFrameDivider.divide(atDistance: layoutMargins.left, from: .minYEdge)

        titleLabel.frame.size = titleLabel.sizeThatFits(layoutFrameDivider.remainder.size)
        titleLabel.frame = layoutFrameDivider.divide(atDistance: titleLabel.frame.height, from: .minYEdge)

        // padding under title label
        layoutFrameDivider.divide(atDistance: layoutMargins.left, from: .minYEdge)

        // padding above action button
        layoutFrameDivider.divide(atDistance: layoutMargins.left, from: .maxYEdge)

        contentContainingView.frame = layoutFrameDivider.remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    open func setup() {
        addSubview(titleLabel)
        addSubview(contentContainingView)
        addSubview(actionButton)
        addSubview(progressLabel)

        contentView = ContentViewType.init()
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = contentContainingView.bounds
        contentContainingView.addSubview(contentView)

        applyTheme()
    }

    func applyTheme() {
        titleLabel.textColor = UIColor.semanticColor(.label(.secondary))
        progressLabel.textColor = UIColor.semanticColor(.label(.secondary))
        backgroundColor = UIColor.white
        
    }
}

//MARK: - Private

private extension FlowStepRootView {


}
