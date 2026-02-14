//
//  CameraTimeLineHorizontalView+Utils.swift
//  Acht
//
//  Created by forkon on 2018/9/3.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

extension HNClip {
    
    func intersects(_ clip2: HNClip) -> Bool {
        return endDate <= clip2.startDate
    }
    
}

extension Array where Element: HNClip {
    
    var continuousClipSections: [[HNClip]] {
        var sections: [[HNClip]] = []
        
        guard !isEmpty else { return sections }
        
        var overlappingFrom: Int = 0
        var earliestClip: HNClip?
        // cluster overlapping clips into groups
        for (currentIndex, clip) in enumerated() {
            if earliestClip == nil || earliestClip!.startDate >= clip.endDate { // non-overlapping
                if earliestClip == nil {
                    earliestClip = clip
                    continue
                }
                
                sections.append(Array(self[overlappingFrom..<currentIndex]))
                overlappingFrom = currentIndex
                earliestClip = clip
            } else { // overlapping
                if clip.startDate < earliestClip!.startDate {
                    earliestClip = clip
                }
            }
        }
        
        sections.append(Array(self[overlappingFrom...]))

        return sections.reversed()
    }
    
    var continuousClipGroups: [HNClipGroup] {
        return continuousClipSections.map{HNClipGroup(clips: ArraySlice($0))}
    }
    
    var clipSegmentSections: [[HNClipSegment]] {
        return continuousClipSections.map{$0.segments}
    }
    
    var segments: [HNClipSegment] {
        var timePoints = Set<Date>()
        for clip in self {
            timePoints.insert(clip.startDate)
            timePoints.insert(clip.endDate)
        }
        
        let sortedTimePoints = Array<Date>(timePoints).sorted()
        var segments = Array<HNClipSegment>()
        for i in 1..<sortedTimePoints.count {
            segments.append(HNClipSegment(from: sortedTimePoints[i-1], to: sortedTimePoints[i], clip: nil))
        }
        
        let clips = sorted(by: {$0.videoType.rawValue < $1.videoType.rawValue || ($0.videoType.rawValue == $1.videoType.rawValue)&&($0.startDate <= $1.startDate)})
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
        
        var subSegments = Array<HNClipSegment>()
        mergedSegments.forEach { (segment) in
            let videoType = segment.clip!.videoType
            let cuttingLength: TimeInterval = (videoType == .buffered ? 200.0 : 20.0)
            var fromDate = segment.from
            
            while fromDate < segment.to {
                var toDate = Date(timeInterval: cuttingLength, since: fromDate)
                
                if toDate > segment.to || (segment.to.timeIntervalSince(toDate) <= cuttingLength / 2) {
                    toDate = segment.to
                }
                subSegments.append(HNClipSegment(from: fromDate, to: toDate, clip: segment.clip))
                fromDate = toDate
            }
        }
        return subSegments
    }
    
    func sortedByDate(inIncreasingOrder: Bool) -> [HNClip] {
        if inIncreasingOrder {
            return sorted{$0.startDate < $1.startDate}
        } else {
            return sorted{$0.startDate > $1.startDate}
        }
    }
    
    func intersects(_ clip: HNClip) -> Bool {
        if isEmpty {
            return true
        } else {
            if let lastEndDate = last?.endDate, lastEndDate >= clip.startDate {
                return true
            } else {
                return false
            }
        }
    }
    
}

extension Array where Element == Array<HNClipSegment> {
    
    func convertTime(_ time: Date?) -> (IndexPath?, Double) {
        if let time = time {
            for (i, section) in enumerated() {
                for (j, segment) in section.enumerated() {
                    if segment.from <= time, segment.to >= time {
                        let progress = time.timeIntervalSince(segment.from) / segment.duration
                        return (IndexPath(item: j, section: i), progress)
                    }
                }
            }
        }
        return (nil, 0.0)
    }

}

extension HNClipSegment {
    
    func time(at percent: Double) -> TimeInterval {
        guard let clip = clip, let rawClip = clip.rawClip else {
            return 0.0
        }
        
        let time: TimeInterval = duration * percent + from.timeIntervalSince(clip.startDate)
        let parking = clip.videoType.isParking
        let pts = rawClip.startTime + (parking ? max(min(rawClip.duration - 1, 5), time) : time)
        return pts
    }
    
}
