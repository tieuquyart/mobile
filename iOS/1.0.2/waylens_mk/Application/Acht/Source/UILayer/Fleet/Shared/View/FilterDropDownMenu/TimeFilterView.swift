//
//  TimeFilterView.swift
//  Fleet
//
//  Created by forkon on 2019/12/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import YNDropDownMenu

class TimeFilterView: YNDropDownView {

    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

extension TimeFilterView: DataFilterGenerator {

    func dataFilter() -> DataFilter {
        return TimeFilter(selectedDates: calendarView.selectedDates)
    }

}

//MARK: - Private

private extension TimeFilterView {

    func setup() {
        calendarView.setCurrentPage(Date(), animated: false)

        applyTheme()
    }

    func updateUI() {
        let selectedItemsCount = calendarView.selectedDates.count
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done") + ((selectedItemsCount != 0) ? "(\(selectedItemsCount))" : ""), for: .normal)
        changeMenu(title: NSLocalizedString("Time", comment: "Time") + ((selectedItemsCount != 0) ? " (\(selectedItemsCount))" : ""), at: 1)
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        hideMenu()
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        calendarView.select([])
        updateUI()
        hideMenu()
    }

}

extension TimeFilterView: Themed {

    func applyTheme() {
        seperatorView.backgroundColor = UIColor.semanticColor(.separator(.opaque))
    }

}

extension TimeFilterView: NibCreatable {}
