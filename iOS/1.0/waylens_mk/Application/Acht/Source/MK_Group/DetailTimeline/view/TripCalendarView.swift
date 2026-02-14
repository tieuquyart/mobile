//
//  CalendarView.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import LBTATools

class TripCalendarView  : UIView {
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private var calendar: FSCalendar!
    weak var delegate : CalendarViewDelegate?
   
    let okButton = UIButton(title: NSLocalizedString("OK", comment: "OK"), titleColor: .white, font: .systemFont(ofSize: 12), backgroundColor: .blue, target: self, action: #selector(okButtonHandler))
    var selectedDate: Date? {
        return calendar.selectedDate
    }
    
    
    func select(_ date: Date) {
        if let selectedDate = selectedDate {
            calendar.deselect(selectedDate)
        }
        calendar.select(date, scrollToDate: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    @objc func okButtonHandler() {
        print("ok button")
        delegate?.okButton()
    }

}




extension TripCalendarView {
    func setUp() {
        calendar = FSCalendar(frame: bounds)
        addSubview(calendar)
        addSubview(okButton)
        okButton.layer.cornerRadius = 5
       // calendar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        calendar.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        okButton.anchor(top: calendar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
  
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
       

    }
    
}

extension TripCalendarView: Themed {

    func applyTheme() {
        calendar.appearance.weekdayTextColor = UIColor.semanticColor(.tint(.primary))
        calendar.appearance.headerTitleColor = UIColor.semanticColor(.tint(.primary))
        calendar.appearance.titleDefaultColor = UIColor.semanticColor(.label(.secondary))
    }

}

extension TripCalendarView : FSCalendarDataSource, FSCalendarDelegate {
    

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("change page to \(self.formatter.string(from: calendar.currentPage))")
    
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.formatter.string(from: date))")

//        if monthPosition == .previous || monthPosition == .next {
//            calendar.setCurrentPage(date, animated: true)
//        }      

    }
}

