//
//  CameraSettingCell.swift
//  Acht
//
//  Created by Chester Shen on 9/29/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class CameraSettingCell: UITableViewCell {
    var isEnabled: Bool = false {
        didSet {
            refreshEnabled()
        }
    }
    let cover = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(cover)

        applyTheme()

        cover.frame = self.bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapCover))
        cover.addGestureRecognizer(tap)
        bringSubviewToFront(cover)
        refreshEnabled()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    @objc func onTapCover() {
        HNMessage.showInfo(message: NSLocalizedString("Please connect via Wi-Fi to enable this setting", comment: "Please connect via Wi-Fi to enable this setting"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cover.frame = self.bounds
    }
    
    func refreshEnabled() {
        cover.isHidden = isEnabled
        selectionStyle = isEnabled ? .default : .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isEnabled = false
    }
}

extension CameraSettingCell: Themed {

    func applyTheme() {
        cover.backgroundColor = UIColor.semanticColor(.background(.secondary)).withAlphaComponent(0.5)
    }

}
