//
//  CalendarView.swift
//  test_alamofire
//
//  Created by thanh on 18/12/2021.
//

import Foundation
import UIKit
import FSCalendar
import LBTATools

protocol CalendarViewDelegate : AnyObject {
    func  okButton()
    func  cancelButton()
}
class CalendarView : UIView {
    
    fileprivate lazy var gregorian: Calendar = { [unowned self] in
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = self.timeZone
        return gregorian
    }()
    
    weak var delegate : CalendarViewDelegate?
    private var calendar: FSCalendar!
    private let timeZone = TimeZone(identifier: "UTC")!
    let okButton = UIButton(title: NSLocalizedString("OK", comment: "OK"), titleColor: .white, font: .systemFont(ofSize: 12), backgroundColor: UIColor.color(fromHex: ConstantMK.blueButton), target: self, action: #selector(okButtonHandler))
    
    let cancelButton = UIButton(title: NSLocalizedString("Cancel", comment: "Cancel"), titleColor: .white, font: .systemFont(ofSize: 12), backgroundColor: .red, target: self, action: #selector(canelButtonHandler))
    @objc func okButtonHandler() {
        print("ok button")
        delegate?.okButton()
    }
    
    @objc func canelButtonHandler() {
        print("cancel button")
        delegate?.cancelButton()
    }
    
    var selectedDates: [Date] {
        return calendar.selectedDates.sorted()
    }
    
//    var maxDatesCanBeSelected: Int = 365 {
//        didSet {
//            assert(maxDatesCanBeSelected >= 0, "max dates can be selected must >= 0")
//        }
//    }
//
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
    
    func setCurrentPage(_ currentPage: Date, animated: Bool) {
        calendar.setCurrentPage(currentPage, animated: animated)
    }
    
    func select(_ dates: [Date]) {
        calendar.selectedDates.forEach { (selectedDate) in
            calendar.deselect(selectedDate)
        }

        let sortedDates = dates.sorted()

        sortedDates.forEach { (date) in
            var scrollToDate = false
            if date == dates.last {
                scrollToDate = true
                calendar.setCurrentPage(date, animated: true)
            }

            calendar.select(date, scrollToDate: scrollToDate)
        }

        configureVisibleCells()
    }

    func select(_ dateRange: DateRange) {
        calendar.selectedDates.forEach { (selectedDate) in
            calendar.deselect(selectedDate)
        }

        var newSelectedDates: [Date] = [dateRange.from]

        var nextDate = gregorian.date(byAdding: .day, value: 1, to: dateRange.from)!

        if !gregorian.isDate(dateRange.from, inSameDayAs: dateRange.to) {
            repeat {
                newSelectedDates.append(nextDate)
                nextDate = gregorian.date(byAdding: .day, value: 1, to: nextDate)!
            } while !gregorian.isDate(nextDate, inSameDayAs: gregorian.date(byAdding: .day, value: 1, to: dateRange.to)!)
        }

        newSelectedDates.append(dateRange.to)

        newSelectedDates.forEach { (date) in
            var scrollToDate = false
            if date == newSelectedDates.last {
                scrollToDate = true
                calendar.setCurrentPage(date, animated: true)
            }

            calendar.select(date, scrollToDate: scrollToDate)
        }

        configureVisibleCells()
    }

}




extension CalendarView {
    func setUp() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calendar = FSCalendar(frame: bounds)
        calendar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(calendar)
        addSubview(okButton)
        okButton.layer.cornerRadius = 5
        okButton.layer.masksToBounds = true
        
        
        calendar.anchor(top: topAnchor, leading: leadingAnchor, bottom: okButton.topAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8))
        okButton.anchor(top: calendar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 4, left: 8, bottom: 8, right: 8))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.today = gregorian.startOfDay(for: Date())

    }
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        guard let diyCell = cell as? DIYCalendarCell  else {return}
            // Configure selection layer
        
        
        if position == .current {
//            if let firstSelectedDate = selectedDates.first, date >= firstSelectedDate, date <= gregorian.date(byAdding: .day, value: (maxDatesCanBeSelected - 1), to: firstSelectedDate)! {
//                diyCell.isInContinuousSelectionRange = true
//            } else {
//                diyCell.isInContinuousSelectionRange = false
//            }
            
//            if let firstSelectedDate = selectedDates.first {
//                diyCell.isInContinuousSelectionRange = true
//            } else {
//                diyCell.isInContinuousSelectionRange = false
//            }

            
            diyCell.isInContinuousSelectionRange = true
            var selectionType = SelectionType.none

            if calendar.selectedDates.contains(date) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                if calendar.selectedDates.contains(date) {
                    if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    }
                    else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    }
                    else if calendar.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    }
                    else {
                        selectionType = .single
                    }
                }
            }
            else {
                selectionType = .none
            }

            if selectionType == .none {
                diyCell.selectionLayer.isHidden = true
                return
            }

            diyCell.selectionLayer.isHidden = false
            diyCell.selectionType = selectionType
        } else {
            diyCell.todayLayer.isHidden = true
            diyCell.selectionLayer.isHidden = true
        }

        
    }
}

extension CalendarView: Themed {

    func applyTheme() {
        calendar.appearance.weekdayTextColor = UIColor.semanticColor(.tint(.primary))
        calendar.appearance.headerTitleColor = UIColor.semanticColor(.tint(.primary))
        calendar.appearance.titleDefaultColor = UIColor.semanticColor(.label(.secondary))
    }

}

extension CalendarView : FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }
    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        let sortedSelectedDates = calendar.selectedDates.sorted()
//        if let first = sortedSelectedDates.first, let last = sortedSelectedDates.last {
//            if (date == first) || (gregorian.date(byAdding: .day, value: (maxDatesCanBeSelected - 1), to: first)! < last) {
//                sortedSelectedDates.forEach { (selectedDate) in
//                    calendar.deselect(selectedDate)
//                }
//                calendar.select(date, scrollToDate: true)
//            } else {
//                var dateWillSelect = gregorian.date(byAdding: .day, value: 1, to: first)!
//                while dateWillSelect < last {
//                    calendar.select(dateWillSelect, scrollToDate: false)
//                    dateWillSelect = gregorian.date(byAdding: .day, value: 1, to: dateWillSelect)!
//                }
//            }
//        }
//
//        if monthPosition == .previous || monthPosition == .next {
//            calendar.setCurrentPage(date, animated: true)
//        }
//        configureVisibleCells()
//    }
//
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let sortedSelectedDates = calendar.selectedDates.sorted()
        if let first = sortedSelectedDates.first, let last = sortedSelectedDates.last {
//            if (date == first) || (gregorian.date(byAdding: .day, value: (maxDatesCanBeSelected - 1), to: first)! < last) {
//                sortedSelectedDates.forEach { (selectedDate) in
//                    calendar.deselect(selectedDate)
//                }
//                calendar.select(date, scrollToDate: true)
//            }
            
            if (date == first) {
                sortedSelectedDates.forEach { (selectedDate) in
                    calendar.deselect(selectedDate)
                }
                calendar.select(date, scrollToDate: true)
            }
            else {
                var dateWillSelect = gregorian.date(byAdding: .day, value: 1, to: first)!
                while dateWillSelect < last {
                    calendar.select(dateWillSelect, scrollToDate: false)
                    dateWillSelect = gregorian.date(byAdding: .day, value: 1, to: dateWillSelect)!
                }
            }
        }

        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.selectedDates.forEach { (selectedDate) in
            calendar.deselect(selectedDate)
        }
        calendar.select(date, scrollToDate: true)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }

        configureVisibleCells()
    }
}

