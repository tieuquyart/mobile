//
//  TimelineCardContentView.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class TimelineCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<TimelineCardItem>> {

    @IBOutlet weak var timelineView: TimelineCardAxisView!
    @IBOutlet weak var itemsStackView: UIStackView!

    private let topPadding: CGFloat = 20.0
    private let bottomPadding: CGFloat = 20.0

    public var items: [TimelineCardItem] = [] {
        didSet {
            updateUI()
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func updateUI() {
        let stackViewWidth = itemsStackView.frame.width

        itemsStackView.arrangedSubviews.forEach { (arrangedSubview) in
            itemsStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        items.forEach { (item) in
            let v = TimelineCardItemView(item: item, width: stackViewWidth)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.heightAnchor.constraint(equalToConstant: v.frame.height).isActive = true
            itemsStackView.addArrangedSubview(v)
            v.leadingAnchor.constraint(equalTo: itemsStackView.leadingAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: itemsStackView.trailingAnchor).isActive = true
        }

        let itemsStackViewSize = itemsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        frame.size.height = itemsStackViewSize.height + topPadding + bottomPadding

        timelineView.updateUI()
    }
}

//MARK: - Private

private extension TimelineCardContentView {

    func setup() {
        backgroundColor = UIColor.clear

        itemsStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timelineView.itemsStackView = itemsStackView

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: itemsStackView)
        itemsStackView.arrangedSubviews.forEach { (arrangedSubview) in
            if arrangedSubview.frame.contains(tapPoint), let timelineItemView = arrangedSubview as? TimelineCardItemView {
                eventHandler?.selectBlock?(timelineItemView.item)
            }
        }
    }

}

extension TimelineCardContentView: NibCreatable {}
