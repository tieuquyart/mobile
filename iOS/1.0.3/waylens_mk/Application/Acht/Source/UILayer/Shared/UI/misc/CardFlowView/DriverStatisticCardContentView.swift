//
//  DriverStatisticCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import AloeStackView

class DriverStatisticCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<Driver>> {

    private enum Config {
        static let rowHeight: CGFloat = 56.0
    }

    private let itemsStackView: AloeStackView = {
        let itemsStackView = AloeStackView()
        itemsStackView.backgroundColor = UIColor.clear
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        itemsStackView.rowInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        itemsStackView.separatorInset = UIEdgeInsets.zero
        itemsStackView.automaticallyHidesLastSeparator = true
        return itemsStackView
    }()

    public var items: [Driver] = [] {
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

private extension DriverStatisticCardContentView {

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

            let mileageSegment = TextStackView(elements: [.mileageCount(item.statistics.mileage), .mileage])
            segmentItems.append(StatisticsSegmentedControlItem(view: mileageSegment, widthProportion: 1))

            let durationSegment = TextStackView(elements: [.hoursCount(item.statistics.duration), .hours])
            segmentItems.append(StatisticsSegmentedControlItem(view: durationSegment, widthProportion: 1))
            
            let eventSegment = TextStackView(elements: [.eventsCount(item.statistics.eventCount), .events])
            segmentItems.append(StatisticsSegmentedControlItem(view: eventSegment, widthProportion: 1))

            let canShowDetails = (
                (item.statistics.mileage.value > 0)
                    || (item.statistics.duration.value > 0)
                    || (item.statistics.eventCount > 0)
            )

            let disclosureIndicatorItem = StatisticsSegmentedControlItem.disclosureIndicatorItem()
            disclosureIndicatorItem.view.isHidden = !canShowDetails
            segmentItems.append(disclosureIndicatorItem)

            let segmentedControl = StatisticsSegmentedControl(items: segmentItems, segmentInset: UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 10.0))
            segmentedControl.backgroundColor = UIColor.clear
            segmentedControl.autoresizingMask = [.flexibleWidth]
            segmentedControl.heightAnchor.constraint(equalToConstant: Config.rowHeight).isActive = true
            segmentedControl.isUserInteractionEnabled = canShowDetails

            itemsStackView.addRow(segmentedControl)
          
            itemsStackView.setTapHandler(forRow: segmentedControl, handler: { [weak self] (rowView) in
                self?.eventHandler?.selectBlock?(item)
            })
        }

        frame.size.height = CGFloat(items.count) * Config.rowHeight
    }

}
