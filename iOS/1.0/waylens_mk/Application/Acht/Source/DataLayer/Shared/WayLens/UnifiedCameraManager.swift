//
//  UnifiedCameraManager.swift
//  Acht
//
//  Created by Chester Shen on 8/3/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import WaylensFoundation
import WaylensCameraSDK

extension Notification.Name {
    public struct UnifiedCameraManager {
        static let listUpdated = Notification.Name(rawValue: "waylens.acht.notification.name.unifiedcameramanager.listupdated")
        static let localDisconnected = Notification.Name(rawValue: "waylens.acht.notification.name.unifiedcameramanager.localDisconnected")
    }
}

protocol UnifiedCameraManagerDelegate: class {
    func onCameraListUpdated()
    func onCameraUpdated(_ camera: UnifiedCamera)
}

class UnifiedCameraManager: NSObject {
    private var cameraPool = [UnifiedCamera]()

    @objc dynamic weak var current: UnifiedCamera? // add `@objc dynamic` for KVO
    var cameras = [UnifiedCamera]()
    var currentIndex: Int? {
        if current != nil {
            return cameras.firstIndex(of: current!)
        }
        return nil
    }
    weak var delegate: UnifiedCameraManagerDelegate?
    
    static let shared = UnifiedCameraManager()
    var local: UnifiedCamera? {
        return cameras.first { $0.viaWiFi }
    }
    var remoteUpdated: Bool = false
    
    var has4gCamera: Bool {
        return (cameras.first{$0.supports4g} != nil)
    }
    
