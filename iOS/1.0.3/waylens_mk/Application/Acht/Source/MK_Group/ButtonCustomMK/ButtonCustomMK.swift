//
//  ButtonCustomMK.swift
//  Acht
//
//  Created by TranHoangThanh on 12/23/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

protocol ButtonCustomMKDelegate : AnyObject {
    func tapButton()
}

class ButtonCustomMK: UIView {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgIconView: UIImageView!
    
    weak var delegate : ButtonCustomMKDelegate?
    var isBorder = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        comonInit()
    }
    func setTitle(str : String , imageStr : String) {
        self.titleLbl.text = str
        self.imgIconView.image = UIImage(named: imageStr)!
    }
    
    func setFontTitle(_ font: UIFont){
        self.titleLbl.font = font
    }
    
    func setTitleColorAndImageColor(color: UIColor){
        self.titleLbl.textColor = color
        self.imgIconView.image = self.imgIconView.image?.withRenderingMode(.alwaysTemplate)
        self.imgIconView.tintColor = color
    }
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    func setBorderView() {
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.masksToBounds = true
        viewContainer.addShadow(offset: CGSize(width: 3, height: 4))
    }
    
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("ButtonCustomMK" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
       
    }
}
