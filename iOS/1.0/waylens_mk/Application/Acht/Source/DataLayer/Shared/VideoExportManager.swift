//
//  VideoExportManger.swift
//  Acht
//
//  Created by forkon on 2019/5/8.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

protocol VideoExportMangerDelegate {

}

class VideoExportManager {
    private var progressClosure: ((Float) -> ())? = nil
    private var successClosure: (() -> ())? = nil
    private var failureClosure: (() -> ())? = nil

    var isExporting: Bool {
        return VideoDownloadManager.shared.status == .downloading
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(videoDownloadManagerStatusDidChange), name: Notification.Name.Downloader.stateChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func exportClip(_ clip: HNClip, from camera: UnifiedCamera, streamIndex: Int32, progress: ((Float) -> ())?, success: (() -> ())?, failure: (() -> ())?) {
        if let rawclip = clip.rawClip, let vdbManager = camera.local?.vdbManager {
            vdbManager.getDownloadUrl(forClip: rawclip, from: 0.0, duration: clip.duration, stream: streamIndex, completion:{ [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }

                if result.isSuccess {
                    strongSelf.progressClosure = progress
                    strongSelf.successClosure = success
                    strongSelf.failureClosure = failure

                    let info = result.value as! VDBDownloadInfo
                    let bytes = Int64(info.kBytes) * 1000

                    do {
                        var url = String(info.url)
                        if streamIndex != 0 {
                            var subs = url.split(separator: "/")
                            for i in 0...subs.count-1 {
                                if subs[subs.count-1-i] == "0" {
                                    subs[subs.count-1-i] = "\(streamIndex)"
                                }
                            }
                            url = String(subs[0] + "/")
                            for i in 1...subs.count-1 {
                                url = url + "/" + subs[i]
                            }
                        }
                        try VideoDownloadManager.shared.addTask(url: url, local: true, clip: clip, bytes: bytes, streamIndex: streamIndex)
                    } catch VideoDownloadError.alreadyInQueue {
                        Log.info("Download task already in queue")
                        strongSelf.failureClosure?()
                    } catch VideoDownloadError.notEnoughSpace(_/*let short*/) {
                        //let size = String.fromBytes(short, countStyle: .file)
                        //let msg = String(format: NSLocalizedString("not_enough_free_space", comment: "Not enough free space.\nNeed at least %@ more"), size)
                        strongSelf.failureClosure?()
                    } catch {
                        // pass
                    }
                } else {
                    strongSelf.failureClosure?()
//                    this.fail(.failToGetUrl, message: NSLocalizedString("Fail to get download url", comment: "Fail to get download url"))
                }
            })
        }
    }

    func cancel() {
        VideoDownloadManager.shared.cancel()
    }
}

private extension VideoExportManager {

    @objc func videoDownloadManagerStatusDidChange() {
        let manager = VideoDownloadManager.shared
        switch manager.status {
        case .idle:
            break
        case .downloading:
            progressClosure?(Float(manager.progress))
        case .canceled:
            break
        case .failed:
            failureClosure?()
        case .completed:
            successClosure?()
        }
    }

}
