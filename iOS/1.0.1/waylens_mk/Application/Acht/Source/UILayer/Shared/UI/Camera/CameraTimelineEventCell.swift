//
//  CameraTimelineEventCell.swift
//  Acht
//
//  Created by Chester Shen on 3/19/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraTimelineEventCell: UICollectionViewCell, ClipRelated {
    var clip: HNClip? {
        didSet {
            refreshUI()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
    }
    
    func refreshUI() {
        if clip?.videoType == .buffered {
            backgroundColor = .clear
        } else {
            backgroundColor = clip?.videoType.color ?? .clear
        }
    }
    
}
