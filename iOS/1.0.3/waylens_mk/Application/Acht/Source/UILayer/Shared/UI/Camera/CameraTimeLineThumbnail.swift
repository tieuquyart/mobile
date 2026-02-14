//
//  CameraTimeLineThumbnail.swift
//  Acht
//
//  Created by Chester Shen on 7/20/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class CameraTimeLineThumbnail: UICollectionReusableView {
    @IBOutlet weak var imageView: UIImageView!
    var previousSize: CGSize = .zero
    weak var data: HNThumbnail? {
        didSet {
            refreshMask()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if previousSize != bounds.size {
            refreshMask()
            previousSize = bounds.size
        }
    }
    
    func refreshMask() {
        var corners: UIRectCorner = []
        if data?.isTop ?? false {
            corners.formUnion([.topLeft, .topRight])
        }
        if data?.isBottom ?? false {
            corners.formUnion([.bottomLeft, .bottomRight])
        }
        if data?.isLeft ?? false {
            corners.formUnion([.topLeft, .bottomLeft])
        }
        if data?.isRight ?? false {
            corners.formUnion([.topRight, .bottomRight])
        }
        roundCorners(corners, radius: traitCollection.isIpad ? 4 : 2)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshMask()
    }
    
    override func prepareForReuse() {
        data = nil
        imageView.cancelImageFuture()
        imageView.image = nil
        backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
