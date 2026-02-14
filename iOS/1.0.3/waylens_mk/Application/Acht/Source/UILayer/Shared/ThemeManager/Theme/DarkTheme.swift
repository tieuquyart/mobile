//
//  DarkTheme.swift
//  Acht
//
//  Created by forkon on 2020/3/12.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

private extension SemanticColor {
    var color: UIColor {
        switch self {
        case .bgTabbar:
            return #colorLiteral(red: 0.07351463288, green: 0.2407833934, blue: 0.4768569469, alpha: 1)
        case .tint(let tintColor):
            switch tintColor {
#if FLEET
            case .primary: return #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1) // #4A90E2
#else
            case .primary: return #colorLiteral(red: 0.3058823529, green: 0.6823529412, blue: 0.8901960784, alpha: 1) // #4EAEE3
#endif
            case .secondary: return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) // #EFEFEF
            }
        case .label(let labelColor):
            switch labelColor {
            case .primary: return #colorLiteral(red: 0.6, green: 0.6274509804, blue: 0.662745098, alpha: 1) // #99A0A9
            case .secondary: return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) // #EFEFEF
            case .tertiary: return #colorLiteral(red: 0.8666666667, green: 0.2588235294, blue: 0.3137254902, alpha: 1) // #DD4250
            case .quaternary: return #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1) // #9B9B9B
            case let .custom(color): return color
            }
        case .fill(let fillColor):
            switch fillColor {
            case .primary: return #colorLiteral(red: 0.4941176471, green: 0.8274509804, blue: 0.1294117647, alpha: 1) // #7ED321
            case .secondary: return #colorLiteral(red: 0.1450980392, green: 0.1960784314, blue: 0.2196078431, alpha: 1).withAlphaComponent(0.87) // #253238
            case .tertiary: return #colorLiteral(red: 0.8666666667, green: 0.2588235294, blue: 0.3137254902, alpha: 1) // #DD4250
            case .quaternary: return #colorLiteral(red: 0.9215686275, green: 0.3529411765, blue: 0.262745098, alpha: 1) // #EB5A43
            case .quinary: return #colorLiteral(red: 0.3058823529, green: 0.6823529412, blue: 0.8901960784, alpha: 1) // #4EAEE3
            case .senary: return #colorLiteral(red: 0.968627451, green: 0.7176470588, blue: 0.2352941176, alpha: 1) // #F7B73C
            case .septenary: return #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1) // #FAFAFA
            case .octonary: return #colorLiteral(red: 0.2039215686, green: 0.2588235294, blue: 0.3294117647, alpha: 1) // #344254
            case let .custom(color): return color
            }
        case .background(let backgroundColor):
            switch backgroundColor {
            case .primary: return  UIColor.color(fromHex: ConstantMK.bgColorLogin)
               
               
            case .secondary: return .black
            case .tertiary: return #colorLiteral(red: 0.8666666667, green: 0.2588235294, blue: 0.3137254902, alpha: 1) // #DD4250
            case .quaternary: return #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1).negative() // #9B9B9B
            case .quinary: return UIColor(rgb: 0x5CBB5E)
            case .senary: return #colorLiteral(red: 0.2039215686, green: 0.2588235294, blue: 0.3294117647, alpha: 1) // #344254
            case .septenary: return .black
            case .octonary: return  #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1).negative() // #E7E7E7
            case .mask: return UIColor.black.withAlphaComponent(0.5)
            case .maskLight: return UIColor.black.withAlphaComponent(0.3)
            case .highlighted: return #colorLiteral(red: 0.9647058824, green: 0.9764705882, blue: 0.9843137255, alpha: 1).darkened(amount: 0.8) // #F6F9FB
            case .buttonDisabled: return #colorLiteral(red: 0.6, green: 0.6274509804, blue: 0.662745098, alpha: 1) // #99A0A9
            case let .custom(color): return color
            }
        case .separator(let separatorColor):
            switch separatorColor {
            case .semiTransparent:
                if #available(iOS 13.0, *) {
                    return UIColor.separator
                } else {
                    return UIColor.darkGray.darkened().withAlphaComponent(0.8)
                }
            case .opaque:
                if #available(iOS 13.0, *) {
                    return .opaqueSeparator
                } else {
                    return UIColor.darkGray.darkened()
                }
            case let .custom(color): return color
            }
        case .border(let borderColor):
            switch borderColor {
#if FLEET
            case .primary: return #colorLiteral(red: 0.6, green: 0.6274509804, blue: 0.662745098, alpha: 1) // #99A0A9
#else
            case .primary: return #colorLiteral(red: 0.8392156863, green: 0.8509803922, blue: 0.8666666667, alpha: 1) // #D6D9DD
#endif
            case let .custom(color): return color
            }
        case .activity(let activityColor):
            switch activityColor {
            case .buffered: return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1) // #E5E5E5
            case .heavy: return #colorLiteral(red: 0.9215686275, green: 0.3529411765, blue: 0.262745098, alpha: 1) // #EB5A43
            case .hit: return #colorLiteral(red: 0.968627451, green: 0.7176470588, blue: 0.2352941176, alpha: 1) // #F7B73C
            case .hardBehavior: return #colorLiteral(red: 0.7764705882, green: 0.4431372549, blue: 0.7921568627, alpha: 1) // #C671CA
            case .harshBehavior: return #colorLiteral(red: 0.7764705882, green: 0.4431372549, blue: 0.7921568627, alpha: 1) // #C671CA
            case .severeBehavior: return #colorLiteral(red: 0.7764705882, green: 0.4431372549, blue: 0.7921568627, alpha: 1) // #C671CA
            case .manual: return #colorLiteral(red: 0.3529411765, green: 0.6196078431, blue: 0.9333333333, alpha: 1) // #5A9EEE
            case .dms: return #colorLiteral(red: 0.4352941176, green: 0.0862745098, blue: 0.9137254902, alpha: 1) // #6F16E9
            case .motion: return #colorLiteral(red: 0.9176470588, green: 0.8705882353, blue: 0.3882352941, alpha: 1) // #EADE63
            case .adas: return #colorLiteral(red: 0.05882352941, green: 0.6901960784, blue: 0.5843137255, alpha: 1) // #0FB095
            case .account: return #colorLiteral(red: 0.05882352941, green: 0.6901960784, blue: 0.5843137255, alpha: 1) // #0FB095
            case .ignition: return #colorLiteral(red: 0.05882352941, green: 0.6901960784, blue: 0.5843137255, alpha: 1) // #0FB095
            case .payment: return #colorLiteral(red: 0.05882352941, green: 0.6901960784, blue: 0.5843137255, alpha: 1) // #0FB095
            }
        case .cameraPickerBackground:
            return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // #191919
        case .playerContainerBackground:
            return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // #191919
        case .textInputAreaBackground:
            return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // #191919
