//
//  WLStyle.swift
//  Acht
//
//  Created by Chester Shen on 6/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a:CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(rgb: Int, a:CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
}

extension UIButton {
    func setEnabled(enabled: Bool) {
        self.isEnabled = enabled
        self.backgroundColor = enabled ? UIColor.semanticColor(.tint(.primary)) : UIColor.semanticColor(.background(.quaternary))
    }
    
    func setBackgroundImageColor(_ color: UIColor, disabledColor: UIColor?=nil) {
        let image = UIImage(color: color)
        setBackgroundImage(image, for: .normal)
        if let color = disabledColor {
            let image = UIImage(color: color)
            setBackgroundImage(image, for: .disabled)
        }
    }

    func setBackgroundImage(with color: UIColor, for state: UIControl.State) {
        let image = UIImage(color: color)
        setBackgroundImage(image, for: state)
    }
    
    func applyMainStyle() {
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        self.setBackgroundImageColor(UIColor.semanticColor(.tint(.primary)), disabledColor: UIColor.semanticColor(.background(.quaternary)))
    }
    
    func applyClearStyle() {
        backgroundColor = .clear
        setBackgroundImage(nil, for: .normal)
        setBackgroundImage(nil, for: .disabled)
    }
}

class HNMainButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        applyMainStyle()
    }
}


class CenteredButton: UIButton
{
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        
        return CGRect(x: 0, y: contentRect.height - rect.height - 5,
                      width: contentRect.width, height: rect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        
        return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
                      y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
                      width: rect.width, height: rect.height)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        if let image = imageView?.image {
            var labelHeight: CGFloat = 0.0
            
            if let size = titleLabel?.sizeThatFits(CGSize(width: self.contentRect(forBounds: self.bounds).width, height: CGFloat.greatestFiniteMagnitude)) {
                labelHeight = size.height
            }
            
            return CGSize(width: size.width, height: image.size.height + labelHeight)
        }
        
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
    
    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}

extension UITraitCollection {
    var isIpad: Bool {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var isIphoneLandscape: Bool {
        return verticalSizeClass == .compact
    }
    
    var isIphonePortrait: Bool {
        return horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var isIphone: Bool {
        return isIphoneLandscape || isIphonePortrait
    }
}
