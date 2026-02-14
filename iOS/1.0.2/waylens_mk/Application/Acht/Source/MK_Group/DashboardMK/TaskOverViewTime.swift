//
//  TaskOverViewTime.swift
//  Acht
//
//  Created by TranHoangThanh on 12/19/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import LBTATools
import DropDown
import SwiftDate


class TaskOverViewTime : UIView {
  
   
    @IBOutlet weak var dateRangeView: DateRangeMKHeaderView!
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var labelTime : UILabel!
    @IBOutlet weak var containerViewTime: UIView!
    
    let chooseShowDate = DropDown()
    
    
    var closureFast : ((DateRange) -> Void)?
    //weak var dateRangeChangeHandler: DateRangeChangeHandler?
    var dateRange: DateRange! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        comonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        comonInit()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        comonInit()
        
    }
    
  
    
//    required public init(frame: CGRect, dateRange: DateRange ,  completion: @escaping  DateRangeChangeHandler ) {
//        self.dateRange = dateRange
//        self.dateRangeChangeHandler = completion
//        super.init(frame: frame)
//
//        comonInit()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    //
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        comonInit()
//
//    }
//
    func setBorderView(for views: UIView...) {
        
        for view in views {
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        }
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        comonInit()
//
//
//    }
//
    
   // let chooseLabelTime = DropDown()
    
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("TaskOverViewTime" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.setBorderView(for: containerViewTime)
        self.labelTime.text = "1 Tuần"
        self.containerViewTime.addTapGesture {
            self.setupchooseShowDate()
        }
        
    
        self.dateRangeView.closureDate = { [weak self] date in
            self?.closureFast?(date)
        }
        
        if let last = Date().getLast7Day() {
            self.dateRangeView.dateRange = DateRange(from: last, to: Date())
        }
    
    }
    
    
    
    
    func updateUI() {
        print("updateUI")
    }
    func setRangeDate(first : Date , last : Date) {
        let newRange = DateRange(from: first, to: last)

        if newRange != self.dateRange {
            self.dateRange = newRange
            self.dateRangeView.dateRange = self.dateRange
            self.closureFast?(self.dateRange)
        }
    }
    func setupchooseShowDate() {
        chooseShowDate.anchorView = containerViewTime
        chooseShowDate.direction = .bottom
        chooseShowDate.bottomOffset = CGPoint(x: 40, y: containerViewTime.bounds.height)

        chooseShowDate.dataSource = ["1 Tuần","1 Tháng", "6 Tháng"]
        chooseShowDate.show()
        chooseShowDate.selectionAction = { [weak self] (index , item) in
           
            self?.labelTime.text = item
            let now = Date()
            let nowStr =  now.toString(format: DateFormatType.isoDate, timeZone: .custom(TimeZone(identifier: "Asia/Ho_Chi_Minh")!))
            print("now",nowStr )
            if item == "1 Tuần" {
                if let last = now.getLast7Day() {
                    self?.setRangeDate(first: last, last: now)
                }
                
            } else if item == "1 Tháng"  {
         
                
                if let last = now.getThisMonthStart() {
                
                    self?.setRangeDate(first: last, last: now)
                }
               
            
            } else if item == "6 Tháng"  {
                if let last = now.getLast6Month() {
                    self?.setRangeDate(first: last, last: now)
                }
            }
        }
    }
}


//let startDate = dateFormatter.string(from: Date().getThisMonthStart()!)
//let endDate = dateFormatter.string(from: Date().getThisMonthEnd()!)


extension Date
{
    mutating func addDays(n: Int)
    {
        let cal = Calendar.current
        self = cal.date(byAdding: .day, value: n, to: self)!
    }

    func firstDayOfTheMonth() -> Date {
        return Calendar.current.date(from:
            Calendar.current.dateComponents([.year,.month], from: self))!
    }

    func getAllDays() -> [Date]
    {
        var days = [Date]()

        let calendar = Calendar.current

        let range = calendar.range(of: .day, in: .month, for: self)!

        var day = firstDayOfTheMonth()

        for _ in 1...range.count
        {
            days.append(day)
            day.addDays(n: 1)
        }

        return days
    }
}

extension Date {

   
func getLast6Month() -> Date? {
    return Calendar.current.date(byAdding: .month, value: -6, to: self)
}

func getLast3Month() -> Date? {
    return Calendar.current.date(byAdding: .month, value: -3, to: self)
}

func getYesterday() -> Date? {
    return Calendar.current.date(byAdding: .day, value: -1, to: self)
}

func getLast7Day() -> Date? {
    return Calendar.current.date(byAdding: .day, value: -7, to: self)
}
func getLast30Day() -> Date? {
    return Calendar.current.date(byAdding: .day, value: -30, to: self)
}
    
    func getCurrentMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }


func getPreviousMonth() -> Date? {
    return Calendar.current.date(byAdding: .month, value: -1, to: self)
}

// This Month Start
func getThisMonthStart() -> Date? {
    let components = Calendar.current.dateComponents([.year, .month], from: self)
    return Calendar.current.date(from: components)!
}

func getThisMonthEnd() -> Date? {
    let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
    components.month += 1
    components.day = 1
    components.day -= 1
    return Calendar.current.date(from: components as DateComponents)!
}

//Last Month Start
func getLastMonthStart() -> Date? {
    let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
    components.month -= 1
    return Calendar.current.date(from: components as DateComponents)!
}

//Last Month End
func getLastMonthEnd() -> Date? {
    let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
    components.day = 1
    components.day -= 1
    return Calendar.current.date(from: components as DateComponents)!
}

}
