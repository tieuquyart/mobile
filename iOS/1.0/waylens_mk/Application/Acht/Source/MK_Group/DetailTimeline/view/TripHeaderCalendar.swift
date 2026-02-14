//
//  TripHeaderCalendar.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar

class TripHeaderCalendar : UIView {
    public typealias DateChangeHandler = ((Date) -> Void)
    let calendarView = TripCalendarView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
    private var selectButton: UIButton!
    private var dateChangeHandler: DateChangeHandler

    public var date: Date {
        didSet {
            updateUI()
        }
    }

    required public init(frame: CGRect, date: Date, dateChangeHandler: @escaping DateChangeHandler) {
        self.date = date
        self.dateChangeHandler = dateChangeHandler
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        selectButton.layer.cornerRadius = selectButton.frame.height / 2
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
}


extension TripHeaderCalendar : Themed {

    public func applyTheme() {
        selectButton.backgroundColor = UIColor.semanticColor(.background(.primary))
    }

}

//MARK: - Private
private extension TripHeaderCalendar {
    
    func setup() {
        backgroundColor = UIColor.clear

        selectButton = UIButton(type: .custom)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        selectButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: UIControl.State.normal)
        selectButton.clipsToBounds = true
        selectButton.layer.borderWidth = 1

        selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)

        addSubview(selectButton)

        applyTheme()

        selectButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        updateUI()
    }

    func updateUI() {
    
        
        let rangeString =  date.toString(format: .isoDate)
    
        selectButton!.set(
            title: rangeString,
            titleFont: UIFont.systemFont(ofSize: 12.0),
            titleColor: UIColor.semanticColor(.tint(.primary)),
            imageOnTitleLeft: nil,
            imageOnTitleRight: FleetResource.Image.dropDownArrow,
            margins: UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0),
            borderColor: UIColor.semanticColor(.border(.primary)),
            cornerRadius: UIButton.CornerRadius.halfHeight
        )

        setNeedsLayout()
    }
    
    
    @objc func selectButtonTapped(_ sender: UIButton) {
     
        calendarView.delegate = self
        calendarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calendarView.select(date)

        let vc = UIViewController()
        vc.view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.8))
        vc.view.backgroundColor = UIColor.semanticColor(.background(.primary))
        vc.view.usingDynamicBackgroundColor = true

        vc.view.addSubview(calendarView)
        calendarView.frame = vc.view.bounds.insetBy(dx: 10.0, dy: 0.0)

        parentViewController?.popout(vc, preferredContentSize: calendarView.bounds.size, tapBackgroundToDismiss: true, from: sender, didDismiss: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if let date = strongSelf.calendarView.selectedDate {
                if date != strongSelf.date {
                    strongSelf.date = date
                    strongSelf.dateChangeHandler(strongSelf.date)
                }
            }
        })
    }
}



extension TripHeaderCalendar  : CalendarViewDelegate {
    func cancelButton() {
       print("ok delegate")
        self.parentViewController?.dismiss(animated: true)
        
    }
    
    func okButton() {
        print("cancel delegate")
        if let date = self.calendarView.selectedDate {
            if date != self.date {
                self.date = date
                self.dateChangeHandler(self.date)
            }
        }
        self.parentViewController?.dismiss(animated: true)
    }
    
}
