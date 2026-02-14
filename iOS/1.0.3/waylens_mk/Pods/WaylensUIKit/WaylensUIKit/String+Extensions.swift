//
//  String+Extensions.swift
//  WaylensUIKit
//
//  Created by forkon on 2020/8/27.
//  Copyright © 2020 Waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

public extension WaylensSpace where Base == String {

    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = base.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }

}
