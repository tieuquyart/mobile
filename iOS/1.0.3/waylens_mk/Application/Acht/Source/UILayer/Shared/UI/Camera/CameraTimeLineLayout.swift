//
//  CameraTimeLineLayout.swift
//  Acht
//
//  Created by Chester Shen on 7/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol TimeLineCollectionViewDelegate: UICollectionViewDelegate {
    func layoutDidPrepare()
}

struct HNClipSegment {
    let fromBigEnd: Bool
    var from: Date
    var to: Date
    var duration: TimeInterval {
        return to.timeIntervalSince(from)
    }
    var clip: HNClip?
    var length: CGFloat = 0
    var minOffset: CGFloat = 0
    var maxOffset: CGFloat {
        return minOffset + length
    }
    init(from: Date, to: Date, clip: HNClip?, fromBigEnd: Bool=true) {
        self.from = from
        self.to = to
        self.clip = clip
        self.fromBigEnd = fromBigEnd
    }
    
    func timeOffset(at offset: CGFloat) -> TimeInterval {
        let distance = fromBigEnd ? (maxOffset - offset) : (offset - minOffset)
        return Double(distance/length) * duration
    }
    
    func offset(forTimeOffset timeOffset: TimeInterval) -> CGFloat {
        let distance = CGFloat(timeOffset/duration)*length
        return fromBigEnd ? (maxOffset - distance) : (minOffset + distance)
    }

    /*
    static func == (lhs: HNClipSegment, rhs: HNClipSegment) -> Bool {
        if lhs.from == rhs.from, lhs.to == rhs.to, lhs.clip == rhs.clip, lhs.fromBigEnd == rhs.fromBigEnd {
            return true
        } else {
            return false
        }
    }
    */
}

extension CGRect {
    var shorterEdge: CGFloat {
        return min(width, height)
    }
    
    var longerEdge: CGFloat {
        return max(width, height)
    }
}

class CameraTimeLineLayout: UICollectionViewLayout {
    class var defaultThumbnailRightSpace: CGFloat {
        return UIScreen.main.bounds.shorterEdge > 700 ? 40 : 20
    }
    
    var dataSource: CameraTimeLineDataSource? {
        didSet {
            if dataSource != oldValue {
                invalidateLayout()
            }
        }
    }
    let targetWidth: CGFloat = UIScreen.main.bounds.shorterEdge
    static let cellSpacing:CGFloat = 20
    static var sectionHeaderHeight: CGFloat {
        return UIScreen.main.bounds.shorterEdge > 700 ? 50 : 36
    }
    var headerWidth: CGFloat {
        return UIScreen.main.bounds.shorterEdge > 700 ? 120 : 85
    }
    let headerSpacing: CGFloat = 24
    var thumbnailRightSpace: CGFloat = CameraTimeLineLayout.defaultThumbnailRightSpace
    var thumbnailWidth: CGFloat {
        return UIScreen.main.bounds.shorterEdge > 700 ? 160 : 100
    }
    var thumbnailHeight:CGFloat {
        return UIScreen.main.bounds.shorterEdge > 700 ? 90 : 56
    }
    static let liveButtonWidth: CGFloat = 80
    static let liveButtonHeight: CGFloat = 20
    var contentHeight:CGFloat = 0
    var isHeaderEnabled: Bool = true
    static let itemCellID = "CameraTimeLineCell"
    static let supplementaryHeader = "CameraTimeLineHeaderView"
    static let supplementaryLiveButton = "CameraTimeLineLiveButton"
    static let supplementaryThumbnail = "CameraTimeLineThumbnail"
    static let supplementaryFooter = "CameraTimeLineFooter"
    var durationUnit: TimeInterval = 30
    var bufferedRatio = 8.0
    var regenerateThumbnail = true
    
