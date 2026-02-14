//
//  ExpandableSliderCell.swift
//  Acht
//
//  Created by Chester Shen on 1/18/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ScaledSlider: UISlider {
    var levelCount: UInt = 0 {
        didSet {
            refreshMarks()
        }
    }
    var marksView: UIStackView?
    func showMarks(_ show: Bool, levels: UInt) {
        levelCount = levels
        if show {
            if marksView == nil {
                marksView = UIStackView(frame: bounds)
                marksView?.alignment = .fill
                marksView?.axis = .horizontal
                marksView?.distribution = .equalSpacing
                marksView?.backgroundColor = .clear
                marksView?.translatesAutoresizingMaskIntoConstraints = false
                superview?.addSubview(marksView!)
                superview?.sendSubviewToBack(marksView!)
                marksView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
                marksView?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
                marksView?.heightAnchor.constraint(equalToConstant: 8).isActive = true
                marksView?.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 2).isActive = true
            }
            marksView?.isHidden = false
            refreshMarks()
        } else {
            marksView?.isHidden = true
        }
    }
    
    func refreshMarks() {
        guard let marksView = marksView else { return }
        marksView.removeAllArrangedSubviews()
        if levelCount >= 3 {
            for i in 0..<levelCount {
                let view = RoundedView(frame: .zero)
//                view.cornerRadius = 1
                view.backgroundColor = UIColor.semanticColor(.separator(.opaque))
                view.translatesAutoresizingMaskIntoConstraints = false
                view.widthAnchor.constraint(equalToConstant: 2).isActive = true
                marksView.addArrangedSubview(view)
                if i == 0 || i == levelCount - 1 {
                    view.alpha = 0
                }
            }
        }
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if levelCount > 1 {
            let step = maximumValue / Float(levelCount - 1)
            let level = round(value / step)
            setValue(level * step, animated: true)
            sendActions(for: .applicationReserved)
        } else {
            sendActions(for: .applicationReserved)
        }
    }
}

class ExpandableSliderCell: CameraSettingCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var slider: ScaledSlider!
    var isExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.usingDynamicTextColor = true

        let arrow = UIImage(named: "down arrow")?.withRenderingMode(.alwaysTemplate)
        arrowImage.image = arrow
        arrowImage.tintColor = UIColor.semanticColor(.separator(.opaque))
        slider.tintColor = UIColor.semanticColor(.tint(.primary))
        slider.maximumTrackTintColor = UIColor.semanticColor(.separator(.opaque))
        self.clipsToBounds = true
    }

    func height(forWidth width: CGFloat, expanded: Bool) -> CGFloat {
        if expanded {
            return contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height
        } else {
            return 60
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        slider.removeTarget(nil, action: nil, for: .allEvents)
        slider.isEnabled = true
        slider.value = 0
    }
}
