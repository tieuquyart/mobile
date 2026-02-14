//
//  CardFlowViewCard.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class CardFlowViewCard: UIView {
    // MARK: Card appearance

    public var cornerRadius: CGFloat = 12.0 {
        didSet {
            setUpAppearance()
        }
    }

    public var borderAppearance: (UIColor, CGFloat) = (.lightGray, 1.0) {
        didSet {
            setUpAppearance()
        }
    }

    public var marginsInSuperview: UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }

    public var contentView: UIView

    public var headerView: UIView? = nil {
        didSet {
            headerView?.clipsToBounds = true
            if autoreload { reload() }
        }
    }

    public var footerView: UIView? = nil {
        didSet {
            footerView?.clipsToBounds = true
            if autoreload { reload() }
        }
    }

    public var autoreload: Bool = true {
        didSet {
            if autoreload { reload() }
        }
    }

    public init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: contentView.bounds)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setUpAppearance()
        reloadData()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    public func reloadData() {
        reload()
    }

    // MARK: Initial setup

    private func setUpAppearance() {
        clipsToBounds = true
        roundCorners(radius: 12)
        applyBorder(color: UIColor.color(fromHex: "#DEE0E7"), width: borderAppearance.1)
        applyTheme()
    }

    // MARK: Displaying

    private func cleanUp() {
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }

    /// Rebuilds timeline from scratch, without reloading data.

    public func reload() {
        cleanUp()

        layoutIfNeeded()

        let headerHeight = headerView?.bounds.height ?? 0.0
        let footerHeight = footerView?.bounds.height ?? 0.0

        let cardBodyView = self.contentView
        cardBodyView.clipsToBounds = true
        cardBodyView.translatesAutoresizingMaskIntoConstraints = false

        let bodyHeight = cardBodyView.bounds.height

        frame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: bounds.width,
            height: headerHeight + bodyHeight + footerHeight
        )

        headerView?.translatesAutoresizingMaskIntoConstraints = false
        footerView?.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews

        if let header = headerView {
            addSubview(header)
        }
        if let footer = footerView {
            addSubview(footer)
        }
        addSubview(cardBodyView)

        // Install constraints

        if headerView != nil {
            self.addConstraints([
                NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: headerView!, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: headerView!, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: headerView!, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: headerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: headerView?.bounds.height ?? 0)
            ])
        }

        if footerView != nil {
            self.addConstraints([
                NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: footerView!, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: footerView!, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: footerView!, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: footerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: footerView?.bounds.height ?? 0)
            ])
        }

        self.addConstraints([
                NSLayoutConstraint(item: headerView ?? self, attribute: headerView != nil ? .bottom : .top, relatedBy: .equal, toItem: cardBodyView, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: footerView ?? self, attribute: footerView != nil ? .top : .bottom, relatedBy: .equal, toItem: cardBodyView, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: cardBodyView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: cardBodyView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        ])

//        setNeedsDisplay()
//        layoutIfNeeded()

//        clipsToBounds = true
    }

}

// MARK: Helper extension

fileprivate extension CardFlowViewCard {

    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }

    func applyBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

}

extension CardFlowViewCard: Themed {

    @objc
    public func applyTheme() {
        backgroundColor = UIColor.semanticColor(.cardBackground)
    }

}