#if FLEET
        case .cardHeaderBackground:
            return #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1) // #252525
        case .cardBackground:
            return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // #191919
        case .mapFloatingPanelBackground:
            return UIColor.clear
            //return #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1) // #252525
        case .tableViewCellBackground(let tableViewCellBackgroundColor):
            switch tableViewCellBackgroundColor {
            case .grouped:
                if #available(iOS 13.0, *) {
                    return UIColor.secondarySystemGroupedBackground
                } else {
                    return #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1) // #1C1C1E
                }
            }
        case .grabberHandleBar:
            return #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1) // #E7E7E7
        case .parkingStatus:
            return #colorLiteral(red: 0.3568627451, green: 0.7568627451, blue: 0.3843137255, alpha: 1) // #5BC162
        case .timelineAxis:
            return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1) // #E5E5E5
        case .timelineMilestonePoint:
            return #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1) // #A8A8A8
        case .memberTagBackground:
            return #colorLiteral(red: 0.3333333333, green: 0.3647058824, blue: 0.4196078431, alpha: 1) // #555D6B
#endif
        }
    }
}

private extension FontAttribute {
    func primaryFont(withSize size: CGFloat = UIFont.labelFontSize) -> UIFont {
        switch self {
        case .regular: return UIFont(name: "BeVietnamPro-Regular", size: size)!
        case .medium: return UIFont(name: "BeVietnamPro-Medium", size: size)!
        case .bold: return UIFont(name: "BeVietnamPro-Bold", size: size)!
        case .semibold: return UIFont(name: "BeVietnamPro-Semibold", size: size)!
        case .italic: return UIFont(name: "BeVietnamPro-Italic", size: size)!
        }
    }
}

private extension FontStyle {
    var fontSize: CGFloat {
        switch self {
        case .small: return 11
        case .caption: return 12
        case .subhead: return 13
        case .body: return 15
        case .headline: return 18
        case .title: return 22
        case .display: return 26
        case .displayBig: return 32
        }
    }
    
    var font: UIFont {
        return attribute.primaryFont(withSize: fontSize)
    }
}
