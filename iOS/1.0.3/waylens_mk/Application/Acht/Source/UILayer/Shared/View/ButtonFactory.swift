//
//  ButtonFactory.swift
//  Acht
//
//  Created by forkon on 2019/11/3.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ButtonFactory {

    class func makeBigBottomButton(_ title: String, titleColor: UIColor = .white, color: UIColor, borderColor: UIColor? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.setBackgroundImageColor(color, disabledColor: UIColor.lightGray)
        button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2.0
        button.layer.borderColor = borderColor?.cgColor
        button.layer.borderWidth = (borderColor != nil) ? 1.0 : 0.0
        return button
    }

    class func makeNoBackgroundButton(_ title: String, titleColor: UIColor = UIColor.black) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        button.sizeToFit()
        return button
    }

}
