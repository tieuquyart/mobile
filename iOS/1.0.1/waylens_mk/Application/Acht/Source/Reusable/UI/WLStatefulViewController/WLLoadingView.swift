//
//  WLLoadingView.swift
//  Acht
//
//  Created by forkon on 2020/2/11.
//  Copyright © 2020 Waylens. All rights reserved.
//

import UIKit

class WLLoadingView: UIView {

    @IBOutlet weak var activityIndicatorView: WLActivityIndicator!

    override func awakeFromNib() {
        super.awakeFromNib()

        applyTheme()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        activityIndicatorView.startAnimating()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
}

extension WLLoadingView: Themed {

    func applyTheme() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                activityIndicatorView.isLight = true
            }
            else {
                activityIndicatorView.isLight = false
            }
        }
    }

}
