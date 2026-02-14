//
//  ExpandableCell.swift
//  Acht
//
//  Created by Chester Shen on 1/15/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ExpandableCellDelegate: class {
    func onMoreButton(sender: ExpandableCelldev)
}

class ExpandableCellModel {
    var collapseHeight: CGFloat = 0
    var expandedHeight: CGFloat = 0
    var isExpanded: Bool = false
    var shouldAnimated: Bool = false
    var height: CGFloat {
        get {
            return isExpanded ? expandedHeight : collapseHeight
        }
    }
}

class ExpandableCelldev: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    
    var isExpanded: Bool = false
    weak var delegate: ExpandableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.usingDynamicTextColor = true

        let arrow = UIImage(named: "down arrow")?.withRenderingMode(.alwaysTemplate)
        arrowImage.image = arrow
        arrowImage.tintColor = UIColor.semanticColor(.separator(.opaque))
        moreButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .normal)
        moreButton.isHidden = false
        self.clipsToBounds = true
    }
    
    func height(forWidth width: CGFloat, expanded: Bool) -> CGFloat {
        if expanded {
            return contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height
        } else {
            return headerView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height
        }
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool=true) {
        isExpanded = expanded
        if expanded {
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.expandView.alpha = 1.0
                    self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
            } else {
                self.expandView.alpha = 1.0
                self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        } else {
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.expandView.alpha = 0
                    self.arrowImage.transform = CGAffineTransform.identity
                }
            } else {
                self.expandView.alpha = 0
                self.arrowImage.transform = CGAffineTransform.identity
            }
        }
    }
    
    @IBAction func onMore(_ sender: Any) {
        delegate?.onMoreButton(sender: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moreButton.isHidden = true
    }
}
