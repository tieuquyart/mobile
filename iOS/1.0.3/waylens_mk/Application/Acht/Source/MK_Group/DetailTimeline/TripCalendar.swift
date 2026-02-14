//
//  TripCalendar.swift
//  Acht
//
//  Created by TranHoangThanh on 12/31/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import Foundation
import FSCalendar
import YNDropDownMenu

class TripCalendar : YNDropDownView {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var doneButton: UIButton!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    var selectedDate: Date? {
        return calendarView.selectedDate
    }
    
    var handleUpdateTime: ((Date) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.select(Date())
    }
    
}


extension TripCalendar  :  FSCalendarDataSource, FSCalendarDelegate {
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        hideMenu()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        calendarView.select([])
        hideMenu()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.formatter.string(from: date))")
        self.handleUpdateTime?(date)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        hideMenu()
    }
    
}


extension TripCalendar : NibCreatable {}



