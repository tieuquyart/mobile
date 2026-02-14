//
//  RadioControl.swift
//  Acht
//
//  Created by forkon on 2019/5/6.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class RadioControl: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    var isSelected: Bool = false {
        didSet {
            updateUI()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20.0, height: 20.0)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        isSelected = !isSelected
    }

}

private extension RadioControl {

    func setup() {
        backgroundColor = UIColor.white

        layer.borderColor = UIColor.color(fromHex: ConstantMK.blueButton).cgColor
        layer.cornerRadius = intrinsicContentSize.height / 2
        layer.masksToBounds = true

        updateUI()
    }

    func updateUI() {
        if isSelected {
            layer.borderWidth = 6.0
        } else {
            layer.borderWidth = 1.0
        }
    }

}
