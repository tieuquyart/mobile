//
//  LabelHeaderView.swift
//  Fleet
//
//  Created by forkon on 2020/12/22.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

func LabelHeaderView(title: String) -> UILabel {
    let label = UILabel()
    label.backgroundColor = UIColor.white
    label.numberOfLines = 0

    let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    style.firstLineHeadIndent = 20.0
    style.headIndent = 20.0
    style.tailIndent = -20.0

    let attrText = NSAttributedString(string: title, attributes:
        [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Regular", size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor.semanticColor(.label(.primary))
        ]
    )

    label.attributedText = attrText

    label.frame.size = attrText.size(constrainedToWidth: UIScreen.main.bounds.width)
    label.frame.size.height += 22 * 2

    return label
}
