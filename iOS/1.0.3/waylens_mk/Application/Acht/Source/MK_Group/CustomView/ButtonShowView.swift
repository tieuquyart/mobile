//
//  ButtonShowView.swift
//  Acht
//
//  Created by TranHoangThanh on 7/28/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit


protocol ButtonShowViewDelegate : AnyObject {
     func showView()
}


class ButtonShowView : UIView {
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var viewBorder: UIView!
    
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var delegate : ButtonShowViewDelegate?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comonInit()
        
    }
     
    private func comonInit() {
        
        Bundle(for: type(of: self)).loadNibNamed("ButtonShowView" , owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addShadow(offset: CGSize(width: 3, height: 4))
        infoLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!

    }
    
    
    @IBAction func btnShowView(_ sender: Any) {
       
        delegate?.showView()
    }
 
    
    
    
    
}
