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
    @IBOutlet weak var lbDriver: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var viewDriver1: UIView!
    @IBOutlet weak var viewParking1: UIView!
    @IBOutlet weak var lbParking: UILabel!
    @IBOutlet weak var viewParking: UIView!
    @IBOutlet weak var viewDriving: UIView!
    @IBOutlet private weak var totalCountLabel: UILabel!
    @IBOutlet private weak var drivingCountLabel: UILabel!
    @IBOutlet private weak var parkingCountLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var totalStackView: UIStackView!
    @IBOutlet weak var parkingStackView: UIStackView!
    @IBOutlet weak var drivingStackView: UIStackView!
    @IBOutlet weak var viewTotal: UIView!
    var totalCount: Int = 0 {
        didSet {
            totalCountLabel.text = "Tổng \(totalCount)"
            lbCount.text = "Tổng \(totalCount)"
        }
    }
    var drivingCount: Int = 0 {
        didSet {
            drivingCountLabel.text = "Lái xe \(drivingCount)"
            lbDriver.text = "Lái xe \(drivingCount)"
        }
    }
    var parkingCount: Int = 0 {
        didSet {
            parkingCountLabel.text = "Đỗ xe \(parkingCount)"
            lbParking.text = "Đỗ xe \(parkingCount)"
        }
    }
    var toggleSortBarHandler: (() -> ())? = nil
    private let layout = DriverListHeaderLayoutImpl()
    override func layoutSubviews() {
        super.layoutSubviews()
        viewTotal.layer.cornerRadius = 12
        viewTotal.layer.masksToBounds = true
        viewDriving.layer.cornerRadius = 12
        viewDriving.layer.masksToBounds = true
        viewParking.layer.cornerRadius = 12
        viewParking.layer.masksToBounds = true
        filterButton.layer.cornerRadius = 12
        filterButton.layer.masksToBounds = true
        viewParking1.layer.cornerRadius = 12
        viewDriver1.layer.cornerRadius = 12
        viewHeader.layer.cornerRadius = 2
        self.filterButton.setImage(UIImage(named: "up arrow"), for: .normal)
        self.backgroundColor = UIColor.white
    }
    func showFilterButton() {
      //  filterButton.isHidden = false
    }
    func hideFilterButton() {
        //filterButton.isHidden = true
    }
}
//MARK: - Private
extension DriverListHeader {
    func setImageButton(val : Bool) {
         let arrowUp = UIImage(named: "up arrow")
         let arrowDown = UIImage(named: "down arrow")
        if val {
            self.filterButton.setImage(arrowUp, for: .normal)
        } else {
            self.filterButton.setImage(arrowDown, for: .normal)
        }
         
    }
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.setImageButton(val: sender.isSelected)
        toggleSortBarHandler?()
    }

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
