//
//  CameraTimeLineHorizontalCell.swift
//  Acht
//
//  Created by forkon on 2018/8/24.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class CameraTimeLineHorizontalCell: UICollectionViewCell {
    
    static let colorViewHeight: CGFloat = 4.0
    static let colorViewPadding: CGFloat = 1.0

    var imageView: UIImageView!
    var colorView: UIView!
    
    var cellModel: CameraTimeLineHorizontalCellModel? {
        didSet {
            refreshUI(with: cellModel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    class func thumbnailSize(for cellHeight: CGFloat) -> CGSize {
        let thumbnailHeight: CGFloat = cellHeight - CameraTimeLineHorizontalCell.colorViewHeight - colorViewPadding
        let ratio: CGFloat = 16.0 / 9.0
        return CGSize(width: thumbnailHeight * ratio, height: thumbnailHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let thumbnailSize = CameraTimeLineHorizontalCell.thumbnailSize(for: bounds.height)
        let imageViewY = CameraTimeLineHorizontalCell.colorViewHeight + CameraTimeLineHorizontalCell.colorViewPadding
        imageView.frame = CGRect(
            x: 0.0,
            y: imageViewY,
            width: thumbnailSize.width,
            height: thumbnailSize.height
        )
        
        colorView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.width,
            height: CameraTimeLineHorizontalCell.colorViewHeight
        )
        colorView.layer.cornerRadius = colorView.frame.height / 2
        
        // a trick, make the two adjacent |colorView| with same color look like they are connected together.
        if let cellModel = cellModel {
            if cellModel.previousVideoType == cellModel.segment.clip?.videoType {
                colorView.frame.origin.x -= 10.0
                colorView.frame.size.width += 10.0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        cellModel = nil
        
        imageView.image = nil
        colorView.backgroundColor = UIColor.clear
    }

}

extension CameraTimeLineHorizontalCell {
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        
        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        imageView.layer.cornerRadius = 0.0
        addSubview(imageView)
        
        colorView = UIView()
        colorView.backgroundColor = UIColor.clear
        addSubview(colorView)
    }
    
    fileprivate func refreshUI(with cellModel: CameraTimeLineHorizontalCellModel?) {
        guard let cellModel = cellModel else {
            return
        }

        let segment = cellModel.segment

        imageView.frame = CGRect(origin: CGPoint.zero, size: cellModel.thumbnailSize)

        guard let clip = segment.clip else {
            return
        }

        if let cameraID = cellModel.cameraID, let rawClip = clip.rawClip {
            let pts = segment.time(at: 0.0)
            let request = VDBThumbnailRequest(cameraID: cameraID, clip: rawClip, pts: pts, cache: true, ignorable: false)

            imageView.vdb_setThumbnail(request, animated:true)
        } else {
            if let thumbnailUrlString = clip.thumbnailUrl, let url = URL(string: thumbnailUrlString) {
                imageView.hn_setImage(url: url, facedown: clip.facedown, dewarp: clip.needDewarp)
            }
        }

        colorView.backgroundColor = ((clip.videoType == .buffered) ? UIColor.clear : clip.videoType.color)

        setNeedsLayout()
    }
    
}

struct CameraTimeLineHorizontalCellModel {
    var cameraID: String? = nil
    var previousVideoType: HNVideoType?
    let thumbnailSize: CGSize
    let segment: HNClipSegment
    
    init(segment: HNClipSegment, cameraID: String, thumbnailSize: CGSize, previousVideoType: HNVideoType?) {
        self.segment = segment
        self.cameraID = cameraID
        self.thumbnailSize = thumbnailSize
        self.previousVideoType = previousVideoType
    }
    
    init(segment: HNClipSegment, thumbnailSize: CGSize, previousVideoType: HNVideoType?) {
        self.segment = segment
        self.thumbnailSize = thumbnailSize
        self.previousVideoType = previousVideoType
    }
}

class CameraTimeLineHorizontalLiveCell: CameraTimeLineHorizontalCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame.size.width = bounds.width
    }
    
}
