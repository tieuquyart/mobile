//
//  Acht.swift
//  Acht
//
//  Created by forkon on 2019/10/12.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class TimelineCardAxisView: UIView {

    private let axisView: UIView = {
        let axisViewWidth: CGFloat = 5.0
        let axisView = UIView()
        axisView.backgroundColor = UIColor.semanticColor(.timelineAxis)
        axisView.translatesAutoresizingMaskIntoConstraints = false
        axisView.widthAnchor.constraint(equalToConstant: axisViewWidth).isActive = true
        axisView.layer.cornerRadius = axisViewWidth / 2
        return axisView
    }()

    private let timeLabelContainerView: UIView = {
        let timeLabelContainerView = UIView()
        timeLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        return timeLabelContainerView
    }()

    private let topPadding: CGFloat = 0.0
    private let bottomPadding: CGFloat = 0.0

    var itemsStackView: UIStackView? = nil {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func updateUI() {
        timeLabelContainerView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }

        itemsStackView?.arrangedSubviews.forEach { (arrangedSubview) in
            if let timelineItemView = arrangedSubview as? TimelineCardItemView {
                let label = UILabel()
                label.text = timelineItemView.item.date.dateManager.fleetDate.toString(.time(.short))
                label.font = UIFont.systemFont(ofSize: 12.0)
                label.textAlignment = .right
                timeLabelContainerView.addSubview(label)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        axisView.layer.sublayers?.forEach({ (sublayer) in
            sublayer.removeFromSuperlayer()
        })

        if let itemsStackView = itemsStackView {
            for (i, subview) in timeLabelContainerView.subviews.enumerated() {
                let arrangedSubview = itemsStackView.arrangedSubviews[i]
                subview.frame.size.width = timeLabelContainerView.frame.width - 6.0
                subview.frame.size.height = arrangedSubview.frame.height
                subview.frame.origin = CGPoint(
                    x: 0.0,
                    y: arrangedSubview.frame.minY + (frame.height - itemsStackView.frame.height) / 2 // self and itemsStackView, align horizontally centers in container
                )

                if let timelineItemView = arrangedSubview as? TimelineCardItemView {
                    let milestoneShapeRect = CGRect(
                        x: 0.0,
                        y: subview.frame.minY,
                        width: axisView.frame.width,
                        height: subview.frame.height
                    )
                    axisView.layer.addSublayer(timelineItemView.milestoneShape(milestoneShapeRect))
                    subview.center.y = timelineItemView.dateLabelPositionY() + subview.frame.minY
                }
            }
        }
    }
}

//MARK: - Private

private extension TimelineCardAxisView {

    func setup() {
        addSubview(timeLabelContainerView)
        addSubview(axisView)

        axisView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        axisView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        axisView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        timeLabelContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        timeLabelContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        timeLabelContainerView.trailingAnchor.constraint(equalTo: axisView.leadingAnchor).isActive = true
        timeLabelContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        setNeedsLayout()
    }

}
