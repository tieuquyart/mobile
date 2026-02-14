//
//  DriverSummaryCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import AloeStackView

class DriverSummaryCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<DriverSummaryCardItem>> {

    private enum Config {
        static let rowHeight: CGFloat = 56.0
    }

    private let itemsStackView: AloeStackView = {
        let itemsStackView = AloeStackView()
        itemsStackView.backgroundColor = UIColor.clear
        itemsStackView.automaticallyHidesLastSeparator = true
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        itemsStackView.rowInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        itemsStackView.separatorInset = UIEdgeInsets.zero
        return itemsStackView
    }()

    public var items: [DriverSummaryCardItem] = [] {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension DriverSummaryCardContentView {

    func setup() {
        backgroundColor = UIColor.clear

        addSubview(itemsStackView)

        itemsStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        itemsStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemsStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        itemsStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func updateUI() {
        itemsStackView.removeAllRows()

        items.forEach { (item) in
            var segmentItems: [StatisticsSegmentedControlItem] = []

            let driverSegment = TextStackView(elements: [.driver(item.name)])
            segmentItems.append(StatisticsSegmentedControlItem(view: driverSegment, widthProportion: 1.5))

            let mileageSegment = TextStackView(elements: [.mileageCount(item.statistics.mileage), .mileage])
            segmentItems.append(StatisticsSegmentedControlItem(view: mileageSegment, widthProportion: 0.8))

            let durationSegment = TextStackView(elements: [.hoursCount(item.statistics.duration), .hours])
            segmentItems.append(StatisticsSegmentedControlItem(view: durationSegment, widthProportion: 0.8))

            let eventSegment = TextStackView(elements: [.eventsCount(item.statistics.eventCount), .events])
            segmentItems.append(StatisticsSegmentedControlItem(view: eventSegment, widthProportion: 0.8))
            
            segmentItems.append(StatisticsSegmentedControlItem.disclosureIndicatorItem(withWidthProportion: 0.4))

            let segmentedControl = StatisticsSegmentedControl(items: segmentItems, segmentInset: UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 0.0))
            segmentedControl.backgroundColor = UIColor.clear
            segmentedControl.autoresizingMask = [.flexibleWidth]
            segmentedControl.heightAnchor.constraint(equalToConstant: Config.rowHeight).isActive = true

            segmentedControl.setInset(forRow: segmentedControl.getAllRows()[4], inset: UIEdgeInsets(top: 12.0, left: 0.0, bottom: 12.0, right: 10.0))

            itemsStackView.addRow(segmentedControl)
            itemsStackView.setTapHandler(forRow: segmentedControl, handler: { [weak self] (rowView) in
                self?.eventHandler?.selectBlock?(item)
            })
        }

        frame.size.height = CGFloat(items.count) * Config.rowHeight
    }

}
