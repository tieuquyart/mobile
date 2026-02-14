//
//  DropDownArrowButton.swift
//  Acht
//
//  Created by forkon on 2020/1/8.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class DropDownArrowButton: UIButton {

    var title: String? {
        set {
            let attributedTitle = NSAttributedString(string: newValue ?? "", attributes: UINavigationBar.appearance().titleTextAttributes)
            set(image: #imageLiteral(resourceName: "icon_white_arrow"), attributedTitle: attributedTitle, at: UIButton.Position.top, width: 6.0, state: UIControl.State.normal)
            sizeToFit()
        }
        get {
            return attributedTitle(for: .normal)?.string
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection), let title = self.title {
                self.title = title
            }
        }
    }

}

//MARK: - Private

private extension DropDownArrowButton {

    func setup() {
        setTitleColor(UIColor.black, for: .normal)
    }

}
