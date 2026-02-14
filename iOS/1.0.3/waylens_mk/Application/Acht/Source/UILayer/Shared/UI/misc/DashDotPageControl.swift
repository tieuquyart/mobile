//
//  DashDotPageControl.swift
//  Acht
//
//  Created by Chester Shen on 6/19/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

//class Dot: UIButton {
//    var isDash: Bool = false {
//        didSet {
//            invalidateIntrinsicContentSize()
//        }
//    }
//
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: isDash ? 21 : 6, height: 6)
//    }
//}

@IBDesignable class DashDotPageControl: UIControl {
    

    @IBInspectable open var numberOfPages: Int = 0  {
        didSet {
            for dot in subviews {
                dot.removeFromSuperview()
            }
            if numberOfPages <= currentPage {
                currentPage = 0
            }
            var left:CGFloat = margin
            for i in 0..<numberOfPages {
                let dot = UIView(frame: CGRect(x: left, y: margin, width: currentPage == i ? 4*radius+spacing : 2*radius, height: 2*radius))
                left = dot.frame.maxX + spacing
                dot.backgroundColor = pageIndicatorTintColor
//                dot.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
//                dot.translatesAutoresizingMaskIntoConstraints = true
                dot.layer.masksToBounds = true
                dot.layer.cornerRadius = radius
//                dot.isDash = currentPage == i
                addSubview(dot)
            }
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable open var currentPage: Int = 0 {
        didSet {
            var i = 0
            var left: CGFloat = margin
            for dot in subviews {
                dot.frame = CGRect(x: left, y: margin, width: currentPage == i ? 4*radius+spacing : 2*radius, height: 2*radius)
                left = dot.frame.maxX + spacing
                i += 1
            }
        }
    }
    var nextPage: Int?
    
//    open var hidesForSinglePage: Bool // hide the the indicator if there is only one page. default is NO
    
    
//    open func size(forNumberOfPages pageCount: Int) -> CGSize // returns minimum size required to display dots for given page count. can be used to size control if page count could change
    
    @IBInspectable open var pageIndicatorTintColor: UIColor? {
        didSet {
            subviews.forEach { (dot) in
                dot.backgroundColor = pageIndicatorTintColor
            }
        }
    }
    
//    open var currentPageIndicatorTintColor: UIColor?
    
    override var intrinsicContentSize: CGSize {
        let width = CGFloat(numberOfPages) * (radius * 2 + spacing) + radius * 2
        return CGSize(width: width+2*margin, height: radius * 2+2*margin)
    }
    
    let radius:CGFloat = 3.0
    let spacing:CGFloat = 6.0
    let margin:CGFloat = 12.0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }
    
    override open class var requiresConstraintBasedLayout: Bool {
        return true
    }

    func finishInit() {
        backgroundColor = .clear
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapGuesture)
    }
    
    func setCurrentPage(_ page: Int, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.currentPage = page
            }
        } else {
            currentPage = page
        }
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let x = sender.location(in: self).x
            if currentPage + 1 < numberOfPages && x > subviews[currentPage].frame.maxX {
                nextPage = currentPage + 1
                sendActions(for: .valueChanged)
            } else if currentPage - 1 >= 0 && x < subviews[currentPage].frame.minX {
                nextPage = currentPage - 1
                sendActions(for: .valueChanged)
            }
        }
    }
}
