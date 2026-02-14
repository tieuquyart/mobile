//
//  CameraTimeLineHorizontalLayout.swift
//  Acht
//
//  Created by Chester Shen on 3/15/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraTimeLineHorizontalLayout: UICollectionViewLayout {
    var dataSource: CameraTimeLineDataSource? {
        didSet {
            if dataSource != oldValue {
                invalidateLayout()
            }
        }
    }
    static let cellSpacing:CGFloat = 14
    let thumbnailWidth: CGFloat = 73
    let thumbnailHeight:CGFloat = 41
    let liveButtonWidth: CGFloat = 65
    let thumbnailYOffset: CGFloat = 18
    let indicatorYOffset: CGFloat = 13
    let indicatorHeight: CGFloat = 4
    let durationUnit: TimeInterval = 30
    let bufferedRatio = 8.0
    var contentWidth:CGFloat = 0
    
    private var itemAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    private var thumbnailAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    private var liveButtonAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryLiveButton, with: IndexPath(item: 0, section: 0))
    private var clipSegments: Array<HNClipSegment> = []
    private var thumbnailMap = [IndexPath: HNThumbnail]()
    var collectionViewBoundsSize: CGSize = .zero
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: contentWidth, height: collectionViewBoundsSize.height)
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        itemAttributesCache.removeAll()
        thumbnailAttributesCache.removeAll()
        clipSegments.removeAll()
        calcLayout()
    }
    
    override func prepare() {
        super.prepare()
        calcLayout()
        (collectionView?.delegate as? TimeLineCollectionViewDelegate)?.layoutDidPrepare()
    }
    
    private func calcLayout() {
        guard itemAttributesCache.isEmpty, let dataSource = dataSource, let collectionView = collectionView else { return }
        if collectionViewBoundsSize == .zero {
            collectionViewBoundsSize = collectionView.bounds.size
        }
        var xOffset: CGFloat = 0//collectionView.bounds.width / 2
        let numberOfSections = dataSource.clipList.count
        for section in (0..<numberOfSections).reversed() {
            let groups = dataSource.groupList[section]
            for i in (0..<groups.count).reversed() {
                let group = groups[i]
                var segments = timeSegments(forClips: Array(group.clips))
                let estimatedLength = cellLength(from: group.startDate!, to: group.endDate!, inSegments: segments)
                let length = max(thumbnailWidth, estimatedLength)
                let ratio = length / estimatedLength
                var groupAttributes = Array<UICollectionViewLayoutAttributes>()
                for clip in group.clips {
                    guard let index = dataSource.indexForClip(clip) else { continue }
                    let itemLength = cellLength(from: clip.startDate, to: clip.endDate, inSegments: segments) * ratio
                    let offset = cellLength(from: group.startDate!, to: clip.startDate, inSegments: segments) * ratio + xOffset
                    let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: index)
                    itemAttributes.frame = CGRect(x: offset, y: indicatorYOffset, width: itemLength, height:indicatorHeight )
                    itemAttributes.zIndex = clip.videoType.rawValue + 1 // make sure cells appear above thumbnails
                    groupAttributes.append(itemAttributes)
                    // TODO: hide buffered cell
                }
                itemAttributesCache.append(contentsOf: groupAttributes)
                
                var sum: CGFloat = 0
                for (j, segment) in segments.enumerated() {
                    segments[j].length = lengthForDuration(segment.duration, videoType: segment.clip!.videoType) * ratio
                    segments[j].minOffset = xOffset + sum
                    sum += segments[j].length
                    clipSegments.append(segments[j])
                }
                
                let count = dataSource.isLocal ? Int(ceil(length / thumbnailWidth)) : 1
                for j in 0..<count {
                    let index = IndexPath(arrayLiteral: section, i, j)
                    let thumbnailAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryThumbnail, with: index)
                    let thumbnailXOffset = xOffset + CGFloat(j)*thumbnailWidth
                    let width = min(xOffset + length - thumbnailXOffset, thumbnailWidth)
                    thumbnailAttributes.frame = CGRect(x: thumbnailXOffset, y: thumbnailYOffset, width: width, height: thumbnailHeight)
                    thumbnailAttributesCache.append(thumbnailAttributes)
                    let thumbnail = addThumbnail(thumbnailAttributes: thumbnailAttributes, groupSegments: segments)
                    thumbnail?.isLeft = (j == 0)
                    thumbnail?.isRight = (j == count-1)
                }
                xOffset += length
                
                if i > 0 {
                    xOffset += CameraTimeLineHorizontalLayout.cellSpacing
                }
            }
            if groups.count > 0 {
                xOffset += CameraTimeLineHorizontalLayout.cellSpacing
            }
        }
        
        let liveButtonFrame = CGRect(x: xOffset, y: thumbnailYOffset, width: liveButtonWidth, height: thumbnailHeight)
        liveButtonAttributes.frame = liveButtonFrame
        liveButtonAttributes.zIndex = 10
        contentWidth = xOffset + liveButtonWidth / 2
        
        clipSegments.sort(by: {$0.from < $1.from})
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemAttributes = itemAttributesCache.filter {
            $0.frame.intersects(rect)
        }
        let thumbnailAttributes = thumbnailAttributesCache.filter {
            $0.frame.intersects(rect)
        }
        let attributes = itemAttributes + thumbnailAttributes
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributesCache.first {
            $0.indexPath == indexPath
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        switch elementKind {
        case CameraTimeLineLayout.supplementaryLiveButton:
            let attributes = liveButtonAttributes.copy() as! UICollectionViewLayoutAttributes
            let sticky = collectionView.contentOffset.x + collectionViewBoundsSize.width - liveButtonWidth
            if sticky < attributes.frame.minX {
                var frame = attributes.frame
                frame.origin.x = sticky
                attributes.frame = frame
            }
            return attributes
        case CameraTimeLineLayout.supplementaryThumbnail:
            return thumbnailAttributesCache.first {
                $0.indexPath == indexPath
            }
        default:
            return nil
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionViewBoundsSize != newBounds.size {
            collectionViewBoundsSize = newBounds.size
            invalidateLayout()
            prepare()
            return false
        }
//        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return false
    }
    
//    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
//        let context = super.invalidationContext(forBoundsChange: newBounds)
//        context.invalidateSupplementaryElements(ofKind: CameraTimeLineLayout.supplementaryLiveButton, at: [IndexPath(item: 0, section: 0)])
//        return context
//    }
    
    func contentOffsetFor(_ date:Date) -> CGFloat? {
        for segment in clipSegments {
            if segment.to < date {
                continue
            }
            if segment.from > date {
                return segment.minOffset // TODO: move to segment method
            }
            if segment.from <= date && date <= segment.to {
                return segment.offset(forTimeOffset: date.timeIntervalSince(segment.from))
            }
        }
        return nil
    }
    
    func indexAndTimeAndSegmentAt(_ offset: CGFloat)-> (IndexPath?, TimeInterval, HNClipSegment?) {
        for (i, segment) in clipSegments.enumerated() {
            if segment.maxOffset <= offset + 0.01 { // approximately equal for float, offset is higher than current segment, continue to check higher segment
                continue
            }
            if segment.minOffset > offset + 0.01 { // offset is lower than current segment
                let index = dataSource!.indexForClip(segment.clip!)
                if i == 0 {
                    var seg = HNClipSegment(from: Date(timeIntervalSince1970: 0), to: segment.from, clip: nil, fromBigEnd: false)
                    seg.minOffset = 0
                    seg.length = collectionViewBoundsSize.width / 2
                    return (index, -1, seg)
                }
                let lastSegment = clipSegments[i-1]
                var seg = HNClipSegment(from: lastSegment.to, to: segment.from, clip: nil, fromBigEnd: false)
                seg.length = segment.minOffset - lastSegment.maxOffset
                seg.minOffset = lastSegment.maxOffset
                return (index, -1, seg)
            }
            // offet is crossing current segment
            // segment.minOffset - 0.01 <= offset < segment.maxOffset - 0.01
            let time = max(0, segment.timeOffset(at: offset)) + segment.from.timeIntervalSince(segment.clip!.startDate)
            let index = dataSource!.indexForClip(segment.clip!)
            return (index, time, segment)
        }
        if isCrossingLiveButton(offset) {
            return (nil, 0, nil)
        } else {
            if let from = clipSegments.last?.to, let maxY = clipSegments.last?.maxOffset {
                var seg = HNClipSegment(from: from, to: Date(), clip: nil, fromBigEnd: false)
                seg.minOffset = maxY
                seg.length =  CameraTimeLineHorizontalLayout.cellSpacing
                return (nil, -1, seg)
            } else {
                return (nil, -1, nil)
            }
        }
    }
    
    func isCrossingLiveButton(_ offset: CGFloat) -> Bool {
        if liveButtonAttributes.frame.width == 0 {
            liveButtonAttributes.frame = CGRect(x:  -liveButtonWidth * 0.5, y: thumbnailYOffset, width:  liveButtonWidth, height: thumbnailHeight)
        }
        return liveButtonAttributes.frame.minX <= offset && offset <= liveButtonAttributes.frame.maxX
    }
    
    func frameForLive() -> CGRect {
        return liveButtonAttributes.frame
    }
    
    func thumbnail(atIndex index: IndexPath) -> HNThumbnail? {
        return thumbnailMap[index]
    }
    
    func addThumbnail(thumbnailAttributes: UICollectionViewLayoutAttributes, groupSegments:Array<HNClipSegment>) -> HNThumbnail? {
        let at = thumbnailAttributes.frame.minX
        for segment in groupSegments {
            if at >= segment.minOffset && at < segment.maxOffset {
                let clip = segment.clip!
                let time: TimeInterval = segment.timeOffset(at: at) + segment.from.timeIntervalSince(clip.startDate)
                let thumbnail = HNThumbnail(thumbnailIndex:thumbnailAttributes.indexPath, clip: clip, time: time)
                thumbnailMap[thumbnailAttributes.indexPath] = thumbnail
                return thumbnail
            }
        }
        return nil
    }
    
    private func timeSegments(forClips clips: Array<HNClip>) -> Array<HNClipSegment>{
        var timePoints = Set<Date>()
        for clip in clips {
            timePoints.insert(clip.startDate)
            timePoints.insert(clip.endDate)
        }
        let sortedTimePoints = Array(timePoints).sorted()
        var segments = Array<HNClipSegment>()
        for i in 1..<sortedTimePoints.count {
            segments.append(HNClipSegment(from: sortedTimePoints[i-1], to: sortedTimePoints[i], clip: nil, fromBigEnd: false))
        }
        
        let clips = clips.sorted(by: {$0.videoType.rawValue < $1.videoType.rawValue || ($0.videoType.rawValue == $1.videoType.rawValue)&&($0.startDate <= $1.startDate)})
        for clip in clips {
            for (index, segment) in segments.enumerated() {
                if segment.from >= clip.startDate && segment.to <= clip.endDate {
                    segments[index].clip = clip
                }
            }
        }
        var mergedSegments = Array<HNClipSegment>()
        var i = 0
        while i < segments.count {
            var j = i
            while j < segments.count && segments[j].clip === segments[i].clip {
                j += 1
            }
            mergedSegments.append(HNClipSegment(from: segments[i].from, to: segments[j-1].to, clip: segments[i].clip, fromBigEnd: false))
            i = j
        }
        return mergedSegments
    }
    
    private func cellLength(from:Date, to:Date, inSegments segments:Array<HNClipSegment>) -> CGFloat {
        var sum: CGFloat = 0
        for segment in segments {
            if segment.to <= from {
                continue
            }
            let _from = max(from, segment.from)
            let _to = min(to, segment.to)
            if _from < _to {
                sum += lengthForDuration(_to.timeIntervalSince(_from), videoType: segment.clip!.videoType)
            }
        }
        return sum
    }
    
    private func lengthForDuration(_ duraton: TimeInterval, videoType:HNVideoType) ->CGFloat {
        let unit = videoType == .buffered ? bufferedRatio * durationUnit: durationUnit
        return CGFloat(duraton / unit) * thumbnailWidth
    }
}
