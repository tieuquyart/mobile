//
//  HNSignBoard.swift
//  Acht
//
//  Created by Chester Shen on 12/13/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensAPNGKit

enum HNWarningLevel {
    case error
    case warning
    case information
    
    var color: UIColor {
        switch self {
        case .error:
            return UIColor.semanticColor(.fill(.quaternary))
        case .warning:
            return UIColor.semanticColor(.fill(.senary))
        case .information:
            return UIColor.semanticColor(.fill(.quinary))
        }
    }
}

class HNSignBoard: UIView {
    @IBOutlet weak var loadingIcon: APNGImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HNSignBoard", owner: self, options: nil)
        addSubview(contentView)
        backgroundColor = .clear
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.masksToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                loadingIcon.image = loadingImage
            }
        }
    }
    
    func startLoading() {
        isHidden = false
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
        isHidden = false
        stopLoading()
        icon.isHidden = false
        titleLabel.isHidden = false
        detailLabel.isHidden = false
        button.isHidden = true
        icon.image = level == .error ? #imageLiteral(resourceName: "icon_sign_error") : #imageLiteral(resourceName: "icon_sign_warning")
        titleLabel.text = title
        detailLabel.text = detail
    }
    
    func showDisconnected() {
        show(
            image: #imageLiteral(resourceName: "icon_network_disconnected"),
            title: NSLocalizedString("Network Not Available", comment: "Network Not Available"),
            detail: NSLocalizedString("Please check your network settings and try again.", comment: "Please check you network settings and try again."), buttonTitle: nil
        )
    }
    
    func show(image: UIImage, title: String, detail: String, buttonTitle: String?) {
        isHidden = false
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
    
    func hide() {
        isHidden = true
    }
}

private extension HNSignBoard {

    var loadingImage: APNGImage? {
        if #available(iOS 12.0, *) {
            return (traitCollection.userInterfaceStyle == .dark) ? APNGImage(named: "logo_loading_light") : APNGImage(named: "logo_loading_dark")
        } else {
            return APNGImage(named: "logo_loading_dark")
        }
    }

}
