//
//  FooterSDCardView.swift
//  Fleet
//
//  Created by DevOps MKVision on 19/01/2024.
//  Copyright © 2024 waylens. All rights reserved.
//

import UIKit

class FooterSDCardView: UIView {
    
    @IBOutlet weak var textLable : UILabel!
    @IBOutlet weak var contentView : UIView!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    func initView(){
        Bundle(for: type(of: self)).loadNibNamed("FooterSDCardView" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        textLable.font = UIFont(name: "BeVietnamPro-Regular", size: 12)!
        textLable.textColor = UIColor.color(fromHex: "#9AA7B6")
        textLable.text = NSLocalizedString("sdcard_event_videos_maximum_space_explanation", comment: "Set the maximum space to allocate for event videos. When events reach the selected value, the oldest event video will be removed automatically when a new event video is generated.")
    }
}
