//
//  FixedStyleLabel.swift
//  Acht
//
//  Created by forkon on 2019/9/25.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FixedStyleLabel: UILabel {

    var mainText: String = "" {
        didSet {
            refresh()
        }
    }

    var subText: String = "" {
        didSet {
            refresh()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                refresh()
            }
        }
    }

    private func setup() {
        textAlignment = .left
        numberOfLines = 2

        refresh()
    }

    private func refresh() {
        let string = "\(mainText)\n\(subText)"

        let mainTextRange = (string as NSString).range(of: mainText)
        let subTextRange = (string as NSString).range(of: subText)

        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes(
            [
                NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Regular", size: 18)!,
                NSAttributedString.Key.foregroundColor : UIColor.black,
            ],
            range: mainTextRange
        )
        attributedString.addAttributes(
            [
                NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Regular", size: 12.0)!,
                NSAttributedString.Key.foregroundColor : UIColor.black,
            ],
            range: subTextRange
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }

}