    private override init() {
        super.init()
        WLBonjourCameraListManager.shared.add(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsUpdated(sender:)), name: Notification.Name.Remote.settingsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChanged(sender:)), name: Notification.Name.Remote.stateChanged, object: nil)
        #if !FLEET
        NotificationCenter.default.addObserver(self, selector: #selector(saveToCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func removeAll() {
        current = nil
        cameraPool.removeAll()
        updateCameraList()
    }
    
    func remove(camera:UnifiedCamera, updateList:Bool=true) {
        if current == camera {
            current = nil
        }
        guard let index = cameraPool.firstIndex(of: camera) else { return }
        cameraPool.remove(at: index)
        if updateList {
            updateCameraList()
        }
    }
    
    func remove(remote: RemoteCamera, updateList:Bool=true) {
        guard let camera = cameraForSN(remote.sn) else { return }
        camera.ownerUserId = ""
        if camera.local != nil {
            delegate?.onCameraUpdated(camera)
        } else {
            remove(camera: camera, updateList:updateList)
        }
    }
    
    func updateRemote() {
        remoteUpdated = false

        if AccountControlManager.shared.isAuthed {
            WaylensClientS.shared.fetchCameraList { [weak self] (result) in
                if result.isSuccess {
                    self?.updateRemote(dicts: result.value?["cameras"] as! [Any])
                    self?.remoteUpdated = true
                    self?.updateCameraList()
                }
            }
        }

    }
    
    @objc func reload() {
        #if !FLEET
        loadFromCache()
        #endif
        updateLocal()
        updateCameraList()
        updateRemote()
    }
    
    @objc func updateCameraList() {
        var newCameras: [UnifiedCamera] = []

        #if FLEET
        newCameras = cameraPool
        #else
        if AccountControlManager.shared.isAuthed, let currentUserId = AccountControlManager.shared.keyChainMgr.userID {
            newCameras = cameraPool.filter({$0.local != nil || $0.ownerUserId == currentUserId})
        } else {
            newCameras = cameraPool.filter({$0.local != nil})
        }
        #endif

        if cameras.isEmpty && newCameras.isEmpty {
            return
        }

        newCameras.sort { (ca, cb) -> Bool in
            if ca.local != nil && cb.local == nil {
                return true
            }
            if ca.local == nil && cb.local != nil {
                return false
            }
            if ca.via4G && !cb.via4G {
                return true
            }
            if !ca.via4G && cb.via4G {
                return false
            }
            if let ta = ca.remote?.lastActiveTime, let tb = cb.remote?.lastActiveTime {
                return ta > tb
            } else if ca.remote?.lastActiveTime != nil {
                return true
            }
            return false
        }

        cameras = newCameras
        delegate?.onCameraListUpdated()
        NotificationCenter.default.post(name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
    }

    #if !FLEET

    private func loadFromCache() {
        if let currentUserId = AccountControlManager.shared.keyChainMgr.userID, let dicts = UserSetting.current.object(key: .cachedCameras) as? [[String: Any]] {
            let cachedCameras = dicts.map({ UnifiedCamera(dict: $0)}).filter({$0.ownerUserId == currentUserId})
            for camera in cachedCameras {
                if cameraPool.first(where: {$0.sn == camera.sn}) == nil {
                    cameraPool.append(camera)
                }
            }
        }
    }

    @objc
    private func saveToCache() {
        // TODO: append new cameras to cache, manage cache by recent connection date etc.
        var dicts = [Any]()
        let currentUserId = AccountControlManager.shared.keyChainMgr.userID
        for camera in cameraPool {
            guard let _ = camera.name else { continue }
            if currentUserId != nil && currentUserId == camera.ownerUserId {
                dicts.append(camera.dictForCache())
            }
        }
        UserSetting.current.set(dicts, forKey: .cachedCameras)
    }

    #endif

    func updateRemote(dicts: [Any]) {
        #if FLEET
        var newSN = [String]()
        for case let dict as [String : Any] in dicts {
            guard let sn = dict["serialNumber"] as? String else { continue }
            newSN.append(sn)

            if let matched = cameraPool.first(where: { $0.sn == sn }) {
                let remote = RemoteCamera(dict: dict)

                if matched.remote != nil {
                    if let mergedDict = matched.remote?.dict.merged(another: dict) {
                        matched.remote?.dict = mergedDict
                    }

                    matched.remote?.update(dict: dict)
                } else {
                    matched.remote = remote
                }
            } else {
                let camera = UnifiedCamera(dict: dict)
                cameraPool.append(camera)
            }
        }
        let copiedPool = Array(cameraPool)
        for camera in copiedPool {
            if let remote = camera.remote, newSN.firstIndex(of: camera.sn) == nil { // removed from current user's account
                remove(remote: remote, updateList: false)
            }
        }
        #else
        guard let currentUserId = AccountControlManager.shared.keyChainMgr.userID else { return }
        var newSN = [String]()
        for case let dict as [String : Any] in dicts {
            guard let sn = dict["sn"] as? String else { continue }
            newSN.append(sn)
            if let matched = cameraPool.first(where: { $0.sn == sn }) {
                let remote = RemoteCamera(dict: dict)
                if matched.remote != nil {
                    if let mergedDict = matched.remote?.dict.merged(another: dict) {
                        matched.remote?.dict = mergedDict
                    }
                    matched.remote?.update(dict: dict)
                } else {
                    matched.remote = remote
                }
                matched.ownerUserId = currentUserId
                if matched.local != nil {
                    reportCamera(matched)
                }
                matched.syncName()
            } else {
                let camera = UnifiedCamera(dict: dict)
                camera.ownerUserId = currentUserId
                cameraPool.append(camera)
            }
        }
        let copiedPool = Array(cameraPool)
        for camera in copiedPool {
            if let remote = camera.remote, camera.ownerUserId == currentUserId && newSN.firstIndex(of: camera.sn) == nil { // removed from current user's account
                remove(remote: remote, updateList: false)
            }
        }
        #endif
    }
    
    func updateLocal() {
        var newSN = [String]()
        let localDevices = WLBonjourCameraListManager.shared.cameraList
        for local in localDevices  {
            if local.sn == nil || (
                (local.productSerie != .horn) &&
                (local.productSerie != .saxhorn) &&
                (local.productSerie != .secureES) &&
                !(local.productSerie == .hachi && UserSetting.shared.debugEnabled == true)
            ) {
                continue
            }
            if let camera = cameraForLocal(local) {
                if camera.local != local {
                    camera.local = local
                    delegate?.onCameraUpdated(camera)
                    #if !FLEET
                    reportCamera(camera)
                    #endif
                }
            } else {
                let camera = UnifiedCamera(local: local, remote: nil)
                cameraPool.append(camera)
            }
            newSN.append(local.sn!)
        }
        let copiedPool = Array(cameraPool)
        for camera in copiedPool {
            if camera.local != nil && newSN.firstIndex(of: camera.sn) == nil { // local camera disconnected
                if camera.remote != nil {
                    camera.local = nil // remove local camera if camera's owned by current user
                } else {
                    remove(camera: camera, updateList: false) // remove camera if camera's not owned
                }
            }
        }
    }
    
    @objc func cameraForLocal(_ local:WLCameraDevice) -> UnifiedCamera? {
        if local.sn == nil { return nil }
        for camera in cameraPool {
            if camera.sn == local.sn {
                return camera
            }
        }
        return nil
    }
    
    func cameraForSN(_ sn:String) -> UnifiedCamera? {
        return cameraPool.first(where: {$0.sn == sn})
    }

    #if !FLEET
    func reportCamera(_ camera: UnifiedCamera) {
        guard let local = camera.local, AccountControlManager.shared.isAuthed else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
            camera.reportICCID(completion: nil)

            WaylensClientS.shared.reportCamera(local.sn!, info: local.dictForReport(), completion: { (result) in
                Log.debug("report camera \(result.isSuccess ? "success" : "failure")")
            })
        }
    }
    #endif
    
    // MARK: - Notifications
    @objc func onStateChanged(sender: Notification) {
        updateRemote()
    }
    
    @objc func onSettingsUpdated(sender: Notification) {
        if let sn = sender.object as? String {
            let camera = cameraForSN(sn)
            camera?.remote?.onSettingsUpdated()
        }
        updateRemote()
    }
        
}

