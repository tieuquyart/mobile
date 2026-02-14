//
//  AlertMessageView.swift
//  Acht
//
//  Created by Chester Shen on 9/28/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import Foundation
import SwiftMessages
import WaylensAPNGKit

class AlertMessageView: MessageView {
    @IBOutlet weak var loadingIcon: WLActivityIndicator?
    func setup(icon: UIImage?=nil, loading: Bool=false, message: String, backgroundColor: UIColor) {
        bodyLabel?.textColor = .white
        bodyLabel?.font = UIFont.systemFont(ofSize: 14)
        bodyLabel?.text = message
        if let icon = icon {
            iconImageView?.image = icon
        } else {
            iconImageView?.isHidden = true
        }
        if loading {
            loadingIcon?.startAnimating()
        } else {
            loadingIcon?.isHidden = true
        }
        backgroundView.backgroundColor = backgroundColor
    }
}
