//
//  VideoDownloadManager.swift
//  Acht
//
//  Created by Chester Shen on 9/22/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import Photos
import WaylensFoundation
import WaylensCameraSDK

enum VideoDownloadError: Error {
    case alreadyInQueue
    case notEnoughSpace(Int64)
}

// Download videos from camera or web server.
class VideoDownloadManager: NSObject {
    struct DownloadTask {
        let clip: BasicClip
        let url: String
        let bytes: Int64
        var duration: TimeInterval {
            return clip.duration
        }
        let toLibrary: Bool
        var status: DownloadTaskStatus = .waiting
        var id: String {
            return clip.identifier
        }
        var savedClip: SavedClip?
        let isLocal: Bool
        var streamIndex = Int32(0)
        init(url: String, local: Bool, clip: BasicClip, bytes: Int64=0, toLibrary: Bool=false) {
            self.url = url
            self.bytes = bytes
            self.isLocal = local
            self.clip = clip
            self.toLibrary = toLibrary
        }
    }
    
    enum DownloadTaskStatus {
        case waiting
        case downloading(Double)
        case completed
        case failed
        
        var progress: Double {
            switch self {
            case .waiting:
                return 0
            case .downloading(let p):
                return p
            case .completed:
                return 1
            case .failed:
                return 0
            }
        }
    }
    enum DownloadManagerStatus {
        case idle
        case downloading
        case completed
        case failed
        case canceled
    }
    
    static let shared = VideoDownloadManager()
    /// Download camera video.
    var downloader: WLVDBVideoDownloader?
    /// Download web sever video.
    var mp4Downloader: MP4VideoDownloader?
    var tasks = [DownloadTask]()
    var completedTasks = [DownloadTask]()
    var status: DownloadManagerStatus = .idle {
        didSet {
            if status == .downloading {
                myIdleTimerManager.instance().myIdleTimerAdd(self)
            } else {
                myIdleTimerManager.instance().myIdleTimerRemove(self)
            }
        }
    }
    var notifyInterval: TimeInterval = 0.1
    private var lock = NSLock()
    fileprivate var lastNotifyTime: Date?
    var taskCount: Int {
        return tasks.count + completedTasks.count
    }
    var currentTaskNumber: Int {
        return completedTasks.count + 1
    }
    var totalBytes: Int64 {
        var bytes: Int64 = 0
        for task in tasks {
            bytes += task.bytes
        }
        for task in completedTasks {
            bytes += task.bytes
        }
        return bytes
    }
    
    var completedBytes: Int64 {
        var bytes = Int64(tasks[0].status.progress * Double(tasks[0].bytes))
        for task in completedTasks {
            bytes += task.bytes
        }
        return bytes
    }
    
    var progress: Double {
        if tasks.isEmpty {
            return 1
        }
        let total = totalBytes
        if total == 0 {
            return 1
        }
        return Double(completedBytes) / Double(total)
    }
    
    var incompletedBytes: Int64 {
        return Int64((1-progress) * Double(totalBytes))
    }
    
    func reset() {
        status = .idle
        tasks.removeAll()
        completedTasks.removeAll()
    }
    
    func downloadStatusFor(_ clip: BasicClip, index: Int32) -> DownloadTaskStatus? {
        if let task = completedTasks.first(where: { $0.clip.isIdenticalTo(clip) && ($0.streamIndex == index)}) {
            return task.status
        } else if let task = tasks.first(where:{ $0.clip.isIdenticalTo(clip)  && ($0.streamIndex == index)}) {
            return task.status
        } else {
            return nil
        }
    }
    
    func addTask(url: String, local:Bool, clip: BasicClip, bytes: Int64, streamIndex: Int32) throws {
        if status != .downloading && status != .idle {
            reset()
        }
        lock.lock()
        if let _ = downloadStatusFor(clip, index: streamIndex) {
            lock.unlock()
            throw VideoDownloadError.alreadyInQueue
        }
        var task = DownloadTask(url: url, local: local, clip: clip, bytes: bytes)
        task.streamIndex = streamIndex
        let remained = Int64(MySystemUtil.getFreeDiskspace()) - incompletedBytes - Int64(Double(bytes) * 1.1)
        if remained < 0 {
            lock.unlock()
            throw VideoDownloadError.notEnoughSpace(-remained)
        }
        tasks.append(task)
        if status != .downloading {
            next()
        }
        notify()
        lock.unlock()
    }
    
