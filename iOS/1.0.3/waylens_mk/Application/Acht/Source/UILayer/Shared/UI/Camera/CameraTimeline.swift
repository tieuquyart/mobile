//
//  CameraTimeline.swift
//  Acht
//
//  Created by Chester Shen on 3/13/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation
import WaylensPiedPiper


protocol CameraTimelineDelegate: class {
    func timelineIsCloseToEnd(_ timeline: CameraTimeline)
    func timelineDidScroll(_ timeline: CameraTimeline)
    func timeline(_ timeline: CameraTimeline, didChangeScrollModeFrom oldMode: CameraTimelineScrollMode, to newMode: CameraTimelineScrollMode)
    func timelineWillGoLive(_ timeline: CameraTimeline)
    func timelineDidPrepareLayout(_ timeline: CameraTimeline)
    func timeline(_ timeline: CameraTimeline, didUnselectItemAt indexPath: IndexPath)
    func timeline(_ timeline: CameraTimeline, didSelectItemAt indexPath: IndexPath)
    func timelineDidTapFooterButton(_ timeline: CameraTimeline)
}

protocol CameraTimeline: class {
    var collectionView: UICollectionView! { get }
    var lineOffset: CGFloat { get }
    var isInLivePositon: Bool { get }
    var dataSource: CameraTimeLineDataSource! { get set }
    var scrollMode: CameraTimelineScrollMode { get set }
    var delegate: CameraTimelineDelegate? { get set }
    func refreshUI()
    func reloadData()
    func isCrossingLiveButton() -> Bool
    func scrollToItem(at: IndexPath, animated:Bool)
    func scrollToLive(animated:Bool)
    func scrollTo(time: Date)
    func updateTime(_ time:Date?, timeString:String?)
    func endOffsetForItem(at: IndexPath) -> CGFloat?
    func indexInfo(at: CGFloat) -> (IndexPath?, TimeInterval, HNClipSegment?)
    func currentIndexInfo() -> (IndexPath?, TimeInterval, HNClipSegment?)
    func setLineOffset(_ offset:CGFloat, animated:Bool)
    // optional
    func cancelSelection()
}

extension CameraTimeline {
    func cancelSelection() {}
    func scrollTo(offset:CGFloat, animated:Bool) {
        if abs(offset - lineOffset) < 1 {
            setLineOffset(offset, animated: false)
            scrollMode = .idle
            delegate?.timelineDidScroll(self)
        } else {
            setLineOffset(offset, animated: animated)
        }
    }
}

struct CameraTimelinePosition {
    var isLive: Bool = false
    var date: Date?
}

class HNThumbnail {
    var clip: HNClip?
    let thumbnailIndex: IndexPath
    let time: TimeInterval
    var isTop: Bool = false
    var isBottom: Bool = false
    var isLeft: Bool = false
    var isRight: Bool = false
    var pts: Double? {
        if let rawClip = clip?.rawClip { // fetch thumbnail after 5 secs
            return rawClip.startTime +  max( min(rawClip.duration - 1, 5), time)
        }
        return nil
    }
    var image: Future<UIImage>?
    init(thumbnailIndex:IndexPath, clip:HNClip, time: TimeInterval) {
        self.thumbnailIndex = thumbnailIndex
        self.clip = clip
        self.time = time
    }
}
