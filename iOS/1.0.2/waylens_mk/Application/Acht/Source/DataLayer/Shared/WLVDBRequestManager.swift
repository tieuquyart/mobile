//
//  WLVDBRequestManager.swift
//  Acht
//
//  Created by Chester Shen on 9/6/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

public enum VDBResult<Value> {
    case success(Value)
    case failure
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
}

public typealias VDBResultHandler<Value> = (VDBResult<Value>)->Void
public typealias VDBDownloadInfo = (url: String, kBytes: Double, subUrl: String?, subsizek: Double, subnUrl: String?, subnsizek: Double, date: Date, duration: TimeInterval)
public class VDBRequest {
    let id: UInt32
    var sentTime: Date?
    var handlers = [VDBResultHandler<Any>]()
    var operation: BlockOperation?
    var task: Task?
    weak var manager: WLVDBRequestManager?
    public init (id: UInt32, completionHandler: VDBResultHandler<Any>? ) {
        self.id = id
        if completionHandler != nil {
            self.handlers.append(completionHandler!)
        }
    }
    
    public func cancel() {
        task?.cancel()
        operation?.cancel()
        manager?.requestMap.removeValue(forKey: id)
    }
}

class Task {
    enum TaskState {
        case pending
        case doing
        case done
        case failed
        case cancelled
    }
    var state: TaskState = .pending
    var ignorable: Bool = false
    var executionBlock: (() -> Swift.Void)?
    weak var queue: TaskQueue?
    weak var request: VDBRequest?
    init(block: @escaping () -> Swift.Void) {
        executionBlock = block
    }
    
    func run() {
        guard state == .pending else {
            return
        }
        state = .doing
        executionBlock?()
    }
    
    func done() {
        state = .done
        remove()
    }
    
    func fail() {
        state = .failed
        remove()
    }
    
    func cancel() {
        state = .cancelled
        remove()
    }
    
    func remove() {
        executionBlock = nil
        queue?.removeTask(self)
    }
}

extension Task:Equatable {
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs === rhs
    }
}

class TaskQueue {
    var q = [Task]()
    var doingTasks = [Task]()
    let lock = NSLock()
    var maxConcurrentCount: Int = 1
    var concurrentCount: Int {
        return doingTasks.count
    }
    func addTask(_ task: Task) -> Bool {
        var removeIgnoreTask : Task? // not current task
        lock.lock()
        if task.ignorable && q.count > 1 {
            for i in (0..<q.count).reversed() {
                if q[i].ignorable {
                    removeIgnoreTask = q[i]
                    q.remove(at: i)
                    break
                }
            }
        }
        task.queue = self
        q.append(task)
        lock.unlock()
        if (removeIgnoreTask != nil) {
            NSLog("ignore request: \(String(describing: removeIgnoreTask?.request?.id)).")
            removeIgnoreTask?.request?.cancel()
        }
        next()
        return true
    }
    
    func removeTask(_ task: Task) {
        lock.lock()
        if let i = doingTasks.firstIndex(of: task) {
            doingTasks.remove(at: i)
        } else if let i = q.firstIndex(of: task) {
            q.remove(at: i)
        }
        lock.unlock()
        next()
    }
    
    func next() {
        if q.count == 0 {
            return
        }
        if concurrentCount < maxConcurrentCount {
            lock.lock()
            let task = q.first
            q.removeFirst()
            doingTasks.append(task!)
            lock.unlock()
            task?.run()
        }
    }
}

public class WLVDBRequestManager: NSObject {
    private var counter: UInt32 = 10000
    var vdb: WLCameraVDBClient
    let lock = NSLock()
    var requestMap = [UInt32: VDBRequest]()
    let queue: OperationQueue
    var thumbnailTaskQueue: TaskQueue
    public init(withVDB vdb: WLCameraVDBClient) {
        self.vdb = vdb
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .utility
        thumbnailTaskQueue = TaskQueue()
        thumbnailTaskQueue.maxConcurrentCount = 2
        super.init()
        vdb.requestDelegate = self
    }
    
    private func newRequest(completion: VDBResultHandler<Any>?) -> VDBRequest {
        lock.lock()
        counter += 1
        lock.unlock()
        let request = VDBRequest(id: counter, completionHandler: completion)
        request.manager = self
        requestMap[request.id] = request
        return request
    }
    
