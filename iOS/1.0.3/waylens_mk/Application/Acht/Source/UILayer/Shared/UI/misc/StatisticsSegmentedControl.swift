//
//  StatisticsSegmentedControl.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import AloeStackView

class StatisticsSegmentedControlItem {
    var view: UIView
    var widthProportion: CGFloat

    init(view: UIView, widthProportion: CGFloat) {
        self.view = view
        self.widthProportion = widthProportion
    }

}

extension StatisticsSegmentedControlItem {

    class func disclosureIndicatorItem(withWidthProportion proportion: CGFloat = 0.5) -> StatisticsSegmentedControlItem {
        let disclosureIndicator = UIImageView(image: FleetResource.Image.rightArrowGray)
        disclosureIndicator.contentMode = .right
//        disclosureIndicator.backgroundColor = UIColor.red
        return StatisticsSegmentedControlItem(view: disclosureIndicator, widthProportion: proportion)
    }

}

class StatisticsSegmentedControl: AloeStackView {
    typealias TapHandler = ((_ tappedSegmentIndex: Int) -> Void)

    private var tapHandler: TapHandler?

    private(set) var items: [StatisticsSegmentedControlItem]

    required init(items: [StatisticsSegmentedControlItem], hidesSeparators: Bool = true, segmentInset: UIEdgeInsets, separatorInset: UIEdgeInsets = UIEdgeInsets.zero,  tapHandler: TapHandler? = nil) {
        self.items = items
        super.init()

        self.hidesSeparatorsByDefault = hidesSeparators
        self.automaticallyHidesLastSeparator = true
        self.rowInset = segmentInset
        self.separatorInset = separatorInset
        self.tapHandler = tapHandler

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        let widthProportionSum = items.map{$0.widthProportion}.reduce(0, +)
        let allRows = getAllRows()
        for (i, view) in allRows.enumerated() {
            let realProportion = items[i].widthProportion / widthProportionSum
            let realWidth = realProportion * bounds.width

            if let widthConstraint = view.superview?.widthConstraint {
                widthConstraint.constant = realWidth
            } else {
                view.superview?.widthAnchor.constraint(equalToConstant: realWidth).isActive = true
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateConstraints()
    }

    private func setup() {
        axis = .horizontal
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        for (i, item) in items.enumerated() {
            let view = item.view
            addRow(view)

            if tapHandler != nil {
                setTapHandler(forRow: view, handler: { [weak self] _ in
                    self?.tapHandler?(i)
                })
            }

        }

        updateConstraints()
    }
}

class TextStackView: UIStackView {

    var elements: [TextStackViewElement]

    private var elementStyleMaker: TextStackViewElementStyleMaker

    init(elements: [TextStackViewElement], elementStyleMaker: @escaping TextStackViewElementStyleMaker = textStackViewElementDefaultStyleMaker) {
        self.elements = elements
        self.elementStyleMaker = elementStyleMaker
        super.init(frame: .zero)

        setUpViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(_ element: TextStackViewElement) {
        if let index = elements.lastIndex(where: {$0 == element}) {
            elements.insert(element, at: index + 1)
            elements.remove(at: index)
        } else {
            elements.append(element)
        }
        setUpTextLabel()
    }

    func setUpTextLabel() {
        arrangedSubviews.forEach { (v) in
            removeArrangedSubview(v)
        }

        subviews.forEach { (v) in
            v.removeFromSuperview()
        }

        elements.forEach { (element) in
            let textLabel = UILabel()
            textLabel.numberOfLines = 1
            textLabel.text = element.text
            textLabel.font = elementStyleMaker(element).font
            textLabel.textColor = elementStyleMaker(element).textColor
            addArrangedSubview(textLabel)
        }
    }

    private func setUpViews() {
        setUpSelf()
        setUpTextLabel()
    }

    private func setUpSelf() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 0
        axis = .vertical
        alignment = .fill
        distribution = .fillProportionally
    }

}

typealias TextStackViewElementStyleMaker = (TextStackViewElement) -> TextStackViewElementStyle

func textStackViewElementDefaultStyleMaker(_ element: TextStackViewElement) -> TextStackViewElementStyle {
    let textColor: UIColor
    switch element {
    case .events, .hours, .mileage:
        textColor = UIColor.semanticColor(.label(.primary))
    default:
        textColor = UIColor.semanticColor(.label(.secondary))
    }

    let font: UIFont
    switch element {
    case .driver:
        font = UIFont(name: "BeVietnamPro-Medium", size: 14)!
    case .events, .hours, .mileage:
        font = UIFont(name: "BeVietnamPro-Medium", size: 12)!
    default:
        font = UIFont(name: "BeVietnamPro-Medium", size: 14)!
    }

    return TextStackViewElementStyle(textColor: textColor, font: font)
}

struct TextStackViewElementStyle {
    var textColor: UIColor
    var font: UIFont
}

enum TextStackViewElement: Equatable {
    case driver(String)
  //  case mileageCount(Measurement<UnitLength>)
    case mileageCount(Measurement<UnitLength>)
   // case mileageCountInt(Int)
    case mileage
    case hoursCount(Measurement<UnitDuration>)
    case hours
    case eventsCount(Int)
    case events
    case activeVehiclesCount(String)
    case activeVehicles
 

    var text: String {
        switch self {
        case .driver(let name):
            return name
        case .mileageCount(let count):
           // return "\(count)"
          
            return count.localeStringValue
        case .mileage:
          //  return NSLocalizedString("Miles", comment: "Miles")
            return NSLocalizedString("Kilometers", comment: "Kilometers")
        case .hoursCount(let count):
            print("count hour localeStringValue2", count)
            print("count hour localeStringValue", count.localeStringValue)
          //  return "\(count.localeValue)"
           return count.localeStringValue
        case .hours:
            return NSLocalizedString("Hours", comment: "Hours")
        case .eventsCount(let count):
            return "\(count)"
        case .events:
            return NSLocalizedString("Events", comment: "Events")
        case .activeVehiclesCount(let value):
            return value
        case .activeVehicles:
            return NSLocalizedString("Active", comment: "Active")
        }
    }

    static func ==(lhs: TextStackViewElement, rhs: TextStackViewElement) -> Bool {
        switch (lhs, rhs) {
        case (.driver(_), .driver(_)):
            return true
        case (.mileageCount(_), .mileageCount(_)):
            return true
        case (.eventsCount(_), .eventsCount(_)):
            return true
        case (.events, .events):
            return true
        case (.hours, .hours):
            return true
        case (.hoursCount(_), .hoursCount(_)):
            return true
        case (.activeVehiclesCount(_), activeVehiclesCount(_)):
            return true
        case (.activeVehicles, .activeVehicles):
            return true
        default:
            return false
        }
    }

}
