//
//  ChartCardHeaderView.swift
//  Fleet
//
//  Created by forkon on 2019/10/17.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ChartCardHeaderView: UIView {
    enum Segment: Int, CaseIterable {
        case mileage = 0
        case duration
        case event
        case activeVehicle
    }

    var segments: [Segment] = []
    var selectHandler: ((Int) -> ())? = nil

    private var selectionIndicator: UIView!
    private var segmentedControl: StatisticsSegmentedControl!
    private(set) var selectedSegmentIndex: Int = 0

    init(segments: [Segment] = Segment.allCases, frame: CGRect) {
        super.init(frame: frame)

        self.segments = segments
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateSelectionIndicatorPosition()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    func update(with mileage: Measurement<UnitLength>?, duration: Measurement<UnitDuration>?, eventCount: Int?, activeCount: String) {
      //  print("thanh1 \(mileage) , duration  \(duration) ")
        if segments.contains(.mileage) {
            if let mileage = mileage {
               
                (segmentedControl.getAllRows()[Segment.mileage.rawValue] as? TextStackView)?.set(.mileageCount(mileage))
            } else {
                
               (segmentedControl.getAllRows()[Segment.mileage.rawValue] as? TextStackView)?.set(.mileageCount(0.measurementLength(unit: .kilometers)))
            }
        }

        if segments.contains(.duration) {
            if let duration = duration {
                print("duration 2", duration)
                (segmentedControl.getAllRows()[Segment.duration.rawValue] as? TextStackView)?.set(.hoursCount(duration))
            } else {
               (segmentedControl.getAllRows()[Segment.duration.rawValue] as? TextStackView)?.set(.hoursCount(0.measurementDuration(unit: .hours)))
            }
        }

        if segments.contains(.event) {
            (segmentedControl.getAllRows()[Segment.event.rawValue] as? TextStackView)?.set(.eventsCount(eventCount ?? 0))
        }

//        if segments.contains(.activeVehicle) {
//            (segmentedControl.getAllRows()[Segment.activeVehicle.rawValue] as? TextStackView)?.set(.activeVehiclesCount(activeCount))
//        }
    }
    
   

}

//MARK: - ChartCardHeaderView

private extension ChartCardHeaderView {

    func setup() {
        setupSegmentedControl()
        setupSelectionIndicator()

        applyTheme()

        setNeedsLayout()
        layoutIfNeeded()

        selectionIndicator.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            self?.selectionIndicator.isHidden = false
            self?.updateSelectionIndicatorPosition()
        }
    }

    func setupSegmentedControl() {
        var segmentItems: [StatisticsSegmentedControlItem] = []

        let elementStyleMaker: (TextStackViewElement) -> TextStackViewElementStyle = { [unowned self] element in
            let textColor: UIColor
            switch element {
            case .events, .hours, .mileage, .activeVehicles:
                textColor = UIColor.semanticColor(.label(.primary))
            default:
                textColor = UIColor.semanticColor(.label(.secondary))
            }

            let font: UIFont
            switch element {
            case .events, .hours, .mileage, .activeVehicles:
                font = UIFont.systemFont(ofSize: 12)
            default:
                if self.selectedSegmentIndex == Segment.mileage.rawValue, case .mileageCount(_) = element {
                    font = UIFont.boldSystemFont(ofSize: 20)
                }
                else if self.selectedSegmentIndex == Segment.duration.rawValue, case .hoursCount(_) = element {
                    font = UIFont.boldSystemFont(ofSize: 20)
                }
                else if self.selectedSegmentIndex == Segment.event.rawValue, case .eventsCount(_) = element {
                    font = UIFont.boldSystemFont(ofSize: 20)
                }
                else {
                    font = UIFont.systemFont(ofSize: 20)
                }
            }

            return TextStackViewElementStyle(textColor: textColor, font: font)
        }

        segments.forEach { (segment) in
            switch segment {
            case .mileage:
              //  let mileageSegment = TextStackView(elements: [.mileageCount(0.measurementLength(unit: .kilometers)), .mileage], elementStyleMaker: elementStyleMaker)
                let mileageSegment = TextStackView(elements: [.mileage], elementStyleMaker: elementStyleMaker)
                mileageSegment.alignment = .center
                segmentItems.append(StatisticsSegmentedControlItem(view: mileageSegment, widthProportion: 1))
            case .duration:
              //  let durationSegment = TextStackView(elements: [.hoursCount2(0.measurementDuration(unit: .hours))], elementStyleMaker: elementStyleMaker)
                let durationSegment = TextStackView(elements: [.hours], elementStyleMaker: elementStyleMaker)
                durationSegment.alignment = .center
                segmentItems.append(StatisticsSegmentedControlItem(view: durationSegment, widthProportion: 1))
            case .event:
             //   let eventSegment = TextStackView(elements: [.eventsCount(0), .events], elementStyleMaker: elementStyleMaker)
                let eventSegment = TextStackView(elements: [.events], elementStyleMaker: elementStyleMaker)
                eventSegment.alignment = .center
                segmentItems.append(StatisticsSegmentedControlItem(view: eventSegment, widthProportion: 1))
            case .activeVehicle:
                let activeSegment = TextStackView(elements: [.activeVehiclesCount("0/0"), .activeVehicles], elementStyleMaker: elementStyleMaker)
                activeSegment.alignment = .center
                segmentItems.append(StatisticsSegmentedControlItem(view: activeSegment, widthProportion: 1))
            }
        }

        let tapHandler: StatisticsSegmentedControl.TapHandler = { [weak self] tappedSegmentIndex in
            guard tappedSegmentIndex != Segment.activeVehicle.rawValue else {
                return
            }

            self?.selectedSegmentIndex = tappedSegmentIndex
            self?.selectHandler?(tappedSegmentIndex)
            self?.updateSelectionIndicatorPosition()
        }

        segmentedControl = StatisticsSegmentedControl(
            items: segmentItems,
            hidesSeparators: false,
            segmentInset: UIEdgeInsets(top: 12.0, left: 5.0, bottom: 12.0, right: 5.0),
            separatorInset: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0),
            tapHandler: tapHandler
        )
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentedControl)

        segmentedControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func setupSelectionIndicator() {
        selectionIndicator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 4.0))
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionIndicator)
    }

    func updateSelectionIndicatorPosition() {
        segmentedControl.getAllRows().forEach { (v) in
            (v as? TextStackView)?.setUpTextLabel()
        }

        let selectedSegment = segmentedControl.getAllRows()[selectedSegmentIndex]
        (selectedSegment as? TextStackView)?.setUpTextLabel()
        selectionIndicator.center.x = selectedSegment.convert(selectedSegment.bounds, to: self).midX
    }

}

extension ChartCardHeaderView: Themed {

    func applyTheme() {
        backgroundColor = UIColor.clear
        selectionIndicator.backgroundColor = UIColor.semanticColor(.tint(.primary))
    }

}
