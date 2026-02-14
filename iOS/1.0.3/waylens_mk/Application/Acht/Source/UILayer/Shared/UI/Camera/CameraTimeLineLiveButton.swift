//
//  CameraTimeLineLiveButton.swift
//  
//
//  Created by Chester Shen on 7/18/17.
//
//

import UIKit

class CameraTimeLineLiveButton: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    enum Style {
        case vertical
        case horizontal
    }
    
    var style: Style = .vertical {
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() {
        switch style {
        case .vertical:
            setVerticalStyle()
        case .horizontal:
            setHorizontalStyle()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshUI()
    }
    
    func setHorizontalStyle() {
        layer.cornerRadius = 3
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    func setVerticalStyle() {
        layer.cornerRadius = bounds.height * 0.5
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "Live"
        titleLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        titleLabel.textColor = UIColor.black
    }
}
