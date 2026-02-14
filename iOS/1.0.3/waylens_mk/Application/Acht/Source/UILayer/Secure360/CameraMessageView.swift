//
//  CameraMessageView.swift
//  Acht
//
//  Created by forkon on 2020/1/16.
//  Copyright © 2020 waylens. All rights reserved.
//

import SwiftMessages

class CameraMessageView: MessageView {
    var closeButtonTapHandler: ((_ button: UIButton) -> Void)?
}

extension CameraMessageView {

    func config(with message: HNCameraMessage) {
        configureContent(body: message.content)
        backgroundColor = message.level.color
    }

}

//MARK: - Private

private extension CameraMessageView {

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeButtonTapHandler?(sender)
    }

}
