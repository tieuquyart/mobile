//
//  CalibrationCalibrateContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/6.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class CalibrationCalibrateContentView: CalibrationPlayerContentView {
    private(set) var goBackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitle("< " + NSLocalizedString("Back to adjust the camera", comment: "Back to adjust the camera"), for: .normal)
        return button
    }()

    private var text: String? {
        set {
            if let newValue = newValue {
                let attributedString = NSMutableAttributedString(string: newValue)

                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20.0, weight: .medium), range: NSRange(location: 0, length: attributedString.string.count))

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center

                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.string.count))

                textView.attributedText = attributedString
            }
            else {
                textView.attributedText = nil
            }
        }
        get {
            return textView.attributedText.string
        }
    }

    private var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }()

    private var countDownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60.0, weight: .medium)
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        bottomView.addSubview(textView)
        bottomView.addSubview(countDownLabel)
        bottomView.addSubview(goBackButton)

        applyTheme()

        render(newState: .positionInvalid)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bottomView.bounds)

        countDownLabel.frame = layoutFrameDivider.remainder

        if !goBackButton.isHidden {
            goBackButton.sizeToFit()
            let goBackButtonAreaFrame = layoutFrameDivider.divide(atDistance: 40.0, from: .maxYEdge)
            goBackButton.center = CGPoint(x: goBackButtonAreaFrame.minX + goBackButtonAreaFrame.width / 2, y: goBackButtonAreaFrame.minY + goBackButtonAreaFrame.height / 2)
        }

        let insetX: CGFloat = 10.0
        let preferredWarningLabelSize = textView.sizeThatFits(layoutFrameDivider.remainder.insetBy(dx: insetX, dy: 0.0).size)
        if preferredWarningLabelSize.height > layoutFrameDivider.remainder.height {
            textView.frame = layoutFrameDivider.remainder.insetBy(dx: insetX, dy: 0.0)
        }
        else {
            textView.frame = layoutFrameDivider.divide(atDistance: preferredWarningLabelSize.height, from: .minYEdge).insetBy(dx: insetX, dy: 0.0)
        }
    }

    func render(newState: CalibrationCalibrateViewState) {
        maskImageView.isHidden = true

        switch newState {
        case .available:
            text = NSLocalizedString("Look forward with the ordinary driving posture.", comment: "Look forward with the ordinary driving posture.") + "\n\n" + NSLocalizedString("ⓘ Please turn up the volume.", comment: "ⓘ Please turn up the volume.")
            textView.isHidden = false
            countDownLabel.text = nil
            countDownLabel.isHidden = true
            goBackButton.isHidden = true
        case .positionInvalid:
            text = NSLocalizedString("Look forward with the ordinary driving posture.", comment: "Look forward with the ordinary driving posture.") + "\n\n" + NSLocalizedString("ⓘ Please turn up the volume.", comment: "ⓘ Please turn up the volume.")
            textView.isHidden = false
            countDownLabel.text = nil
            countDownLabel.isHidden = true
            goBackButton.isHidden = false
            maskImageView.isHidden = false
        case .ready(let countDown):
            text = nil
            textView.isHidden = true
            countDownLabel.text = "\(countDown)"
            countDownLabel.isHidden = false
            goBackButton.isHidden = true
        case .triggeredCalibration, .doneCalibration:
            text = nil
            textView.isHidden = true
            countDownLabel.text = nil
            countDownLabel.isHidden = true
            goBackButton.isHidden = true
        }

        applyTheme()
        setNeedsLayout()
    }

    override func applyTheme() {
        super.applyTheme()

        countDownLabel.textColor = UIColor.semanticColor(.label(.secondary))
        goBackButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .normal)
        goBackButton.addUnderline(with: UIColor.semanticColor(.tint(.primary)))

        if let attributedString = textView.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.semanticColor(.label(.secondary)), range: NSRange(location: 0, length: attributedString.string.count))

            let volumeTipsRange = (attributedString.string as NSString).range(of: NSLocalizedString("ⓘ Please turn up the volume.", comment: "ⓘ Please turn up the volume."))

            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0, weight: .medium), range: volumeTipsRange)

            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.semanticColor(.tint(.primary)), range: volumeTipsRange)

            textView.attributedText = attributedString
        }
    }
}
