//
//  AlbumVideoCell.swift
//  Acht
//
//  Created by Chester Shen on 9/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol AlbumVideoCellDelegate:NSObjectProtocol {
    func onDelete(clip: SavedClip)
    func onExport(clip: SavedClip)
}

class AlbumVideoCell: UITableViewCell {

    @IBOutlet weak var selectionIndicator: UIButton!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var coverLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverAspectConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var deleteShareStackView: UIStackView!

    weak var delegate: AlbumVideoCellDelegate?
    
    var clip: SavedClip? {
        didSet {
            refreshUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        cover.layer.cornerRadius = 2
        cover.clipsToBounds = true
        cover.contentMode = .scaleAspectFit

        indicator.layer.cornerRadius = indicator.frame.width / 2
    }
    
    func refreshUI() {
        selectionIndicator.tintColor = UIColor.semanticColor(.tint(.primary))
        timeLabel.text = clip?.startDate.toHumanizedDateTimeString()
        locationLabel.text = clip?.location?.address?.street
        let thisClip = clip
        if let coordinate = clip?.location?.coordinate, clip?.location?.address == nil {
            CacheManager.shared.locationCache.get(coordinate.coarseGrained())
                .onSuccess({ [weak self] (_location) in
                    thisClip?.location?.address = _location.address
                    SavedClipManager.shared.save()
                    if thisClip == self?.clip {
                        self?.refreshUI()
                    }
                })
        }
        if let path = clip?.thumbnailUrl, let facedown = clip?.facedown {
            let thumbnailURL = URL(fileURLWithPath: path)
            // todo, dewarp
            cover.hn_setImage(url: thumbnailURL, facedown: facedown, dewarp: clip?.needDewarp ?? true, completion: { [weak self] in
                guard let self = self else {
                    return
                }

                if let image = self.cover.image {
                    let newConstraint = self.coverAspectConstraint.constraintWithMultiplier(image.size.width / image.size.height)
                    self.cover.removeConstraint(self.coverAspectConstraint)
                    self.cover.addConstraint(newConstraint)
                    self.coverAspectConstraint = newConstraint
                }
            })
        }
        indicator.backgroundColor = clip?.indicatorColor ?? UIColor.semanticColor(.activity(.buffered))
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            beginEditMode()
        } else {
            endEditMode()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionIndicator.isSelected = selected
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let indicatorColor = indicator.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        indicator.backgroundColor = indicatorColor
    }

    @IBAction func onDelete(_ sender: Any) {
        if clip != nil {
            delegate?.onDelete(clip: clip!)
        }
    }
    
    @IBAction func onExport(_ sender: Any) {
        if clip != nil {
            delegate?.onExport(clip: clip!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.backgroundColor = .clear
        cover.image = nil
        timeLabel.text = nil

        resetCoverAspectConstraint()
    }
    
}

extension AlbumVideoCell {

    private func beginEditMode() {
        coverCenterXConstraint.constant = 36.0
        coverLeadingSpaceConstraint.constant = 52.0
        selectionStyle = .none

        UIView.animate(withDuration: 0.3) {
            self.selectionIndicator.alpha = 1.0
            self.deleteShareStackView.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    private func endEditMode() {
        coverCenterXConstraint.constant = 0.0
        coverLeadingSpaceConstraint.constant = 26.0
        selectionStyle = .default

        UIView.animate(withDuration: 0.3) {
            self.selectionIndicator.alpha = 0.0
            self.deleteShareStackView.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    private func resetCoverAspectConstraint() {
        let newConstraint = self.coverAspectConstraint.constraintWithMultiplier(16.0 / 9.0)
        self.cover.removeConstraint(self.coverAspectConstraint)
        self.cover.addConstraint(newConstraint)
        self.coverAspectConstraint = newConstraint
    }

}
