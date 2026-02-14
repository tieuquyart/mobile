//
//  CTLCloudDataSource.swift
//  Acht
//
//  Created by Chester Shen on 8/25/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class CTLCloudDataSource: CameraTimeLineDataSource {
    private lazy var dataBufferUsingInFetching: [HNClip] = []

    private var dateDict = [String: Int]()
    private var clipNumsDict:[String: Int]?
    private var dateNumsDict:[String: Any]?
    private let batch = 10
    private var hasMore: Bool = true
    private var clips = [HNClip]()
    override var isLocal: Bool {
        get {
            return false
        }
    }
    var shouldFetch: Bool {
        return !isFetching && hasMore
    }
    private var isStatsReady: Bool = false {
        didSet {
            checkReady()
        }
    }
    
    var pendingData: [HNClip]? {
        didSet {
            checkReady()
        }
    }

    var specifiedDateForFetchingData: Date? = nil
    
    override func didSetCamera(from oldValue: UnifiedCamera?, to camera: UnifiedCamera?) {
        if camera != oldValue {
            clearData()
        }
        if camera != nil {
            if let containingDate = specifiedDateForFetchingData {
                fetchData(includeDataGeneratedIn: containingDate)
            } else {
                fetchData()
            }
        }
    }
    
    override var filter: HNVideoOptions? {
        didSet {
            if isStatsReady {
                updateStatics()
            }
        }
    }
    
    func reloadDataAndStatics() {
        isStatsReady = false
        fetchData()
    }
    
    override func reload() {
        fetchData()
    }
    
    override func clearData() {
        clearClips()
        clearStatics()
    }
    
    private func clearClips() {
        super.clearData()
        clips.removeAll()
    }
    
    override func removeClip(_ clip: HNClip) {
        WaylensClientS.shared.deleteClip(clip.clipID) { [weak self] (result) in
            if result.isSuccess {
                self?.reloadDataAndStatics()
            } else {
                HNMessage.showError(message: NSLocalizedString("Failed to delete video", comment: "Failed to delete video"))
            }
        }
    }
    
    func checkReady() {
        if pendingData != nil && isStatsReady {
            processData(clips: pendingData!)
            pendingData = nil
        }
    }
    
    private func sum(dict: [String: Int]) -> Int {
        var s = 0
        for (type, count) in dict {
            if filter == nil || filter!.contains(HNVideoOptions.fromType( HNVideoType.from(string: type))) {
                s += count
            }
        }
        return s
    }
    
    private func dateSum(dict: [String: Any]) -> [String: Int] {
        var dates = [String: Int]()
        for (type, value) in dict {
            if filter == nil || filter!.contains(HNVideoOptions.fromType( HNVideoType.from(string: type))) {
                let typeDict = value as! [String: Int]
                for (day, count) in typeDict {
                    dates[day] = (dates[day] ?? 0) + count
                }
            }
        }
        return dates
    }
    
    func clearStatics() {
        totalCount = 0
        clipNumsDict = nil
        dateNumsDict = nil
        isStatsReady = false
    }
    
    func updateStatics() {
        guard clipNumsDict != nil, dateNumsDict != nil else { return }
        totalCount = sum(dict: clipNumsDict!)
        dateDict = dateSum(dict: dateNumsDict!)
        delegate?.staticsUpdated(self)
    }
    
    func getStats() {
        if camera != nil {
            WaylensClientS.shared.fetchClipsStats(camera!.sn, completion: { [weak self] (result) in
                guard let this = self else { return }

                #if FLEET
                if result.isSuccess {
                    this.totalCount = (result.value?["eventTotalCount"] as? Int) ?? 0
                    this.delegate?.staticsUpdated(this)
                    this.isStatsReady = true
                } else {
                    this.isFetching = false
                }
                #else
                if result.isSuccess {
                    this.clipNumsDict = result.value?["clipNums"] as? [String: Int]
                    this.dateNumsDict = result.value?["dateNums"] as? [String: Any]
                    this.updateStatics()
                    this.isStatsReady = true
                } else {
                    this.isFetching = false
                }
                #endif
            })
        }
    }
    
    private func fetchData(more:Bool=false) {
        guard let camera = camera else { return }
        if !(AccountControlManager.shared.isAuthed && camera.ownerUserId == AccountControlManager.shared.keyChainMgr.userID) {
            clearData()
            return
        }
        if isFetching {
            return
        }
        isFetching = true
        if !isStatsReady {
            getStats()
        }
        WaylensClientS.shared.fetchClips(camera.sn, filter: filter, cursor: more ? currentRealCount() : 0, count: batch) { [weak self] (result) in
            self?.isFetching = false
            if result.isSuccess {
                #if FLEET
                self?.hasMore = result.value!["hasMore"] as? Bool ?? false
                let data = (result.value!["events"] as! [[String: Any]]).map({HNClip(dict:$0)})
                #else
                self?.hasMore = result.value!["hasMore"] as! Bool
                let data = (result.value!["clips"] as! [[String: Any]]).map({HNClip(dict:$0)})
                #endif

                if !more {
                    self?.clearClips()
                }
                self?.pendingData = data.filter({$0.duration > 0})
            } else {
                // pass
            }
        }
    }

    private func fetchData(includeDataGeneratedIn specifiedDate: Date, more: Bool = false) {
        guard let camera = camera else {
            return
        }

        if !(AccountControlManager.shared.isAuthed && camera.ownerUserId == AccountControlManager.shared.keyChainMgr.userID) {
            dataBufferUsingInFetching.removeAll()
            clearData()
            return
        }

        if isFetching {
            return
        }

        isFetching = true

        if !isStatsReady {
            getStats()
        }

        WaylensClientS.shared.fetchClips(camera.sn, filter: filter, cursor: more ? dataBufferUsingInFetching.count : 0, count: batch) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.isFetching = false

            if result.isSuccess {
                #if FLEET
                strongSelf.hasMore = result.value!["hasMore"] as? Bool ?? false
                let data = (result.value!["events"] as! [[String: Any]]).map({HNClip(dict:$0)})
                #else
                strongSelf.hasMore = result.value!["hasMore"] as! Bool
                let data = (result.value!["clips"] as! [[String: Any]]).map({HNClip(dict:$0)})
                #endif

                strongSelf.dataBufferUsingInFetching.append(contentsOf: data.filter({$0.duration > 0}))

                func hasFound() -> Bool {
                    return strongSelf.dataBufferUsingInFetching.first(where: {$0.startDate == specifiedDate}) != nil
                }

                func complete() {
                    strongSelf.pendingData = strongSelf.dataBufferUsingInFetching
                    strongSelf.dataBufferUsingInFetching.removeAll()
                    strongSelf.specifiedDateForFetchingData = nil
                }

                if hasFound() {
                    complete()
                } else {
                    if let lastClip = strongSelf.dataBufferUsingInFetching.last, lastClip.startDate.timeIntervalSince1970 < specifiedDate.timeIntervalSince1970 { // earlier than specifiedDate and not found
                        complete()
                    } else if !strongSelf.hasMore {
                        complete()
                    } else {
                        strongSelf.fetchData(includeDataGeneratedIn: specifiedDate, more: true)
                    }
                }
            } else {
                strongSelf.specifiedDateForFetchingData = nil
                strongSelf.dataBufferUsingInFetching.removeAll()
            }
        }
    }
    
    func fetchMoreData() {
        fetchData(more: true)
    }
    
    private func currentRealCount() -> Int {
        var count = 0
        let _clipList = clipList
        for arr in _clipList {
            count += arr.count
        }
        return count
    }
    
    override func countOf(section: Int) -> Int {
        if (section < clipList.count - 1) || (!hasMore && section < clipList.count) {
            return clipList[section].count
        } else if section >= dateList.count {
            return 0
        }
        let date = dateList[section]
        let dateKey = date.toString(format: .isoDate)
        return dateDict[dateKey] ?? 0
    }
    
    private func processData(clips:Array<HNClip>) {
        self.clips.append(contentsOf: clips)
        self.clips.sort(by: {$0.endDate > $1.endDate})
        let (groupList, clipList, dateList) = organizeData(self.clips)
        self.groupList = groupList
        self.clipList = clipList
        self.dateList = dateList
        delegate?.listUpdated(self)
    }
}