    private var itemAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    private var headerAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    private var thumbnailAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    private var liveButtonAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryLiveButton, with: IndexPath(item: 0, section: 0))
    private var footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryFooter, with: IndexPath(item: 0, section: 0))
    private var clipSegments: Array<HNClipSegment> = []
    private var thumbnailMap = [IndexPath: HNThumbnail]()
    var collectionViewBoundsSize: CGSize = .zero
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: collectionViewBoundsSize.width, height: contentHeight)
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()

        itemAttributesCache.removeAll()
        headerAttributesCache.removeAll()
        if regenerateThumbnail {
            thumbnailAttributesCache.removeAll()
            thumbnailMap.removeAll()
        }
        clipSegments.removeAll()
        calcLayout()
    }
    
    private func calcLayout() {
        guard itemAttributesCache.isEmpty, let collectionView = collectionView, let dataSource = dataSource else { return }
        if collectionViewBoundsSize == .zero {
            collectionViewBoundsSize = collectionView.bounds.size
        }
        guard collectionViewBoundsSize.width == targetWidth else { return }
        var earliestDate: Date?
        let xOffset = collectionViewBoundsSize.width - thumbnailWidth - thumbnailRightSpace
        liveButtonAttributes.frame = frameForLive()
        var yOffset: CGFloat = 0
        let contentWidth = collectionViewBoundsSize.width
        let numberOfSections = dataSource.clipList.count
        for section in 0 ..< numberOfSections {
            let date = dataSource.dateList[section]

            if earliestDate == nil || !(Calendar.current.isDate(earliestDate!, inSameDayAs: date)) && earliestDate! > date {
                earliestDate = date
                if isHeaderEnabled {
                    if headerAttributesCache.count > 0 {
                        yOffset += headerSpacing
                    }
                    let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryHeader, with: IndexPath(item: 0, section: section))
                    headerAttributes.frame = CGRect(x: 0, y: yOffset, width: headerWidth, height: CameraTimeLineLayout.sectionHeaderHeight)
                    headerAttributes.zIndex = 10
                    headerAttributesCache.append(headerAttributes)
                    yOffset += CameraTimeLineLayout.sectionHeaderHeight + headerSpacing
                }
            } else {
                yOffset += CameraTimeLineLayout.cellSpacing
            }
            
            let groups = dataSource.groupList[section]
            for i in 0..<groups.count {
                let group = groups[i]
                if i > 0 {
                    yOffset += CameraTimeLineLayout.cellSpacing
                }
                var segments = timeSegments(forClips: Array(group.clips))
                let estimatedHeight = cellHeight(from: group.startDate!, to: group.endDate!, inSegments: segments)
                let height = max(thumbnailHeight, estimatedHeight)
                let ratio = height / estimatedHeight
                var groupAttributes = Array<UICollectionViewLayoutAttributes>()
                for clip in group.clips {
                    guard let index = dataSource.indexForClip(clip) else { continue }
                    let itemHeight = cellHeight(from: clip.startDate, to: clip.endDate, inSegments: segments) * ratio
                    let offset = cellHeight(from: clip.endDate, to: group.endDate!, inSegments: segments) * ratio + yOffset
                    let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: index)
                    itemAttributes.frame = CGRect(x: 0, y: offset, width: contentWidth, height: itemHeight)
                    itemAttributes.zIndex = clip.videoType.rawValue + 1 // make sure cells appear above thumbnails
                    groupAttributes.append(itemAttributes)
                }
                itemAttributesCache.append(contentsOf: groupAttributes)
                
                var sum: CGFloat = 0
                for (j, segment) in segments.enumerated().reversed() {
                    guard let clip = segment.clip else {
                        continue
                    }
                    segments[j].length = heightForDuration(segment.duration, videoType: clip.videoType) * ratio
                    segments[j].minOffset = yOffset + sum
                    sum += segments[j].length
                    clipSegments.append(segments[j])
                    var thisDate = earliestDate!

                    while (!Calendar.current.isDate(segment.from, inSameDayAs: thisDate) && segment.from < thisDate) { // current segment is crossing date
                        thisDate = thisDate.adjust(.day, offset: -1).dateFor(.endOfDay)
                        earliestDate = thisDate
                        let thisOffset = segments[j].offset(forTimeOffset: thisDate.timeIntervalSince(segments[j].from))
                        if isHeaderEnabled, let thisSection = dataSource.sectionFor(date: thisDate) {
                            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryHeader, with: IndexPath(item: 0, section: thisSection))
                            headerAttributes.frame = CGRect(x: 0, y: thisOffset, width: headerWidth, height: CameraTimeLineLayout.sectionHeaderHeight)
                            headerAttributes.zIndex = 10
                            headerAttributesCache.append(headerAttributes)
                        }
                    }
                }
                yOffset += height
                
                if regenerateThumbnail {
                    let count = dataSource.isLocal ? Int(ceil(height / thumbnailHeight)) : 1
                    for j in 0..<count {
                        let index = IndexPath(arrayLiteral: section, i, j)
                        let thumbnailAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryThumbnail, with: index)
                        let y = max(yOffset - CGFloat(j+1)*thumbnailHeight, yOffset-height)
                        thumbnailAttributes.frame = CGRect(x: xOffset, y: y, width: thumbnailWidth, height: yOffset - CGFloat(j)*thumbnailHeight - y)
                        thumbnailAttributesCache.append(thumbnailAttributes)
                        let thumbnail = addThumbnail(thumbnailAttributes: thumbnailAttributes, groupSegments: segments)
                        thumbnail?.isBottom = (j == 0)
                        thumbnail?.isTop = (j == count-1)
                    }
                } else {
                    let thumbnails = thumbnailAttributesCache.filter( {$0.indexPath[0] == section && $0.indexPath[1] == i})
                    for (j, attributes) in thumbnails.enumerated() {
                        guard let thumbnail = thumbnailMap[attributes.indexPath] else { continue }
                        let bottomOffset = cellHeight(from: group.startDate!, to: group.startDate!.addingTimeInterval(thumbnail.time), inSegments: segments)
                        let y = max(yOffset - bottomOffset - thumbnailHeight, yOffset-height)
                        thumbnails[j].frame = CGRect(x: xOffset, y: y, width: thumbnailWidth, height: yOffset - bottomOffset - y)
                    }
                }
            }
        }
        if isHeaderEnabled {
            let footerHeight = collectionViewBoundsSize.height - CameraTimeLineLayout.sectionHeaderHeight
            footerAttributes.frame = CGRect(x: 0, y: yOffset, width: contentWidth, height: footerHeight)
            yOffset += footerHeight
        }
        contentHeight = yOffset
        clipSegments.sort(by: {$0.from < $1.from})
    }
    
    override func prepare() {
        super.prepare()

        calcLayout()
        (collectionView?.delegate as? TimeLineCollectionViewDelegate)?.layoutDidPrepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let dataSource = dataSource else { return nil }
        let itemAttributes = itemAttributesCache.filter {
            $0.frame.intersects(rect)
        }
        let thumbnailAttributes = thumbnailAttributesCache.filter {
            $0.frame.intersects(rect)
        }
        var headerAttributes: Array<UICollectionViewLayoutAttributes> = []
        if isHeaderEnabled {
            let numberOfSections = dataSource.clipList.count
            for section in 0..<numberOfSections {
                guard let attributes = layoutAttributesForSupplementaryView(ofKind: CameraTimeLineLayout.supplementaryHeader, at: IndexPath(item:0, section: section)) else { continue }
                if attributes.frame.intersects(rect) {
                    headerAttributes.append(attributes)
                }
            }
        }
        var attributes = itemAttributes + thumbnailAttributes + headerAttributes
        if isHeaderEnabled && liveButtonAttributes.frame.intersects(rect) {
            attributes.append(liveButtonAttributes)
        }
        if isHeaderEnabled && footerAttributes.frame.intersects(rect) {
            attributes.append(footerAttributes)
        }

        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributesCache.first {
            $0.indexPath == indexPath
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case CameraTimeLineLayout.supplementaryHeader:
            if !isHeaderEnabled {
                return nil
            }
            let i = headerAttributesCache.firstIndex {
                $0.indexPath == indexPath
            }
            guard let index = i else { return nil }
            let currentAttribute = headerAttributesCache[index].copy() as! UICollectionViewLayoutAttributes
            let offset = collectionView!.contentOffset.y
            let sectionTop = currentAttribute.frame.minY
            if offset > sectionTop {
                var y : CGFloat
                if index == headerAttributesCache.count - 1 {
                    y = offset
                } else {
                    let sectionBottom = headerAttributesCache[index+1].frame.minY
                    if sectionBottom - CameraTimeLineLayout.sectionHeaderHeight > offset {
                        y = offset
                    } else {
                        y = sectionBottom - CameraTimeLineLayout.sectionHeaderHeight
                    }
                }
                var frame = currentAttribute.frame
                frame.origin.y = y
                currentAttribute.frame = frame
            }
            return currentAttribute
        case CameraTimeLineLayout.supplementaryLiveButton:
            return liveButtonAttributes
        case CameraTimeLineLayout.supplementaryThumbnail:
            return thumbnailAttributesCache.first {
                $0.indexPath == indexPath
            }
        case CameraTimeLineLayout.supplementaryFooter:
            return footerAttributes
        default:
            return nil
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.size != collectionViewBoundsSize {
            collectionViewBoundsSize = newBounds.size
            invalidateLayout()
            prepare()
            return false
        }
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return false
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard isHeaderEnabled else { return context }
        var toInvalidate = [IndexPath]()
        if let headers = dataSource?.clipList.count {
            for section in 0..<headers {
                let index = IndexPath(item:0, section: section)
                toInvalidate.append(index)
    //            guard let attributes = layoutAttributesForSupplementaryView(ofKind: CameraTimeLineLayout.supplementaryHeader, at: index) else { continue }
    //            let originalAttributes = headerAttributesCache.first {
    //                $0.indexPath == index
    //            }
    //            if originalAttributes?.frame != attributes.frame {
    ////            if attributes.frame.intersects(newBounds) {
    //                toInvalidate.append(attributes.indexPath)
    //            }
            }
        }
        context.invalidateSupplementaryElements(ofKind: CameraTimeLineLayout.supplementaryHeader, at: toInvalidate)
        return context
    }
    
    func indexPathForNearestElementAbove(_ offset:CGFloat) -> IndexPath? {
        var followingItem: UICollectionViewLayoutAttributes?
        for item in itemAttributesCache {
            if item.frame.maxY < offset && (followingItem == nil || item.frame.maxY>followingItem!.frame.maxY) {
                followingItem = item
            }
        }
        return followingItem?.indexPath
    }
    
    func contentOffsetFor(_ date:Date) -> CGFloat? {
        for segment in clipSegments {
            if segment.to < date {
                continue
            }
            if segment.from > date {
                return segment.maxOffset // return nearest(later) offset
            }
            if segment.from <= date && date <= segment.to {
                return segment.offset(forTimeOffset: date.timeIntervalSince(segment.from))
            }
        }
        return nil
    }
    
    func indexAndTimeAndSegmentAt(_ offset: CGFloat)-> (IndexPath?, TimeInterval, HNClipSegment?) {
        for (i, segment) in clipSegments.enumerated() {
            if segment.minOffset >= offset - 0.01 { // approximately equal for float, offset is higher than current segment, continue to check higher segment
                continue
            }
            if segment.maxOffset < offset - 0.01 { // offset is lower than current segment
                let index = dataSource!.indexForClip(segment.clip!)
                if i == 0 {
                    var seg = HNClipSegment(from: Date(timeIntervalSince1970: 0), to: segment.from, clip: nil)
                    seg.minOffset = segment.maxOffset
                    seg.length = collectionViewBoundsSize.height
                    return (index, -1, seg)
                }
                let lastSegment = clipSegments[i-1]
                var seg = HNClipSegment(from: lastSegment.to, to: segment.from, clip: nil)
                seg.minOffset = segment.maxOffset
                seg.length = lastSegment.minOffset - segment.maxOffset
                return (index, -1, seg)
            }
            // offet is crossing current segment
            // segment.minOffset + 0.01 < offset <= segment.maxOffset + 0.01
            let time = max(0, segment.timeOffset(at: offset)) + segment.from.timeIntervalSince(segment.clip!.startDate)
            let index = dataSource!.indexForClip(segment.clip!)
            return (index, time, segment)
        }
        if isCrossingLiveButton(offset) {
            return (nil, 0, nil)
        } else {
            if let from = clipSegments.last?.to, let maxY = clipSegments.last?.minOffset {
                var seg = HNClipSegment(from: from, to: Date(), clip: nil)
                seg.minOffset = CameraTimeLineLayout.sectionHeaderHeight + 0.5 * CameraTimeLineLayout.liveButtonHeight
                seg.length = maxY - seg.minOffset
                return (nil, -1, seg)
            } else {
                return (nil, -1, nil)
            }
        }
    }
    
    func isCrossingLiveButton(_ offset: CGFloat) -> Bool {
        if liveButtonAttributes.frame.height == 0 {
            liveButtonAttributes.frame = frameForLive()
        }
        return liveButtonAttributes.frame.minY <= offset && offset <= liveButtonAttributes.frame.maxY
    }
    
    func frameForLive() ->CGRect {
        let size = CGSize(width: CameraTimeLineLayout.liveButtonWidth, height: CameraTimeLineLayout.liveButtonHeight)
        let xOffset = collectionViewBoundsSize.width / 2 - size.width / 2
        return CGRect(x: xOffset, y: CameraTimeLineLayout.sectionHeaderHeight - 0.5 * size.height, width: size.width, height: size.height)
    }
    
    func thumbnail(atIndex index: IndexPath) -> HNThumbnail? {
        return thumbnailMap[index]
    }
    
    func addThumbnail(thumbnailAttributes: UICollectionViewLayoutAttributes, groupSegments:Array<HNClipSegment>) -> HNThumbnail? {
        let at = thumbnailAttributes.frame.maxY
        for segment in groupSegments {
            if at > segment.minOffset && at <= segment.maxOffset {
                let clip = segment.clip!
                let time: TimeInterval = segment.timeOffset(at: at) + segment.from.timeIntervalSince(clip.startDate)
                let thumbnail = HNThumbnail(thumbnailIndex:thumbnailAttributes.indexPath, clip: clip, time: time)
                thumbnailMap[thumbnailAttributes.indexPath] = thumbnail
                return thumbnail
            }
        }
        return nil
    }
}

