//
//  TimelineItemView.swift
//  Acht
//
//  Created by forkon on 2019/10/15.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class TimelineCardItemView: UIView {
    private var textElementStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    private var disclosureIndicator: UIImageView? = nil

    private(set) var item: TimelineCardItem

    private var width: CGFloat

    init(item: TimelineCardItem, width: CGFloat) {
        self.item = item
        self.width = width
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let disclosureIndicator = disclosureIndicator {
            disclosureIndicator.center.y = bounds.height / 2
            disclosureIndicator.frame.origin.x = bounds.width - disclosureIndicator.frame.width
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

    func dateLabelPositionY() -> CGFloat {
        return frame.height / 2
//        return textElementStackView.arrangedSubviews.first?.center.y ?? 0.0
    }
}

extension TimelineCardItemView {

    func milestoneShape(_ rect: CGRect) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.semanticColor(.timelineMilestonePoint).cgColor

        if let driverTimelineEvent = item.object as? DriverTimelineEvent, driverTimelineEvent.type == .cameraEvent {
            if let eventColor = (driverTimelineEvent.content as? DriverTimelineCameraEventContent)?.eventType.color.cgColor {
                shape.fillColor = eventColor
            }

            let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
            shape.path = path.cgPath
        }
        else if let driverTimelineEvent = item.object as? DriverTimelineEvent, driverTimelineEvent.type == .ignitionStatus {
            let dotSize = CGSize(width: 8.0, height: 8.0)
            let path = UIBezierPath(
                roundedRect: CGRect(
                    x: -(dotSize.width - rect.width) / 2,
                    y: rect.minY +  dateLabelPositionY() - dotSize.height / 2,
                    width: dotSize.width,
                    height: dotSize.height),
                cornerRadius: dotSize.width / 2)
            shape.path = path.cgPath
        }

        let dotSize = CGSize(width: 8.0, height: 8.0)
        let dotPath = UIBezierPath(
            roundedRect: CGRect(
                x: -(dotSize.width - rect.width) / 2,
                y: rect.minY +  dateLabelPositionY() - dotSize.height / 2,
                width: dotSize.width,
                height: dotSize.height),
            cornerRadius: dotSize.width / 2
        ).cgPath

        if let driverTimelineEvent = item.object as? DriverTimelineEvent {
            switch driverTimelineEvent.type {
            case .cameraEvent:
                if let eventColor = (driverTimelineEvent.content as? DriverTimelineCameraEventContent)?.eventType.color.cgColor {
                    shape.fillColor = eventColor
                }

                let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
                shape.path = path.cgPath
            case .ignitionStatus:
                if let ignitionStatus = (driverTimelineEvent.content as? DriverTimelineIgnitionStatusContent)?.ignitionStatus {
                    shape.fillColor = ignitionStatus.color.cgColor
                }

                shape.path = dotPath
            case .geoFence:
                shape.fillColor = UIColor(rgb: 0x99A0A9).cgColor
                shape.path = dotPath
            }
        } else {
            shape.path = dotPath
        }

        return shape
    }

}

//MARK: - Private

private extension TimelineCardItemView {

    func setup() {
        let disclosureIndicatorSize = CGSize(width: 20.0, height: 20.0)

        addSubview(textElementStackView)

        textElementStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textElementStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textElementStackView.widthAnchor.constraint(equalToConstant: width - disclosureIndicatorSize.width).isActive = true

        item.textElements.forEach { (textElement) in
            let label = UILabel()
            label.text = textElement.text
            label.font = textElement.font
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalToConstant: width * 0.7).isActive = true
            textElementStackView.addArrangedSubview(label)
        }

        applyTheme()

        frame.size.height = textElementStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        if item.hasDetails {
            disclosureIndicator = UIImageView(image: FleetResource.Image.rightArrowGray)
            disclosureIndicator?.contentMode = .center
            disclosureIndicator?.frame.size = disclosureIndicatorSize
            addSubview(disclosureIndicator!)
        }

        setNeedsLayout()
    }

}

extension TimelineCardItemView: Themed {

    func applyTheme() {
        for (i, textElement) in item.textElements.enumerated() {
            if i < textElementStackView.arrangedSubviews.count,
                let label = textElementStackView.arrangedSubviews[i] as? UILabel {
                label.textColor = textElement.color()
            }
        }
    }

}
