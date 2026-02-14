//
//  CameraTimeLineDataSource.swift
//  Acht
//
//  Created by Chester Shen on 7/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNClipGroup {
    var clips: ArraySlice<HNClip>
    var duration: TimeInterval {
        return endDate!.timeIntervalSince(startDate!)
    }
    var startDate: Date?
    var endDate: Date?
    
    init(clips:ArraySlice<HNClip>) {
        self.clips = clips
        startDate = clips.min(by: {$0.startDate < $1.startDate})?.startDate
        endDate = clips.max(by: {$0.endDate < $1.endDate})?.endDate
    }
}

protocol CameraTimeLineDataSourceDelegate: class {
    func listUpdated(_ source: CameraTimeLineDataSource)
    func staticsUpdated(_ source: CameraTimeLineDataSource)
    func clipUpdated(_ source: CameraTimeLineDataSource, clip: HNClip)
    func clipCreated(_ source: CameraTimeLineDataSource, clip: HNClip)
}

class CameraTimeLineDataSource: NSObject {
    var groupList = Array<Array<HNClipGroup>>()
    var clipList = Array<Array<HNClip>>()
    var dateList = Array<Date>()
    var filter: HNVideoOptions?
    var totalCount: Int = 0
    weak var delegate: CameraTimeLineDataSourceDelegate?
    var camera: UnifiedCamera? {
        didSet {
            didSetCamera(from: oldValue, to: camera)
        }
    }
    var isLocal: Bool {
        get {
            return false
        }
    }
    var needDewarp: Bool {
        get {
            return camera?.needDewarp ?? false
        }
    }
    var isFetching: Bool = false

    func reload() {
        // for override
    }
    
    func didSetCamera(from oldValue: UnifiedCamera?, to camera: UnifiedCamera?) {
        // for override
    }
    
    func organizeData(_ clips: [HNClip]) -> (Array<Array<HNClipGroup>>, Array<Array<HNClip>>, Array<Date>) {
//        runtest()
        var groupList = Array<Array<HNClipGroup>>()
        var clipList = Array<Array<HNClip>>()
        var dateList = Array<Date>()
        if clips.count == 0 {
            return (groupList, clipList, dateList)
        }
        
//        let profile_start = Date()
        
        var overlappingFrom = 0
        var earliestClip: HNClip?
        var groups = Array<HNClipGroup>()
        // cluster overlapping clips into groups
        for (currentIndex, clip) in clips.enumerated() {
            if earliestClip == nil || earliestClip!.startDate >= clip.endDate { // non-overlapping
                if earliestClip == nil {
                    earliestClip = clip
                    continue
                }
                let group = HNClipGroup(clips: clips[overlappingFrom..<currentIndex])
                groups.append(group)
                overlappingFrom = currentIndex
                earliestClip = clip
            } else { // overlapping
                if clip.startDate < earliestClip!.startDate {
                    earliestClip = clip
                }
            }
        }
        let group = HNClipGroup(clips: clips[overlappingFrom...])
        groups.append(group)
//        Log.debug("Generate Groups within \(-profile_start.timeIntervalSinceNow)")
        // organize groups by date
        for group in groups {
            guard let endDate = group.endDate, let startDate = group.startDate else { continue }
            let lastDate = dateList.last
            var section: Int!
            if lastDate == nil || startDate < lastDate! {
                var thisDate: Date!

                if lastDate == nil || endDate < lastDate! {
                    thisDate = Calendar.current.startOfDay(for: endDate)
                    section = groupList.count // end date is in next section
                } else {
                    thisDate = lastDate!.adjust(.day, offset: -1)
                    section = groupList.count - 1 // end date in current section
                }

                while thisDate >= startDate || (Calendar.current.isDate(thisDate, inSameDayAs: startDate)) {
                    dateList.append(thisDate)
                    groupList.append([])
                    clipList.append([])
                    thisDate = thisDate.adjust(.day, offset: -1)
                }
            } else {
                section = groupList.count - 1
            }

            groupList[section].append(group)
        }
        
        // insert today if not existed
        let today = Calendar.current.startOfDay(for: Date())
        var i = 0
        for date in dateList {
//            if date.compare(.isSameDay(today)) {
            if Calendar.current.isDate(date, inSameDayAs: today) {
                i = -1
                break
            } else if date < today {
                break
            }
            i += 1
        }
        if i >= 0 {
            dateList.insert(today, at: i)
            groupList.insert([], at: i)
            clipList.insert([], at: i)
        }
//        Log.debug("Organize Groups within \(-profile_start.timeIntervalSinceNow)")
        // organize clips by date
        var lastSection: Int? = 0
        var lastDate: Date? = nil
        for clip in clips {
            var section: Int?
//            if let date = lastDate, date.compare(.isSameDay(clip.endDate)) {
            if let date = lastDate, Calendar.current.isDate(date, inSameDayAs: clip.endDate) {
                section = lastSection
            } else {
                section = sectionFor(date: clip.endDate, in: dateList)
            }
            clipList[section!].append(clip)
            lastSection = section
            lastDate = clip.endDate
        }
        //Log.debug("Organize Clips within \(-profile_start.timeIntervalSinceNow)")
        return (groupList, clipList, dateList)
    }
    
    func clearData() {
        groupList.removeAll()
        clipList.removeAll()
        dateList.removeAll()
    }
    
    func removeClip(_ clip: HNClip) {
        // to override
    }
    
    func clipWithIndex(_ indexPath : IndexPath) -> HNClip? {
        if clipList.count <= indexPath.section {
            return nil
        }
        if clipList[indexPath.section].count <= indexPath.item {
            return nil
        }
        return clipList[indexPath.section][indexPath.item]
    }
    
    func indexForClip(_ clip:HNClip) -> IndexPath? {
        guard let section = sectionFor(date: clip.endDate) else { return nil }
        for (item, _clip) in clipList[section].enumerated() {
            if _clip == clip {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }
    
    func countOf(section: Int) -> Int {
        // for override
        return 0
    }
    
    func sectionFor(date: Date, in dateList:[Date]?=nil) -> Int? {
        let dates = dateList ?? self.dateList
        var r = dates.count
        var l = 0
        while l < r {
            let m = (l + r) / 2
            let thisDate = dates[m]
//            if thisDate.compare(.isSameDay(date)) {
            if Calendar.current.isDate(thisDate, inSameDayAs: date) {
                return m
            }
            if thisDate > date {
                l = m + 1
            } else {
                r = m
            }
        }
        return nil
    }
}
