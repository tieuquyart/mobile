//
//  MonospacedLabel.swift
//  Acht
//
//  Created by Chester Shen on 9/13/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class MonospacedLabel: UILabel {
    
    private func setMono() {
        self.font = UIFont.monospacedDigitSystemFont(ofSize: self.font.pointSize, weight: UIFont.Weight(rawValue: self.font.weight()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setMono()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setMono()
    }
}

extension UIFont {
    func weight() -> CGFloat {
        let fontWeightMap = [
            "UltraLight": UIFont.Weight.ultraLight,
            "Thin": UIFont.Weight.thin,
            "Light": UIFont.Weight.light,
            "UIFontWeightRegular": UIFont.Weight.regular,
            "Medium": UIFont.Weight.medium,
            "Semibold": UIFont.Weight.semibold,
            "Bold": UIFont.Weight.bold,
            "Heavy": UIFont.Weight.heavy,
            "Black": UIFont.Weight.black
        ]
        for (key, weight) in fontWeightMap {
            if fontName.contains(key) {
                return weight.rawValue
            }
        }
        return UIFont.Weight.regular.rawValue
    }
}
