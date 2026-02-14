//
//  HNSignBubble.swift
//  Acht
//
//  Created by Chester Shen on 12/15/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNSignBubble: UIView {

    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var triangle: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: InsetButton!
    var willBeHidden: Bool = false
    var isAnimating: Bool = false
    
    var preferredWidth: CGFloat = 280
    weak var anchorView: UIView?
    var targetFrame: CGRect = .zero
    let arrowHeight: CGFloat = 10
    let arrowWidth: CGFloat = 16
    let radius: CGFloat = 2
    var actionBlock: (()->Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("HNSignBubble", owner: self, options: nil)
        addSubview(contentView)
        backgroundColor = .clear
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        actionButton.layer.cornerRadius = actionButton.bounds.height * 0.5
        actionButton.layer.masksToBounds = true
        actionButton.inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func bubblePath(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth * 0.5, y: arrowHeight))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: arrowHeight))
        path.addArc(withCenter: CGPoint(x: rect.maxX - radius, y:arrowHeight+radius), radius: radius, startAngle: 1.5 * .pi, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(withCenter: CGPoint(x:rect.maxX - radius, y:rect.maxY - radius), radius: radius, startAngle: 0, endAngle: 0.5 * .pi, clockwise: true)
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        path.addArc(withCenter:  CGPoint(x: radius, y:rect.maxY - radius), radius: radius, startAngle: 0.5 * .pi, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: radius + arrowHeight))
        path.addArc(withCenter: CGPoint(x: radius, y: radius + arrowHeight), radius: radius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.midX - arrowWidth * 0.5, y: arrowHeight))
        path.close()
        return path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer()
        let path = bubblePath(rect: bounds)
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer
    }
    
    func reset() {
        removeFromSuperview()
        frame = .zero
        transform = CGAffineTransform.identity
        isHidden = true
    }
    
    func setup(level: HNWarningLevel, title: String, actionTitle: String?=nil, actionBlock:(()->Void)?=nil) {
        switch level {
        case .error:
            icon.image = #imageLiteral(resourceName: "icon_sign_error_w")
        case .warning:
            icon.image = #imageLiteral(resourceName: "icon_sign_warning_w")
        case .information:
            icon.image = #imageLiteral(resourceName: "icon_sign_information_w")
        }
        titleLabel.text = title
        if let actionTitle = actionTitle {
            self.actionBlock = actionBlock
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.setTitleColor(level.color, for: .normal)
            actionButton.isHidden = false
        } else {
            self.actionBlock = nil
            actionButton.isHidden = true
        }
        contentView.backgroundColor = level.color.withAlphaComponent(0.9)
//        triangle.tintColor = level.color.withAlphaComponent(0.9)
        let size = contentView.systemLayoutSizeFitting(CGSize(width: preferredWidth, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        guard let anchorView = anchorView else {
            targetFrame = CGRect(origin: .zero, size: size)
            return
        }
        let middleBottom = CGPoint(x: anchorView.bounds.width / 2, y: anchorView.bounds.height)
        let origin = anchorView.convert(middleBottom, to: superview)
        targetFrame = CGRect(x: origin.x - size.width / 2, y: origin.y/2, width: size.width, height: size.height)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        layer.position = origin
    }
    
    func show() {
        frame = targetFrame
        self.layoutIfNeeded()
        transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        self.layoutIfNeeded()
        isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func show(message: HNCameraMessage, from anchorView: UIView, in superView: UIView) {
        show(level: message.level, title: message.content, from: anchorView, in: superView, actionTitle: message.actionTitle, actionBlock: message.actionBlock)
    }
    
    func show(level: HNWarningLevel, title: String, from anchorView: UIView, in superView: UIView, actionTitle: String?=nil, actionBlock:(()->Void)?=nil) {
        reset()
        superView.addSubview(self)
        self.anchorView = anchorView
        setup(level: level, title: title, actionTitle: actionTitle, actionBlock: actionBlock)
        show()
    }
    
    @IBAction func onTap(_ sender: Any) {
        hide()
    }
    
    @IBAction func onAction(_ sender: Any) {
        if let block = actionBlock {
            block()
        }
        hide()
    }
    
    func hide(animated: Bool = true) {
        UIView.animate(withDuration: animated ? Constants.Animation.defaultDuration : 0.0, animations: {
            self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }) { (finished) in
            self.isHidden = true
        }
    }
}

extension HNSignBubble: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
//extension UIView {
//    func showBubble(level: HNWarningLevel, title: String, from anchorView: UIView, actionTitle: String?=nil, actionBlock:(()->Void)?=nil) {
//        let bubble = HNSignBubble(frame: CGRect.zero)
//        bubble.show(level: level, title: title, from: anchorView, in: self, actionTitle: actionTitle, actionBlock:actionBlock)
//    }
//}
