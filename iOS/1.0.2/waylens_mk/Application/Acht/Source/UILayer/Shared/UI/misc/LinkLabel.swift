//
//  LinkLabel.swift
//  Acht
//
//  Created by forkon on 2019/5/6.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LinkLabel: UILabel {

    private var textWithLink: String? = nil
    private var linkHandler: (() -> ())? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setLink(for textToAddLink: String, linkHandler: @escaping () -> ()) {
        if let text = text, text.range(of: textToAddLink) != nil {
            self.textWithLink = textToAddLink
            self.linkHandler = linkHandler

            let underlineAttributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: textToAddLink)
            underlineAttributedString.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
            attributedText = underlineAttributedString
        }
    }

}

private extension LinkLabel {

    func setup() {
        isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        guard let textWithLink = textWithLink, let range = (text as NSString?)?.range(of: textWithLink) else {
            return
        }

        if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
            linkHandler?()
        }
    }

}