extension CameraTimeLineLayout {
    fileprivate func timeSegments(forClips clips:Array<HNClip>) -> Array<HNClipSegment>{
        var timePoints = Set<Date>()
        for clip in clips {
            timePoints.insert(clip.startDate)
            timePoints.insert(clip.endDate)
        }
        let sortedTimePoints = Array(timePoints).sorted()
        var segments = Array<HNClipSegment>()
        for i in 1..<sortedTimePoints.count {
            segments.append(HNClipSegment(from: sortedTimePoints[i-1], to: sortedTimePoints[i], clip: nil))
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
            mergedSegments.append(HNClipSegment(from: segments[i].from, to: segments[j-1].to, clip: segments[i].clip))
            i = j
        }
        return mergedSegments
    }
    
    fileprivate func cellHeight(from:Date, to:Date, inSegments segments:Array<HNClipSegment>) -> CGFloat {
        var sum: CGFloat = 0
        for segment in segments {
            guard let clip = segment.clip, segment.to > from else {
                continue
            }
            let _from = max(from, segment.from)
            let _to = min(to, segment.to)
            if _from < _to {
                sum += heightForDuration(_to.timeIntervalSince(_from), videoType: clip.videoType)
            }
        }
        return sum
    }

    func heightForDuration(_ duraton: TimeInterval, videoType:HNVideoType) ->CGFloat {
        var unit = videoType == .buffered ? bufferedRatio * durationUnit: durationUnit
        if videoType.isDMS || videoType.isADAS {
            unit = durationUnit / 3.0
        }
        return CGFloat(duraton / unit) * thumbnailHeight
    }
}
