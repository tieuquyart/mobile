//
//  TextFieldMKCustom.swift
//  Acht
//
//  Created by TranHoangThanh on 11/22/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
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
    func txtSecureEntry(secureTxt: Bool) {
        infoTextField.isSecureTextEntry = secureTxt
    }
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("TextFieldMKCustom" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        viewTf.layer.cornerRadius = 12
        viewTf.layer.masksToBounds = true
        viewTf.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        viewTf.layer.borderWidth = 1
    }
}
