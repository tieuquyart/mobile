//
//  AlertListCell.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import UIKit

class AlertListCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var thumbnailContainingView: UIView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var subInfo: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationLabelGradientBackground: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var uploadingStatusView: UIView!
    
    weak var alert: AchtAlert? {
        didSet {
            refreshUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indicator.layer.cornerRadius = 2
        indicator.layer.masksToBounds = true
        thumbnailContainingView.layer.cornerRadius = 2
        thumbnailContainingView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let indicatorColor = indicator.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        indicator.backgroundColor = indicatorColor
    }
    
    func reset() {
        senderLabel.text = nil
        subInfo.text = nil
        durationLabel.text = nil
        showOrHideDurationLabelGradientBackground()
        indicator.backgroundColor = .clear
        uploadingStatusView.isHidden = true
        thumbnail.image = nil
    }

    func refreshUI() {
        guard let alert = alert else {
            reset()
            return
        }
        #if FLEET
        senderLabel.text = "\(alert.sender) · \(alert.eventType.description)"
        #else
        senderLabel.text = "\(alert.sender) · \(alert.alertType.displayName)"
        #endif
        subInfo.text = alert.location?.address?.street

        #if FLEET
        durationLabel.isHidden = true
        #else
        if alert.duration > 0 {
            durationLabel.text = NSString(time: alert.duration) as String
        } else {
            durationLabel.text = nil
        }
        #endif

        showOrHideDurationLabelGradientBackground()

//        durationLabel.isHidden = true
        dateLabel.text = alert.createTime.toHumanizedDateTimeString()

        #if FLEET
        indicator.backgroundColor = alert.eventType.color
        thumbnail.image = UIImage(named: "video placeholder")
        #else
        indicator.backgroundColor = alert.alertType.color

        if let thumbnailUrl = URL(string: alert.thumbnailUrl) {
            thumbnail.hn_setImage(url: thumbnailUrl, facedown: alert.facedown, dewarp: alert.needDewarp)
            uploadingStatusView.backgroundColor = UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.6)
            contentView.alpha = 1.0
            isUserInteractionEnabled = true
        } else {
            thumbnail.image = nil
            uploadingStatusView.backgroundColor = UIColor.semanticColor(.tint(.primary))
            contentView.alpha = 0.5
            isUserInteractionEnabled = false
        }
        #endif

//        uploadingIcon.isHidden = !(alert.hasVideo && (alert.uploadStatus?.isUploading ?? false))
        
        if alert.uploadStatus?.isUploading == true {
            uploadingStatusView.isHidden = false
        } else {
            uploadingStatusView.isHidden = true
        }
        
        if alert.isRead {
//            backgroundColor = WLStyle.notificationReadBackgroundColor
            senderLabel.font = UIFont.systemFont(ofSize: 14)
            dateLabel.font = UIFont.systemFont(ofSize: 20)
            subInfo.font = UIFont.systemFont(ofSize: 14)
        } else {
            senderLabel.font = UIFont.boldSystemFont(ofSize: 14)
            dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            subInfo.font = UIFont.boldSystemFont(ofSize: 14)
//            backgroundColor = .white
        }
    }

    private func showOrHideDurationLabelGradientBackground() {
        #if FLEET
        durationLabelGradientBackground.isHidden = true
        #else
        if let durationText = durationLabel.text, !durationText.isEmpty {
            durationLabelGradientBackground.isHidden = false
        } else {
            durationLabelGradientBackground.isHidden = true
        }
        #endif
    }
}