    public func getThumbnail(forClip clip: WLVDBClip, atTime point:Double, ignorable:Bool=false, cache: Bool=true, completion:@escaping VDBResultHandler<Any>) -> VDBRequest {
//        Log.debug("request thumbnail for clip \(clip.clipID) at \(point) ignorable:\(ignorable)")
//        Log.debug("clip id \(clip.clipID) uuid \(clip.uuid) start \(clip.startTime) pts \(Int64(point*1000))")
        let request = newRequest(completion: completion)
        let operation = BlockOperation { [weak self, weak request] in
            guard let req = request, let this = self else { return }
            req.sentTime = Date()
            this.vdb.getThumbnailForClip(clip.clipID, in: WLVDBDomain(rawValue: UInt32(clip.clipType)), atTime: point, tag: req.id, canBeIgnore: false, with: clip.vdbID, useCache: cache)
        }
        request.operation = operation
        request.task = Task { [weak self] in
            self?.queue.addOperation(operation)
        }
        request.task?.ignorable = ignorable
        request.task?.request = request
        _ = thumbnailTaskQueue.addTask(request.task!)
        return request
    }
    
    public func getDownloadUrl(forClip clip: WLVDBClip, from: TimeInterval=0, duration: TimeInterval=0, stream: Int32=0, completion:@escaping VDBResultHandler<Any>) {
        let request = newRequest(completion: completion)
        let startTime = clip.startTime + from
        let length = duration > 0 ? min(duration, clip.duration) : clip.duration
        
        // `WLCameraVDBClient.mm` -> `- (void)getDownloadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length main:(BOOL)bmain sub:(BOOL)bsub subn:(int)subn tag:(uint32_t)tag`
        // `CameraVDBClient+Recv.mm` -> `VDB_CMD_GetDownloadUrlEx`
        vdb.getDownloadURL(
            forClip: clip.clipID,
            in: WLVDBDomain(rawValue: UInt32(clip.clipType)),
            from: startTime,
            length: length,
            main: clip.resolutions.count > 0 ? true : false,
            sub: clip.resolutions.count > 1 ? true : false, // Single stream has no sub-stream
            subn: stream,
            tag: request.id
        )
    }
    
    public func getGpsData(forClip clip: WLVDBClip, atTime point:Double, completion:@escaping VDBResultHandler<Any>) -> VDBRequest {
        let request = newRequest(completion: completion)
        vdb.getRawData(withACC: false, gps: true, obd: false, forClip: clip.clipID, in: WLVDBDomain(rawValue: UInt32(clip.clipType)), atTime: point, tag: request.id, withVDBId: clip.vdbID)
        return request
    }
}

extension WLVDBRequestManager: WLVDBRequestDelegate {
    public func onGet(_ thumbnail: WLVDBThumbnail) {
        let key = UInt32(thumbnail.tag)
        if let request = requestMap[key] {
            var result: VDBResult<Any>?
            Log.debug("Get thumbnail for clip \(thumbnail.clipID) at \(thumbnail.pts), response time:\(-request.sentTime!.timeIntervalSinceNow)")
            if thumbnail.imageData == nil {
                result = .failure
                request.task?.fail()
            } else {
                result = .success(thumbnail)
                request.task?.done()
            }
            //            let result = (thumbnail.img == nil) ? .failure : .success(thumbnail)
            for handler in request.handlers {
                handler(result!)
            }
            requestMap.removeValue(forKey: key)
        }
    }
    
    public func onGetDownloadURL(_ mainurl: String?, mainsize mainsizek: Double, sub subUrl: String?, subsize subsizek: Double, subn subnUrl: String?, subnsize subnsizek: Double, date mainDate: Date, length: UInt32, tag: UInt32) {
        guard let request = requestMap[tag] else { return }
        Log.debug("Get Download Url for main(\(mainsizek)KB):\(mainurl ?? "nil"), sub(\(subsizek)KB):\(subUrl ?? "nil"), subn(\(subnsizek)KB):\(subnUrl ?? "nil"), date:\(mainDate), length:\(length)")
        var result: VDBResult<Any>?
        if mainurl != nil {
            result = .success((url: mainurl!, kBytes: mainsizek, subUrl: subUrl, subsizek: subsizek, subnUrl: subnUrl, subnsizek: subnsizek, date: mainDate, duration: Double(length)/1000))
        } else {
            result = .failure
        }
        for handler in request.handlers {
            handler(result!)
        }
        requestMap.removeValue(forKey: tag)
    }
    
    public func onGetGpsData(_ info: gpsInfor_t, in domain: WLVDBDomain, tag: UInt32) {
        guard let request = requestMap[tag] else { return }
        let result: VDBResult<Any>?
        if info.hdop < 0 {
            result = .failure
        } else {
            result = .success(info)
        }
        for handler in request.handlers {
            handler(result!)
        }
        requestMap.removeValue(forKey: tag)
    }
    
}
