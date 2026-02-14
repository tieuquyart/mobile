//
//  TimelineCardHeaderView.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class TimelineCardHeaderView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!

//    var date: Date? = nil {
//        didSet {
//            if let date = date {
//                titleLabel.text = date.dateManager.fleetDate.toString(.date(.medium))
//            }
//        }
//    }

    var date: String? = nil {
        didSet {
            if let date = date {
                titleLabel.text = date
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
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

//MARK: - Private

private extension TimelineCardHeaderView {

    func setup() {
        applyTheme()
    }

}

extension TimelineCardHeaderView: Themed {

    func applyTheme() {
        backgroundColor = UIColor.semanticColor(.cardHeaderBackground)
    }

}

extension TimelineCardHeaderView: NibCreatable {}