extension UnifiedCameraManager: WLBonjourCameraListManagerDelegate {

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didUpdateCameraList cameraList: [WLCameraDevice]) {
        if cameraList.count > 0 {
            updateLocal()
            updateCameraList()
            #if !FLEET
            saveToCache()
            #endif
        }
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didDisconnectCamera camera: WLCameraDevice) {
        #if !FLEET
        saveToCache()
        #endif
        if let camera = cameraForLocal(camera) {
            if camera.remote != nil {
                camera.remote?.update(dict:camera.toDict()) // merge local states & settings to remote
                camera.local = nil
                delegate?.onCameraUpdated(camera)
            } else {
                remove(camera: camera)
                HNMessage.showInfo(message: String(format: NSLocalizedString("%@ disconnected", comment: "%@ disconnected"), camera.name ?? NSLocalizedString("Camera", comment: "Camera")))
            }
            NotificationCenter.default.post(name: Notification.Name.UnifiedCameraManager.localDisconnected, object: nil)
        }
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didUpdateCamera camera: WLCameraDevice) {
        guard let camera = cameraForLocal(camera) else { return }
        delegate?.onCameraUpdated(camera)
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, camera: WLCameraDevice, didChangeName name: String?) {
        guard let camera = cameraForLocal(camera) else { return }
        delegate?.onCameraUpdated(camera)
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, camera: WLCameraDevice, didEncounterRecError err: Error) {
        Log.error("Camera did encounter record error: \(err._code)")
    }

    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didLiveMark done: Bool) {
        NotificationCenter.default.post(
            name: Notification.Name.Local.liveMark,
            object: self,
            userInfo: [Notification.Name.Local.liveMark: done]
        )
    }

}
