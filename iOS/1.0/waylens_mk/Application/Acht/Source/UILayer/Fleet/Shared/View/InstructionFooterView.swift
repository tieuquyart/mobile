//
//  InstructionFooterView.swift
//  Fleet
//
//  Created by forkon on 2019/12/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensUIKit

class InstructionFooterView: UITextView {
    private let textMargin: CGFloat = 20.0

    init() {
        super.init(frame: CGRect.zero, textContainer: nil)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(withWidth width: CGFloat) {
        if let textHeight = text?.wl.heightWithConstrainedWidth(width: width - textMargin * 2, font: font!) {
            frame.size = CGSize(width: width, height: textHeight + textMargin)
        }
    }

}

//MARK: - Private

private extension InstructionFooterView {

    func setup() {
        isScrollEnabled = false
        isEditable = false
        textContainerInset = UIEdgeInsets(top: textMargin, left: textMargin, bottom: 0.0, right: textMargin)
        backgroundColor = UIColor.clear
        textColor = UIColor.semanticColor(.label(.primary))
        font = UIFont.systemFont(ofSize: 14.0)
    }
}
