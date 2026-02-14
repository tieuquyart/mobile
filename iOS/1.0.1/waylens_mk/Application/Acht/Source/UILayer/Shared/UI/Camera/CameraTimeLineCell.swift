//
//  CameraTimeLineCell.swift
//  Acht
//
//  Created by Chester Shen on 7/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
//protocol CameraTimeLineCellDelegate : NSObjectProtocol {
//    func onLongpressed(cell : CameraTimeLineCell)
//}

protocol ClipRelated {
    var clip: HNClip? { get set }
}

class CameraTimeLineCell: UICollectionViewCell, ClipRelated {
    @IBOutlet weak var timeline: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailArea: UIView!
    @IBOutlet weak var thumbnailAreaTrailingConstraint: NSLayoutConstraint!

    var clip: HNClip? {
        didSet {
            refreshUI()
        }
    }
    
    var isUserSelected: Bool = false {
        didSet {
            if isUserSelected {
                thumbnailArea.alpha = 1
            } else {
                thumbnailArea.alpha = 0
            }
        }
    }
    
    func refreshUI() {
        guard let clip = clip else { return }
        timeline.layer.cornerRadius = timeline.frame.width * 0.5
        timeLabel.text = clip.startDate.toString(format: .timeMin12)
        if clip.videoType.isDMS || clip.videoType.isADAS {
            locationLabel.text = clip.videoType.description
        } else {
            if let location = clip.location {
                if clip.videoType.isParking {
                    locationLabel.text = location.address?.street
                } else {
                    if location.horizontalAccuracy < 99 {
                        locationLabel.text = location.address?.street
                    } else {
                        locationLabel.text = location.address?.city
                    }
                }
            } else {
                locationLabel.text = nil
            }
        }
        timeline.backgroundColor = clip.videoType.color
    }
    
    override func awakeFromNib() {
        applyTheme()
        isUserSelected = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        applyTheme()
    }
    
    override func prepareForReuse() {
        isUserSelected = false
    }
}

extension CameraTimeLineCell: Themed {

    func applyTheme() {
        thumbnailArea.layer.borderColor = UIColor.semanticColor(.fill(.tertiary)).cgColor

        let scale: CGFloat = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ? 2 : 1
        thumbnailArea.layer.borderWidth = 3 * scale
        thumbnailArea.layer.cornerRadius = 2 * scale
    }

}
