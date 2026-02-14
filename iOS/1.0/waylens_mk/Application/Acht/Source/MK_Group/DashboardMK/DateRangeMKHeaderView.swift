//
//  DateRangeMKView.swift
//  Acht
//
//  Created by TranHoangThanh on 12/27/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import SnapKit

protocol DateRangeMKHeaderViewDelegate: AnyObject {
    func onClickShowDateView(isShow:Bool)
}


public class DateRangeMKHeaderView: UIView {
    
    
    let calendarView = CalendarView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.8))
    let vc = UIViewController()
    weak var delegate : DateRangeMKHeaderViewDelegate?
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var labelTime : UILabel!
    @IBOutlet weak var containerViewTime: UIView!
    
    
    
    public var dateRange: DateRange! {
        didSet {
            updateUI()
        }
    }
    
    var closureDate : ((DateRange) -> Void)?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        comonInit()
        
    }
    
    
    func setBorderView(for views: UIView...) {
        
        for view in views {
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        }
    }
    
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("DateRangeMKHeaderView" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        calendarView.delegate = self
        calendarView.autoresizingMask = [.flexibleWidth]
        
        
        vc.view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width * 0.9, height: 270))
        vc.view.backgroundColor = UIColor.semanticColor(.background(.primary))
        vc.view.usingDynamicBackgroundColor = true
        
        vc.view.addSubview(calendarView)
        calendarView.frame = vc.view.frame.insetBy(dx: 10.0, dy: 0.0)
        self.setBorderView(for: containerViewTime)
        self.labelTime.text = ""
        self.containerViewTime.addTapGesture {
            self.delegate?.onClickShowDateView(isShow: true)
            
            self.setupchooseShowDate()
        }
        
        self.layoutIfNeeded()
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

extension DateRangeMKHeaderView: Themed {
    
    public func applyTheme() {
        
    }
    
}

//MARK: - Private
private extension DateRangeMKHeaderView {
    
    
    
    func updateUI() {
        
        let data1 = dateRange.from.toString(format: DateFormatType.isoDate, timeZone: .custom(TimeZone(identifier: "Asia/Ho_Chi_Minh")!))
        let data2 = dateRange.to.toString(format: DateFormatType.isoDate, timeZone: .custom(TimeZone(identifier: "Asia/Ho_Chi_Minh")!))
        let rangeString =  "\(data1) to \(data2)"
        self.labelTime.text = rangeString
        
        setNeedsLayout()
    }
    
    
    
    @objc func setupchooseShowDate() {
        
        parentViewController?.popout(vc, preferredContentSize:  vc.view.bounds.size, tapBackgroundToDismiss: true, from: self.contentView, didDismiss: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.onClickShowDateView(isShow: false)
            
            if let first = strongSelf.calendarView.selectedDates.first, let last = strongSelf.calendarView.selectedDates.last {
                let newRange = DateRange(from: first, to: last)
                
                if newRange != strongSelf.dateRange {
                    strongSelf.dateRange = newRange
                    strongSelf.closureDate?(strongSelf.dateRange)
                }
            }
            
        })
        
    }
}

extension DateRangeMKHeaderView : CalendarViewDelegate {
    func cancelButton() {
        print("ok delegate")
        self.parentViewController?.dismiss(animated: true)
        
    }
    
    func okButton() {
        print("cancel delegate")
        if let first = calendarView.selectedDates.first, let last = calendarView.selectedDates.last {
            let newRange = DateRange(from: first, to: last)
            
            if newRange != self.dateRange {
                self.dateRange = newRange
                self.closureDate?(self.dateRange)
                
            }
            
        }
        self.delegate?.onClickShowDateView(isShow: false)
        self.parentViewController?.dismiss(animated: true)
    }
    
}
