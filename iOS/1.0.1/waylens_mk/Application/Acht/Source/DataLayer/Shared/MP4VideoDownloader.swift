//
//  MP4VideoDownloader.swift
//  Acht
//
//  Created by Chester Shen on 9/10/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import Foundation
import Alamofire
import WaylensFoundation

protocol MP4DownloaderDelegate {
    func onDownloadProgress(_ progress: Progress)
    func onDownloadComplete(success:Bool, error:Error?)
}

class MP4VideoDownloader {
    var url: URL
    var delegate: MP4DownloaderDelegate?
    var downloadedFileURL: URL?
    init(urlString: String) {
        url = URL(string: urlString)!
        
    }
    
    func start() {
        let _headers = [
            "User-Agent"    : WaylensClientS.shared.userAgent,
        ]
        let destination: DownloadRequest.DownloadFileDestination = {temporaryURL, response in
            if let suggestedFileName = response.suggestedFilename {
                do {
                    
                    self.downloadedFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/" + suggestedFileName)
                    if let url = self.downloadedFileURL {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        return (destinationURL: url, options: [.removePreviousFile, .createIntermediateDirectories])
                    }
                } catch let e {
                    Log.warn("Failed to get temporary directory - \(e)")
                }
            }
            let (url, _) = DownloadRequest.suggestedDownloadDestination()(temporaryURL, response)
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(url, headers: _headers, to: destination)
            .downloadProgress { [weak self] (progress) in
            self?.delegate?.onDownloadProgress(progress)
        }
            .response { response in
            self.delegate?.onDownloadComplete(success: response.error == nil, error: response.error)
        }
    }
}
