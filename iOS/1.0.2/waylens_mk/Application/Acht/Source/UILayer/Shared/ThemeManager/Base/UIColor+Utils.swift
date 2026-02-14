//
//  UIColor+Utils.swift
//  Gaudi
//
//  Created by Giuseppe Lanza on 13/12/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import UIKit

public extension UIColor {
    
    @available(iOS 13.0, *)
    convenience init(lightColor: UIColor, darkColor: UIColor) {
        self.init { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .light: return lightColor
            case .dark: return darkColor
            case .unspecified: return lightColor
            @unknown default: return lightColor
            }
        }
    }
    
    final func negative() -> UIColor {
        var (r, g, b): (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
        _ = getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red: 1 - r, green: 1 - g, blue: 1 - b, alpha: 1)
    }

    /**
     Creates and returns a color object with the lightness increased by the given amount.

     - parameter amount: CGFloat between 0.0 and 1.0. Default value is 0.2.
     - returns: A lighter UIColor.
     */
    final func lighter(amount: CGFloat = 0.2) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return UIColor(hue: hue, saturation: saturation, brightness: brightness + amount, alpha: alpha)
    }

    /**
     Creates and returns a color object with the lightness decreased by the given amount.

     - parameter amount: Float between 0.0 and 1.0. Default value is 0.2.
     - returns: A darker UIColor.
     */
    final func darkened(amount: CGFloat = 0.2) -> UIColor {
        return lighter(amount: amount * -1.0)
    }

    /**
     Creates and returns a color object with the saturation increased by the given amount.

     - parameter amount: CGFloat between 0.0 and 1.0. Default value is 0.2.
     - returns: A UIColor more saturated.
     */
    final func saturated(amount: CGFloat = 0.2) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return UIColor(hue: hue, saturation: saturation + amount, brightness: brightness, alpha: alpha)
    }

    /**
     Creates and returns a color object with the saturation decreased by the given amount.

     - parameter amount: CGFloat between 0.0 and 1.0. Default value is 0.2.
     - returns: A UIColor less saturated.
     */
    final func desaturated(amount: CGFloat = 0.2) -> UIColor {
        return saturated(amount: amount * -1.0)
    }
    
    final func toImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    final func isSameColorAs(_ color: UIColor) -> Bool {
        var (selfR, selfG, selfB, selfA): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        _ = getRed(&selfR, green: &selfG, blue: &selfB, alpha: &selfA)
        _ = color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let distance = sqrt(pow(selfR - r, 2) + pow(selfG - g, 2) + pow(selfB - b, 2) + pow(selfA - a, 2))
        return distance <= 0.0002
    }

    /*
    func isSameColorAs(_ color : UIColor) -> Bool {
        if self == color {
            return true
        }

        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let convertColorToRGBSpace : ((_ color : UIColor) -> UIColor?) = { (color) -> UIColor? in
            if color.cgColor.colorSpace!.model.rawValue == CGColorSpaceModel.rgb.rawValue {
                let oldComponents = color.cgColor.components!
                let components : [CGFloat] = [ oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1] ]
                let colorRef = CGColor(colorSpace: colorSpaceRGB, components: oldComponents)!
                let colorOut = UIColor(cgColor: colorRef)
                return colorOut
            }
            else {
                return color
            }
        }

        let selfColor = convertColorToRGBSpace(self)
        let otherColor = convertColorToRGBSpace(color)

        if let selfColor = selfColor, let otherColor = otherColor {
            var (selfR, selfG, selfB): (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
            var (r, g, b): (CGFloat, CGFloat, CGFloat) = (0, 0, 0)

            _ = selfColor.getRed(&selfR, green: &selfG, blue: &selfB, alpha: nil)
            _ = otherColor.getRed(&r, green: &g, blue: &b, alpha: nil)

            let distance = sqrt(pow(selfR - r, 2) + pow(selfG - g, 2) + pow(selfB - b, 2))
            return distance <= 0.000001
        }
        else {
            return false
        }
    }
*/
}
