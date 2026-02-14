//
//  DriverListHeader.swift
//  Fleet
//
//  Created by forkon on 2019/9/24.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit


@IBDesignable
class StackView: UIStackView {
   @IBInspectable private var color: UIColor?
    override var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            self.setNeedsLayout() // EDIT 2017-02-03 thank you @BruceLiu
        }
    }

    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(rect: self.bounds).cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
    }
}

class DriverListHeader: UIView, NibCreatable {
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbDriving: UILabel!
    @IBOutlet weak var viewDriving: UIView!
    @IBOutlet weak var viewParking: UIView!
    @IBOutlet weak var lbParking: UILabel!
    @IBOutlet private weak var totalCountLabel: UILabel!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var totalStackView: UIStackView!
    @IBOutlet weak var viewTotal: UIView!
    var totalCount: Int = 0 {
        didSet {
            totalCountLabel.text = "Tổng \(totalCount)"
        }
    }
    var drivingCount: Int = 0 {
        didSet {
            lbDriving.text = "Lái xe \(drivingCount)"
        }
    }
    var parkingCount: Int = 0 {
        didSet {
            lbParking.text = "Đỗ xe \(parkingCount)"
        }
    }
    private let layout = DriverListHeaderLayoutImpl()
    override func layoutSubviews() {
        super.layoutSubviews()
        viewTotal.layer.cornerRadius = 8
        viewTotal.layer.masksToBounds = true
        viewDriving.layer.cornerRadius = 8
        viewDriving.layer.masksToBounds = true
        viewParking.layer.cornerRadius = 8
        viewParking.layer.masksToBounds = true
        viewParking.layer.cornerRadius = 8
        viewDriving.layer.cornerRadius = 8
        viewHeader.layer.cornerRadius = 2
        //viewBorder
        viewBorder.roudCorners([.topLeft,.topRight], radius: 12.0)
        viewBorder.layer.masksToBounds = true
        //initLb
        totalCountLabel.text = "Tổng 0"
        lbDriving.text = "Lái xe 0"
        lbParking.text = "Đỗ xe 0"
        
        self.backgroundColor = UIColor.white
    }
}
//MARK: - Private
extension DriverListHeader {

}

private protocol DriverListHeaderLayout: AnyObject {
    var marginProportion: CGFloat { get }

    func layout(totalStackView: UIStackView, parkingStackView: UIStackView, drivingStackView: UIStackView, filterButton: UIButton, seperatorView: UIView)
}

private final class DriverListHeaderLayoutImpl: DriverListHeaderLayout {
    
    let marginProportion: CGFloat = 0.035

    func layout(totalStackView: UIStackView, parkingStackView: UIStackView, drivingStackView: UIStackView, filterButton: UIButton, seperatorView: UIView) {
        
        guard let containingView = filterButton.superview else {
            return
        }

        let margin = marginProportion * containingView.bounds.width
        let dividualSpaceWithoutMargins = containingView.bounds.width - margin * 2

        let allArrangedViews = [totalStackView, seperatorView, drivingStackView, parkingStackView, filterButton]
        let allArrangedViewsWidth = allArrangedViews.reduce(0.0) {$0 + $1.frame.width}
        let allArrangedViewsCount = allArrangedViews.count

        let gap = (dividualSpaceWithoutMargins - allArrangedViewsWidth) / CGFloat((allArrangedViewsCount - 1/* seperatorView */) * 2)

        var x: CGFloat = margin
        for arrangedView in allArrangedViews {
            arrangedView.center.y = containingView.frame.height / 2

            if arrangedView == seperatorView {
                arrangedView.frame.origin.x = x
            }
            else if arrangedView == filterButton {
                x += gap * 2
                arrangedView.frame.origin.x = x
            }
            else {
                x += gap
                arrangedView.frame.origin.x = x
                x += gap
            }

            x += arrangedView.frame.width
        }
    }

}

extension UIView {
    func roudCorners(_ corners: UIRectCorner, radius: CGFloat){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
}
