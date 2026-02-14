//
//  DIYCalendarCell.swift
//  test_alamofire
//
//  Created by thanh on 18/12/2021.
//

import Foundation
import FSCalendar


enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class DIYCalendarCell: FSCalendarCell {
    
   
    
    weak var todayLayer: CAShapeLayer!
    weak var selectionLayer: CAShapeLayer!
    
    var isInContinuousSelectionRange: Bool = false {
        didSet {
            configureAppearance()
        }
    }
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let todayLayer = CAShapeLayer()
        todayLayer.fillColor = UIColor.white.cgColor
        todayLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(todayLayer, below: self.titleLabel!.layer)
        self.todayLayer = todayLayer
        
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.black.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        
        self.shapeLayer.isHidden = true
        
    }
    
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.todayLayer.frame = self.shapeLayer.frame
        self.todayLayer.path = UIBezierPath(ovalIn: self.todayLayer.bounds).cgPath
        
        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = CGRect(
            x: self.contentView.bounds.origin.x,
            y: self.shapeLayer.frame.origin.y,
            width: self.contentView.bounds.width,
            height: self.shapeLayer.bounds.height
        )
        
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(rect: self.selectionLayer.bounds).cgPath
        }
        else if selectionType == .leftBorder {
            self.selectionLayer.path = UIBezierPath(
                roundedRect: self.selectionLayer.bounds,
                byRoundingCorners: [.topLeft, .bottomLeft],
                cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)
            ).cgPath
        }
        else if selectionType == .rightBorder {
            self.selectionLayer.path = UIBezierPath(
                roundedRect: self.selectionLayer.bounds,
                byRoundingCorners: [.topRight, .bottomRight],
                cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)
            ).cgPath
        }
        else if selectionType == .single {
            let width = selectionLayer.bounds.width
            let height = selectionLayer.bounds.height
            
            let roundedRect: CGRect
            
            if width > height {
                roundedRect = self.selectionLayer.bounds.insetBy(dx: (width - height) / 2, dy: 0.0)
            }
            else {
                roundedRect = self.selectionLayer.bounds.insetBy(dx: 0.0, dy: (height - width) / 2)
            }
            
            self.selectionLayer.path = UIBezierPath(
                roundedRect: roundedRect,
                cornerRadius: self.selectionLayer.bounds.shorterEdge / 2
            ).cgPath
        }
        
        
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = UIColor.lightGray
        } else {
            if isInContinuousSelectionRange {
                titleLabel.font = UIFont(name: "BeVietnamPro-Regular", size: appearance.titleFont.pointSize)
            } else {
                titleLabel.font = appearance.titleFont
            }
        }
        
        todayLayer.isHidden = !dateIsToday
    }
    
}
