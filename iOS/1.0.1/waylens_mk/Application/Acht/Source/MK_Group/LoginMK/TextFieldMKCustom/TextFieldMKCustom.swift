//
//  TextFieldMKCustom.swift
//  Acht
//
//  Created by TranHoangThanh on 11/22/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import UIKit

private let familyName = "SFProDisplay"

enum AppFont: String {
    case light = "Light"
    case regular = "Regular"
    case bold = "Bold"

    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size + 1.0) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    
    fileprivate var fullFontName: String {
        return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
    }
    
    
}

//extension UIFont {
//
//    public enum SFProType: String {
//        case regular = "-Regular"
//    }
//
//    static func SFPro(_ type: SFProType = .regular , size: CGFloat = UIFont.systemFontSize) -> UIFont {
//        return UIFont(name: "SF-Pro-Display-\(type.rawValue)", size: size)!
//    }
//
//    var isBold: Bool {
//        return fontDescriptor.symbolicTraits.contains(.traitBold)
//    }
//
//    var isItalic: Bool {
//        return fontDescriptor.symbolicTraits.contains(.traitItalic)
//    }
//
//}

class TextFieldMKCustom : UIView {
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var viewTf: UIView!
    @IBOutlet weak var infoTextField: UITextField!
  
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
    }
    
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comonInit()
        
    }
    
    func setTitle(str : String ) {
        self.titleLbl.text = str
        
    }
    
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("TextFieldMKCustom" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
//        contentView.roundCorners([.bottomLeft, .bottomRight], radius: 30)
//
        self.titleLbl.font =  AppFont.regular.size(14)
        viewTf.layer.cornerRadius = 12
        viewTf.layer.masksToBounds = true
        viewTf.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        viewTf.layer.borderWidth = 1
        
       
    }
    
}
