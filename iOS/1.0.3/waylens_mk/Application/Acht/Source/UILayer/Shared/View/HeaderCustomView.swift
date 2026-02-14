//
//  HeaderCustomView.swift
//  Fleet
//
//  Created by DevOps MKVision on 24/01/2024.
//  Copyright © 2024 waylens. All rights reserved.
//

import UIKit

protocol HeaderCustomViewDelegate{
    func onBack()
}

class HeaderCustomView: UIView {
    
    var delegate : HeaderCustomViewDelegate?
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var viewBound : UIView!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var title : UILabel!
    
    let nibName = "HeaderCustomView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    func initView(){
        Bundle.main.loadNibNamed(nibName, owner: self)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        clipsToBounds = true
        
//        viewBound.viewShadow(offset: CGSize(width: 3, height: 4))
    }
    
    
    func isHiddenBack(_ isHidden : Bool){
        backBtn.isHidden = isHidden
    }
    
    @IBAction func backBtn(_ sender : Any){
        print("onBack")
        self.delegate?.onBack()
    }

}

