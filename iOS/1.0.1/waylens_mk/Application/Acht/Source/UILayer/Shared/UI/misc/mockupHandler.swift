//
//  mockupHandler.swift
//  Acht
//
//  Created by gliu on 6/22/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class debugClipInfo {
    var clipID : Int32
    var type : HNVideoType
    var location : String
    
    init(_ clipid : Int32, t : HNVideoType, loc : String) {
        clipID = clipid
        type = t
        location = loc
    }
    
    init(dict : NSDictionary) {
        self.clipID = dict["clipID"] as! Int32
        self.type = HNVideoType(rawValue: dict["type"] as! Int)!
        self.location = dict["location"] as! String
    }
    
    var dict : NSDictionary {
        get {
            return NSDictionary.init(objects: [self.clipID, self.type.rawValue, location],
                                     forKeys: ["clipID" as NSCopying, "type" as NSCopying, "location" as NSCopying])
        }
    }
    
}

class mockupHandler {
    
    static let shared = mockupHandler()
    
    var opertationClip : Int32
    fileprivate var changedClips : [debugClipInfo]
    fileprivate var alertList : [Int32]

    fileprivate init () {
        opertationClip = 0
        changedClips = []
        alertList = []
        load()
    }

    func tryAddClip(_ clipid : Int32, type : HNVideoType, location : String) {
        for clip in changedClips {
            if clip.clipID == clipid {
                return
            }
        }
        self.updateClip(clipid, type: type, location: location)
    }
    func updateClip(_ clipid : Int32, type : HNVideoType, location : String) {
        var found = false
        for clip in changedClips {
            if clip.clipID == clipid {
                clip.type = type
                clip.location = location
                found = true
                break
            }
        }
        if found == false {
            changedClips.append(debugClipInfo.init(clipid, t: type, loc: location))
        }
        save()
    }
    func addAlertClip(_ clipid : Int32) {
        var found = false
        for clip in alertList {
            if clip == clipid {
                found = true
                break
            }
        }
        if found == false {
            alertList.insert(clipid, at: 0)
        }
        save()
    }
    func removeAlert(clipid : Int32) {
        var index = -1
        for i in 0...alertList.count-1 {
            let clip = alertList[i]
            if clip == clipid {
                index = i
                break
            }
        }
        if index >= 0 {
            alertList.remove(at: index)
            save()
        }
    }
    func numberOfAlertClips() -> Int {
        return alertList.count
    }
    func alertClipAt(index: Int) -> Int32? {
        if index < alertList.count {
            return alertList[index]
        }
        return nil
    }
    func removeAll() {
        changedClips.removeAll()
        alertList.removeAll()
        save()
    }
    func getDebugClip() -> debugClipInfo? {
        if opertationClip == 0 {
            return nil
        }
        return getClip(clipID: opertationClip)
    }
    func getClip(clipID : Int32) -> debugClipInfo? {
        for clip in changedClips {
            if clip.clipID == clipID {
                return clip
            }
        }
        return nil
    }
    
    fileprivate var lock = NSLock()
    fileprivate func save() {
        lock.lock()
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        guard path != nil else {
            lock.unlock()
            return
        }
        
        let dict = NSDictionary.init(objects: [changedClipsDict(), alertList], forKeys: ["changedClips" as NSCopying, "alertList" as NSCopying])
        let file = path!.appending("/mockup.config")
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
            if FileManager.default.fileExists(atPath: file) {
                do {
                    try FileManager.default.removeItem(atPath: file)
                } catch {
                }
            }
            do {
                try data.write(to: URL.init(fileURLWithPath: file))
            } catch {
                NSLog("data write to file failed")
            }
        } catch {
            NSLog("PropertyListSerialization create data failed!")
        }
        lock.unlock()
    }
    fileprivate func changedClipsDict() -> Array<NSDictionary> {
        var arr = Array<NSDictionary>()
        for clip in changedClips {
            arr.append(clip.dict)
        }
        return arr
    }
    fileprivate func load() {
        lock.lock()
        changedClips.removeAll()
        alertList.removeAll()
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        guard path != nil else {
            lock.unlock()
            return
        }
        let file = path!.appending("/mockup.config")
        guard FileManager.default.fileExists(atPath: file) else {
            NSLog("find file " + file + " failed")
            lock.unlock()
            return
        }
        let data = FileManager.default.contents(atPath: file)
        do {
            let dict = try PropertyListSerialization.propertyList(from: data!, options: .mutableContainersAndLeaves, format: nil) as? NSDictionary
            guard dict != nil else {
                NSLog("mockupHandler load() failed")
                lock.unlock()
                return
            }
            let alerts = dict!["alertList"] as! [Int32]
            let changelist = dict!["changedClips"] as! [NSDictionary]
            for info in changelist {
                changedClips.append(debugClipInfo.init(dict: info))
            }
            for info in alerts {
                alertList.append(info)
            }
        } catch {}
        lock.unlock()
    }
}
