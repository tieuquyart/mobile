//
//  ClipInfoBar.swift
//  Acht
//
//  Created by forkon on 2019/7/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ClipInfoBar: UIView, NibCreatable {
    @IBOutlet private weak var indicatorBar: UIView!
    @IBOutlet private weak var infoLabel: MonospacedLabel!
    @IBOutlet weak var infoButton: UIButton!
    
    var showInfoHandler: (() -> Void)? = nil
    var isAppeared: Bool {
        return superview != nil && !isHidden
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func update(with clip: HNClip) {
        let type = clip.videoType
        let duration = clip.duration

        infoLabel.text = "\(type.description) · \(duration.toString(.hms))"

        if UserSetting.shared.debugEnabled &&
            clip.rawClip?.eventType ?? .NULL != .NULL &&
            clip.rawClip?.eventDate ?? 0.0 > 0.0 {
            infoLabel.text = infoLabel.text! + String.init(format: " @ %0.1f", clip.rawClip!.eventDate)
        }
        indicatorBar.backgroundColor = type.color
    }

    private func setup() {
        indicatorBar.layer.cornerRadius = 2
        indicatorBar.layer.masksToBounds = true
    }

    @IBAction func infoButtonTapped(_ sender: Any) {
        showInfoHandler?()
    }

}