    fileprivate func next() {
        if tasks.isEmpty { // all tasks completed
            status = .completed
            notify()
            return
        }
        status = .downloading
        let task = tasks[0]
        tasks[0].status = .downloading(0)
        if task.isLocal {
            downloader = WLVDBVideoDownloader(url: task.url, duration: task.duration * 1000, delegate: self)
        } else {
            mp4Downloader = MP4VideoDownloader(urlString: task.url)
            mp4Downloader?.delegate = self
            mp4Downloader?.start()
        }
    }
    
    func cancel() {
        downloader?.cancelTask()
        downloader = nil
        status = .canceled
        tasks.removeAll()
        notify()
        // TODO: cancel mp4 downloader
    }
    
    fileprivate func notify() {
        lastNotifyTime = Date()
        NotificationCenter.default.post(name: Notification.Name.Downloader.stateChanged, object: nil)
    }
}

extension VideoDownloadManager: WLVDBVideoDownloaderDelegate {
    func vdbVideoDownloader(_ vdbVideoDownloader: WLVDBVideoDownloader!, onDownloadProcess process: Int32) {
        Log.verbose("VDB video download progress \(process)")
        if process < 0 {
            // failed
            tasks[0].status = .failed
            downloader?.cancelTask()
            downloader = nil
            status = .failed
            notify()
        } else if (process == 200) {
            // completed
            guard let task = tasks.first, let pathStr = downloader?.getFileURL() else { return }
            downloader = nil
            let originalPath = URL(fileURLWithPath: pathStr)
            SavedClipManager.shared.moveVideo(from: originalPath, toLibrary: task.toLibrary, clip: task.clip, streamIndex: task.streamIndex, completion: { (success, savedClip) in
                if success {
                    self.tasks[0].status = .completed
                    self.tasks[0].savedClip = savedClip
                    self.completedTasks.append(self.tasks[0])
                    self.tasks.removeFirst()
                    self.next()
                } else {
                    self.tasks[0].status = .failed
                    self.status = .failed
                }
                self.notify()
            })
        } else {
            // downloading
            if tasks.count > 0 {
                tasks[0].status = .downloading(Double(process) * 0.01)
                if lastNotifyTime == nil || -lastNotifyTime!.timeIntervalSinceNow > notifyInterval {
                    notify()
                }
            }
        }
    }

    func vdbVideoDownloader(_ vdbVideoDownloader: WLVDBVideoDownloader!, onDownloadedBytes bytes: Int64) {
        if !tasks.isEmpty {
            tasks[0].status = .downloading(downloader?.currentProgress() ?? 0)
        }
        if lastNotifyTime == nil || -lastNotifyTime!.timeIntervalSinceNow > notifyInterval {
            notify()
        }
    }
}

extension VideoDownloadManager: MP4DownloaderDelegate {
    func onDownloadProgress(_ progress: Progress) {
        if tasks.count > 0 {
            tasks[0].status = .downloading(progress.fractionCompleted)
            if lastNotifyTime == nil || -lastNotifyTime!.timeIntervalSinceNow > notifyInterval {
                notify()
            }
        }
    }
    
    func onDownloadComplete(success:Bool, error:Error?) {
        if success {
            // completed
            guard let task = tasks.first, let originalPath = mp4Downloader?.downloadedFileURL else { return }
            SavedClipManager.shared.moveVideo(from: originalPath, toLibrary: task.toLibrary, clip: task.clip, streamIndex: task.streamIndex, completion: { (success, savedClip) in
                if success {
                    self.tasks[0].status = .completed
                    self.tasks[0].savedClip = savedClip
                    self.completedTasks.append(self.tasks[0])
                    self.tasks.removeFirst()
                    self.next()
                } else {
                    self.tasks[0].status = .failed
                    self.status = .failed
                }
                self.notify()
            })
        } else {
            // failed
            tasks[0].status = .failed
            downloader?.cancelTask()
            downloader = nil
            status = .failed
            notify()
        }
    }
}

extension Notification.Name {
    struct Downloader {
        static let stateChanged = Notification.Name(rawValue: "waylens.acht.notification.name.downloader.statechanged")
    }
}
