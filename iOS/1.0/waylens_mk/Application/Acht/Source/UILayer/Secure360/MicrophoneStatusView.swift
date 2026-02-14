//
//  MicrophoneStatusView.swift
//  Acht
//
//  Created by forkon on 2020/1/15.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class MicrophoneStatusView: UIView {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        translatesAutoresizingMaskIntoConstraints = false
    }

}

extension MicrophoneStatusView: NibCreatable {}
