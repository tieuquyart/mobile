//
//  CTLLocalDataSource.swift
//  Acht
//
//  Created by Chester Shen on 8/26/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class CTLLocalDataSource: CameraTimeLineDataSource, WLCameraVDBClipsAgentDelegate {
    private var allClips: [HNClip] = []
    override var isLocal: Bool {
        get {
            return true
        }
    }
    private let listLock = NSLock()
    
    
    override func didSetCamera(from oldValue: UnifiedCamera?, to camera: UnifiedCamera?) {
        oldValue?.local?.clipsAgent.remove(delegate: self)
        if camera != nil {
            camera?.local?.clipsAgent.add(delegate: self)
            reload()
        } else {
            clearData()
        }
    }
    
    var agent: WLCameraVDBClipsAgent? {
        get {
            return camera?.local?.clipsAgent
        }
    }
    
    var dispatchQueue = DispatchQueue(label: "horn.localdatasource.refresh", qos: .background)
//    var operationQueue: OperationQueue
//    var lastOperation: Operation?
        
    override init() {
//        operationQueue = OperationQueue()
//        operationQueue.maxConcurrentOperationCount = 1
//        operationQueue.qualityOfService = .background
    }
    
    override func reload() {
        onClipListLoaded(WLClipListType.bookMark)
    }
    
    private func refresh(all:Bool, completion:(()->Void)?=nil) {
        let clips = currentClips(refreshAll: all)
        totalCount = clips.count
        delegate?.staticsUpdated(self)
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let (groupList, clipList, dateList) = strongSelf.organizeData(clips)
            DispatchQueue.main.async {
                strongSelf.groupList = groupList
                strongSelf.clipList = clipList
                strongSelf.dateList = dateList
                completion?()
            }
        }
    }
    
    override func removeClip(_ clip: HNClip) {
        guard let rawclip = clip.rawClip else { return }
        camera?.local?.vdbClient.removeClip(rawclip.clipID, in: WLVDBDomain(rawValue: UInt32(rawclip.clipType)), with: rawclip.vdbID)
    }
    
    override func countOf(section: Int) -> Int {
        if section < clipList.count {
            return clipList[section].count
        }
        return 0
    }
    
    // MARK:- vdb clips agent delegate
    @objc func onVDBReady(_ isReady: Bool) {
        Log.debug("on VDB Ready: \(isReady)")
        if !isReady {
            clearData()
            delegate?.listUpdated(self)
        }
    }
    
    @objc func onClipListLoaded(_ listType: WLClipListType) {
        Log.debug("on clip list loaded")
        refresh(all: true) { [weak self] in
            if let this = self {
                this.delegate?.listUpdated(this)
            }
        }
    }
    
    @objc func onNewClip(_ clip: WLVDBClip!, to listType: WLClipListType) {
        Log.debug("on new clip, \(clip.clipID), \(clip.eventType.rawValue), \(clip.startDate+clip.startTime), \(clip.duration), \(clip.gmtoff)")

        allClips.append(HNClip(clip))
        refresh(all: false) { [weak self] in
            if let this = self {
                this.delegate?.clipCreated(this, clip: HNClip(clip))
            }
        }
    }
    
    @objc func onRemove(_ clip: WLVDBClip!, from listType: WLClipListType) {
        Log.debug("on clip removed")
        allClips.removeAll { (_clip) -> Bool in
            _clip.rawClip == clip
        }
        refresh(all: false) { [weak self] in
            if let this = self {
                this.delegate?.listUpdated(this)
            }
        }
    }
    
    @objc func onUpdate(_ clip: WLVDBClip?, from listType: WLClipListType) {
        guard let clip = clip else { return }
        //Log.debug("on clip updated, \(clip.clipID), \(clip.eventType.rawValue), \(clip.startDate+clip.startTime), \(clip.duration), \(clip.gmtoff)")
        if let updatedClip = allClips.first(where: { $0.rawClip == clip }) {
            updatedClip.updateRawClip(clip)
            if updatedClip.videoType.isContained(by: filter) {
                refresh(all: false) { [weak self] in
                    if let this = self {
                        this.delegate?.clipUpdated(this, clip: HNClip(clip))
                    }
                }
            }
        }
    }
    
    func getLocation(forClip clip: HNClip, completion: (()->Void)?) {
        camera?.local?.getLocation(forClip: clip, completion: { (_) in
            completion?()
        })
    }
    
    // MARK:- Private
    private func convertRawClips(_ rawClips: Array<WLVDBClip>) -> Array<HNClip> {
        var clips: Array<HNClip> = []
        for rawClip in rawClips {
            let clip = HNClip(rawClip)
            clips.append(clip)
        }
        return clips
    }
    
    private func sortClips(_ clips: inout [HNClip]) {
        clips.sort(by: {$0.endDate > $1.endDate || $0.endDate == $1.endDate && $0.duration > $1.duration || $0.endDate == $1.endDate && $0.duration == $1.duration && $0.videoType.rawValue < $1.videoType.rawValue})
    }
    
    private func getAllClips() -> [HNClip] {
        guard let loops = agent?.list(of: WLClipListType.loop), let manuals = agent?.list(of: WLClipListType.manual), let bookmarks = agent?.list(of: WLClipListType.bookMark) else { return [] }
        var converted = convertRawClips(loops + manuals + bookmarks)

        /*
        if UserSetting.shared.debugEnabled, let duration = converted.first(where:{ $0.duration <= 0})?.duration {
            DispatchQueue.main.async {
                HNMessage.showError(message: String(format: NSLocalizedString("Clip duration is %f", comment: "Clip duration is %f"), duration))
            }
        }
        */
        
        sortClips(&converted)
        return converted
    }
    
    private func currentClips(refreshAll:Bool=false) -> [HNClip] {
        if refreshAll {
            allClips = getAllClips()
        }
        var filtered = allClips.filter({ $0.duration > 0 && $0.videoType.isContained(by: filter) })
        sortClips(&filtered)
        return filtered
    }
    
    deinit {
        camera?.local?.clipsAgent.remove(delegate: self)
    }
}
