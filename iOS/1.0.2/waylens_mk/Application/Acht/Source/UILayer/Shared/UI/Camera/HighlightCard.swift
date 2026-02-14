//
//  HighlightCard.swift
//  Acht
//
//  Created by Chester Shen on 1/16/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

enum HighlightCardState: Equatable {
    case waitForUserOperation
    case savingClip(progress: Float)

    static func == (lhs: HighlightCardState, rhs: HighlightCardState) -> Bool {
        switch (lhs, rhs) {
        case (.waitForUserOperation, .waitForUserOperation):
            fallthrough
        case (.savingClip(_), .savingClip(_)):
            return true
        default:
            return false
        }
    }
}

class HighlightCard: UIButton {
    @IBOutlet var view: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var expanOrShrinkButton: UIButton!

    private lazy var progressAreaMask: CAShapeLayer = CAShapeLayer()

    var image: UIImage? {
        didSet {
            thumbnail.image = image
        }
    }

    var isExpaned: Bool {
        return layer.mask == nil
    }

    private var previousHighlightCardState: HighlightCardState? = nil
    var highlightCardState: HighlightCardState = .waitForUserOperation {
        didSet {
            previousHighlightCardState = oldValue
            refresh()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(
            roundedRect: circularProgressView.frame,
            cornerRadius: circularProgressView.frame.height / 2
            ).cgPath
        progressAreaMask.path = path
    }

    func expandOrShrink() {
        if isExpaned {
            shrink()
        } else {
            expand()
        }
    }
    
    @IBAction func expanOrShrinkButtonTapped(_ sender: Any) {
        expandOrShrink()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Make `expanOrShrinkButton` can be tapped.
        if circularProgressView.frame.contains(point) {
            return expanOrShrinkButton
        } else {
            return super.hitTest(point, with: event)
        }
    }
}

private extension HighlightCard {

    private func commonInit() {
        Bundle.main.loadNibNamed("HighlightCard", owner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    private func refresh() {
        if previousHighlightCardState == nil || highlightCardState != previousHighlightCardState! {
            switch highlightCardState {
            case .waitForUserOperation:
                expand()
                circularProgressView.progress = 0.0
                label.text = NSLocalizedString("Tap to Save", comment: "Tap to Save")
            case .savingClip(let progress):
                shrink()
                circularProgressView.progress = progress
                label.text = NSLocalizedString("Tap to Cancel", comment: "Tap to Cancel")
            }
        } else {
            switch highlightCardState {
            case .savingClip(let progress):
                circularProgressView.progress = progress
            default:
                break
            }
        }
    }

    private func expand() {
        layer.mask = nil
    }

    private func shrink() {
        layer.mask = progressAreaMask
    }

}

@IBDesignable
class CircularProgressView: UIView {
    @IBInspectable var progress: Float = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startAngle = CGFloat.pi * 1.5
        let endAngle = startAngle + (CGFloat.pi * 2)
        let lineWidth: CGFloat = 4.0
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2

        let bezierPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: (endAngle - startAngle) * CGFloat(progress) + startAngle,
            clockwise: true
        )
        bezierPath.lineWidth = lineWidth
        lineColor.setStroke()
        bezierPath.stroke()
    }
}
