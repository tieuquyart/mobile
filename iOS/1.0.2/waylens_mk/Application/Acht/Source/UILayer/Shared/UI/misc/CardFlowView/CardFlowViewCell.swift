//
//  CardFlowViewCard.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class CardFlowViewCell: UITableViewCell {
    // MARK: Subviews

    private(set) var headerView: UIView? = nil
    var card: CardFlowViewCard? = nil

    // MARK: Meta

    var bottomPadding: CGFloat = 0.0 {
        didSet {
            guard card != nil else { return }

            contentView.constraints.forEach {
                if $0.secondItem is CardFlowViewCard, $0.secondAttribute == .bottom {
                    $0.constant = bottomPadding

                    setNeedsLayout()
                }
            }
        }
    }

    // MARK: Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initState()

        cleanUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        initState()

        cleanUp()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }

    private func initState() {
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude,
                                      bottom: 0, right: 0)
    }

    // MARK: Setup

    private func cleanUp() {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        headerView = nil
        card = nil

        bottomPadding = 0.0
    }

    private func setUp(card: CardFlowViewCard, headerStrings: (NSAttributedString, NSAttributedString?)?, customHeaderView: UIView?) {

        if let customHeader = customHeaderView {
            headerView = customHeader
        } else if let title = headerStrings?.0 {
            headerView = SimpleTimelineItemHeader(width: bounds.width,
                                                  title: title,
                                                  subtitle: headerStrings?.1 ?? NSAttributedString(string: ""))
        }

        if let headerView = headerView {
            addHeader(headerView)
        }

        addCard(card)

        contentView.setNeedsLayout()
    }

    func setUp(customHeaderView: UIView,
               card: CardFlowViewCard) {
        setUp(card: card, headerStrings: nil, customHeaderView: customHeaderView)
    }

    func setUp(title: NSAttributedString, subtitle: NSAttributedString? = nil, card: CardFlowViewCard) {
        setUp(card: card, headerStrings: (title, subtitle), customHeaderView: nil)
    }

    func setUp(card: CardFlowViewCard) {
        setUp(card: card, headerStrings: nil, customHeaderView: nil)
    }

    // MARK: Layout

    private func addHeader(_ header: UIView) {
        header.frame = CGRect(origin: .zero, size: header.bounds.size)
        contentView.addSubview(header)

        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: header, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: header, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: header, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: header.bounds.height)
        ]

        constraints.forEach { $0.isActive = true }
    }

    private func addCard(_ card: CardFlowViewCard) {
        self.card = card
        self.card?.translatesAutoresizingMaskIntoConstraints = false

        card.frame.size.width = bounds.width - card.marginsInSuperview.left - card.marginsInSuperview.right

        card.reload()

        contentView.insertSubview(card, at: contentView.subviews.count)

        card.dropShadow(ViewShadowConfig.default)

        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: headerView ?? contentView, attribute: headerView != nil ? .bottom : .top, relatedBy: .equal, toItem: card, attribute: .top, multiplier: 1, constant: -card.marginsInSuperview.top),
            NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: card, attribute: .leading, multiplier: 1, constant: -card.marginsInSuperview.left),
            NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: card, attribute: .trailing, multiplier: 1, constant: card.marginsInSuperview.right),
            NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: card, attribute: .bottom, multiplier: 1, constant: bottomPadding + card.marginsInSuperview.bottom),
            NSLayoutConstraint(item: card, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: card.bounds.size.height)
        ]

        constraints.forEach { $0.isActive = true }
    }

}

fileprivate class SimpleTimelineItemHeader: UIView {
    // MARK: Constants

    static let defaultHeight: CGFloat = 60.0
    static let defaultPadding: CGFloat = 10.0

    // MARK: Properties

    var titleLabel: UILabel!
    var subtitleLabel: UILabel!

    // MARK: Initializers

    init(frame: CGRect, title: NSAttributedString, subtitle: NSAttributedString? = nil) {
        super.init(frame: frame)

        backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false

        let titlesContainer = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - SimpleTimelineItemHeader.defaultPadding))
        titlesContainer.backgroundColor = .clear
        addSubview(titlesContainer)

        let titleHeight: CGFloat = subtitle != nil ? titlesContainer.bounds.height / 2 : titlesContainer.bounds.height

        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: titlesContainer.bounds.width, height: titleHeight))
        titleLabel.attributedText = title
        titlesContainer.addSubview(titleLabel)

        if let subtitle = subtitle {
            subtitleLabel = UILabel(frame: CGRect(x: 0, y: titlesContainer.bounds.height / 2, width: titlesContainer.bounds.width, height: titlesContainer.bounds.height / 2))
            subtitleLabel.attributedText = subtitle
            titlesContainer.addSubview(subtitleLabel)
        }
    }

    convenience init(width: CGFloat, title: NSAttributedString, subtitle: NSAttributedString) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: width, height: SimpleTimelineItemHeader.defaultHeight + SimpleTimelineItemHeader.defaultPadding), title: title, subtitle: subtitle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
