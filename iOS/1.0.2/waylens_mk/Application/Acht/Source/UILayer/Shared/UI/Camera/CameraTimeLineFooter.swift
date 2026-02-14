//
//  CameraTimeLineFooter.swift
//  Acht
//
//  Created by Chester Shen on 8/8/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensAPNGKit

protocol CameraTimeLineFooterDelegate: NSObjectProtocol {
    func onTapFooterButton()
}

class CameraTimeLineFooter: UICollectionReusableView {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var loadingIcon: APNGImageView!
    
    weak var delegate: CameraTimeLineFooterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        button.isHidden = true
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onAction), for: .touchUpInside)

        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    func startLoading() {
        loadingIcon.isHidden = false
        icon.isHidden = true
        titleLabel.isHidden = true
        detailLabel.isHidden = true
        button.isHidden = true
        if loadingIcon.image == nil {
            loadingIcon.image = loadingImage
        }
        loadingIcon.startAnimating()
    }
    
    func stopLoading() {
        loadingIcon.stopAnimating()
        loadingIcon.isHidden = true
    }
    
    func show(level: HNWarningLevel, title: String, detail: String) {
        stopLoading()
        icon.isHidden = false
        titleLabel.isHidden = false
        detailLabel.isHidden = false
        button.isHidden = true
        icon.image = level == .error ? #imageLiteral(resourceName: "icon_sign_error") : #imageLiteral(resourceName: "icon_sign_warning")
        titleLabel.text = title
        detailLabel.text = detail
    }
    
    func show(image: UIImage, title: String, detail: String, buttonTitle: String?) {
        stopLoading()
        icon.isHidden = false
        titleLabel.isHidden = false
        detailLabel.isHidden = false
        icon.image = image
        titleLabel.text = title
        detailLabel.text = detail
        if buttonTitle != nil {
            button.isHidden = false
            button.setTitle(buttonTitle, for: .normal)
        } else {
            button.isHidden = true
        }
    }
    
    @objc func onAction() {
        delegate?.onTapFooterButton()
    }
}

private extension CameraTimeLineFooter {

    var loadingImage: APNGImage? {
        if #available(iOS 12.0, *) {
            return (traitCollection.userInterfaceStyle == .dark) ? APNGImage(named: "logo_loading_light") : APNGImage(named: "logo_loading_dark")
        } else {
            return APNGImage(named: "logo_loading_dark")
        }
    }

}

extension CameraTimeLineFooter: Themed {

    func applyTheme() {
        loadingIcon.image = loadingImage
        button.setBackgroundImageColor(UIColor.semanticColor(.tint(.primary)))
    }

}
